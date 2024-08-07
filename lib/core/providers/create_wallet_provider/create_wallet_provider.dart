import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:bip39/bip39.dart' as bip39;
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:ethers/crypto/formatting.dart';
import 'package:ethers/utils/hdnode/hd_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:web3dart/web3dart.dart';

void createWalletWithPasswordIsolate(CreatePasswordIsolateType args) {
  Wallet wallet = Wallet.createNew(
      EthPrivateKey.fromHex(args.privateKey), args.password, Random());
  args.sendPort.send(wallet);
}

CreateWalletProvider getCreateWalletProvider(BuildContext context) =>
    context.read<CreateWalletProvider>();

class CreateWalletProvider extends ChangeNotifier {
  String _password = '';
  List<String> _passphrase = [];
  FlutterSecureStorage fss;

  CreateWalletProvider(this.fss);

  setPassword(String password) {
    _password = password;
  }

  String getPassword() => _password;

  List<String> getPassphrase() => _passphrase;

  setPassphrase(List<String> passphrase) {
    _passphrase = passphrase;
  }

  Future<void> createWalletWithPassword(
      String passphrase, String password, String privateKey) async {
    Completer futureCompleter = Completer();
    ReceivePort receiverPort = ReceivePort();
    Isolate.spawn(
        createWalletWithPasswordIsolate,
        CreatePasswordIsolateType(
            privateKey: privateKey,
            password: password,
            sendPort: receiverPort.sendPort));
    receiverPort.listen((data) async {
      FlutterSecureStorage fss = const FlutterSecureStorage();
      await fss.write(
          key: "wallet", value: jsonEncode([(data as Wallet).toJson()]));
      await fss.write(key: "seed_phrase", value: passphrase);
      await fss.write(key: "password", value: password);
      Box box = await Hive.openBox("user_preference");
      await box.put(data.privateKey.address.hex, "Account 1");
      notifyListeners();
      futureCompleter.complete();
    });
    return futureCompleter.future;
  }

  Future<void> createWallet() async {
    FlutterSecureStorage fss = const FlutterSecureStorage();
    Completer futureCompleter = Completer();
    ReceivePort receiverPort = ReceivePort();
    String generatedMnemonic = bip39.generateMnemonic();
    final hdNode = HDNode.fromMnemonic(generatedMnemonic);
    Isolate.spawn(
        createWalletWithPasswordIsolate,
        CreatePasswordIsolateType(
            privateKey: hdNode.privateKey!,
            password: _password,
            sendPort: receiverPort.sendPort));
    receiverPort.listen((data) async {
      final wallet = (data as Wallet);
      try {
        final message = DateTime.now().toString();

        final hash = EthSigUtil.signPersonalMessage(
            message: utf8.encode(message),
            privateKey: bytesToHex(wallet.privateKey.privateKey));
        await RemoteServer.registerUser(
            message: message,
            hash: hash,
            address: wallet.privateKey.address.hex);
        await fss.write(key: "wallet", value: jsonEncode([wallet.toJson()]));
        await fss.write(key: "seed_phrase", value: generatedMnemonic);
        await fss.write(key: "password", value: _password);
        Box box = await Hive.openBox("user_preference");
        await box.put(data.privateKey.address.hex, "Account 1");
        notifyListeners();
        futureCompleter.complete();
      } catch (e) {
        futureCompleter.completeError(e);
      }
    });
    return futureCompleter.future;
  }
}
