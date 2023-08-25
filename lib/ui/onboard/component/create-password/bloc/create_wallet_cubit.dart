import 'dart:convert';
// ignore: library_prefixes
import 'dart:developer' as printLog;
import 'dart:isolate';
import 'dart:math';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:web3dart/web3dart.dart';
import 'package:ethers/signers/wallet.dart' as ethers;

part 'create_wallet_state.dart';

class CreatePasswordIsolateType {
  String privateKey;
  String password;
  String passpharse;
  SendPort sendPort;
  CreatePasswordIsolateType(
      {required this.privateKey,
      required this.passpharse,
      required this.password,
      required this.sendPort});
}

void createWalletWithPasswordIsolate(CreatePasswordIsolateType args) {
  Wallet wallet = Wallet.createNew(
      EthPrivateKey.fromHex(args.privateKey), args.password, Random());
  args.sendPort.send(wallet);
}

class CreateWalletCubit extends Cubit<CreateWalletState> {
  CreateWalletCubit() : super(CreateWalletInitial());
  createWalletWithPassword(
      String passphrase, String password, String privateKey) async {
    ReceivePort receiverPort = ReceivePort();
    Isolate.spawn(
        createWalletWithPasswordIsolate,
        CreatePasswordIsolateType(
            privateKey: privateKey,
            passpharse: passphrase,
            password: password,
            sendPort: receiverPort.sendPort));
    receiverPort.listen((data) async {
      FlutterSecureStorage fss = const FlutterSecureStorage();
      await fss.write(key: "wallet", value: jsonEncode([(data as Wallet).toJson()]));
      await fss.write(key: "seed_phrase", value: passphrase);
      Box box = await Hive.openBox("user_preference");
      box.put(data.privateKey.address.hex, "Account 1");
      printLog.log("SAVED ${await fss.read(key: "wallet")}");
      printLog.log("SAVED ${await fss.read(key: "seed_phrase")}");
      emit(CreateWalletSuccess());
    });
  }

  createWalletFromPassPhrase(String passphrase, String password) async {
    var walletFromMnemonic = ethers.Wallet.fromMnemonic(passphrase);
    Wallet wallet = Wallet.createNew(
        EthPrivateKey.fromHex(walletFromMnemonic.privateKey!),
        password,
        Random());
    FlutterSecureStorage fss = const FlutterSecureStorage();
    await fss.write(key: "wallet", value: jsonEncode([wallet.toJson()]));
    await fss.write(key: "seed_phrase", value: passphrase);
    Box box = await Hive.openBox("user_preference");
    box.put(wallet.privateKey.address.hex, "Account 1");
    emit(CreateWalletSuccess());
  }
}
