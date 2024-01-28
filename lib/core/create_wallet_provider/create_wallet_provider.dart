import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:wallet_cryptomask/ui/onboard/component/create-password/bloc/create_wallet_cubit.dart';
import 'package:web3dart/web3dart.dart';

void createWalletWithPasswordIsolate(CreatePasswordIsolateType args) {
  Wallet wallet = Wallet.createNew(
      EthPrivateKey.fromHex(args.privateKey), args.password, Random());
  args.sendPort.send(wallet);
}

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
}
