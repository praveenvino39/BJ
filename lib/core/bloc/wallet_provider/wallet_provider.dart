import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:ethers/signers/wallet.dart' as ethers;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/core/model/wallet_model.dart';
import 'package:wallet_cryptomask/ui/onboard/component/create-password/bloc/create_wallet_cubit.dart';
import 'package:web3dart/web3dart.dart';

class WalletProvider extends ChangeNotifier {
  bool loading = false;
  FlutterSecureStorage fss;
  Box userPreference;
  late Web3Client web3client;
  late int activeAccountIndex;
  late String defaultCurrency;
  late WalletModel activeWallet;
  late Network activeNetwork;
  List<WalletModel> wallets = [];
  String balanceInPrefereCurrency = "0";
  double nativeBalance = 0.0;

  WalletProvider(this.fss, this.userPreference);

  showLoading() {
    loading = true;
    notifyListeners();
  }

  hideLoading() {
    loading = false;
    notifyListeners();
  }

  Network getNetwork(String networkName) {
    try {
      return Core.networks
          .firstWhere((element) => element.networkName == networkName);
    } catch (e) {
      return Core.networks[0];
    }
  }

  changeNativeBalance(double balance) {
    nativeBalance = balance;
    notifyListeners();
  }

  initWeb3Client(Network network) {
    Client httpClient = Client();
    activeNetwork = network;
    web3client = Web3Client(network.url, httpClient);
    notifyListeners();
  }

  String getAccountName() {
    return userPreference
        .get(activeWallet?.wallet.privateKey.address.hex.toLowerCase());
  }

  String getAccountNameFor(String address) {
    return userPreference.get(address);
  }

  Future<void> copyPublicAddress() async {
    await Clipboard.setData(
      ClipboardData(text: activeWallet?.wallet.privateKey.address.hex ?? ""),
    );
  }

  getNativeBalanceFormatted() {
    return "${nativeBalance.toStringAsFixed(18).split(".")[0]}.${nativeBalance.toStringAsFixed(18).split(".")[1].substring(0, 4)} ${activeNetwork.symbol}";
  }

  getPreferedBalanceFormatted() {
    return "$balanceInPrefereCurrency ${defaultCurrency.toUpperCase()}";
  }

  getPreferedBalance() {
    return double.parse(balanceInPrefereCurrency);
  }

  Future<void> loadWallets(dynamic walletJson, String password) async {
    Completer futureCompleter = Completer();
    ReceivePort receivePort = ReceivePort();
    Isolate.spawn(
        loadWalletIsolate,
        LoadWalletIsolateType(
            walletJson: walletJson,
            password: password,
            sendPort: receivePort.sendPort));
    receivePort.listen((wallets) {
      if (wallets is ArgumentError) {
        futureCompleter.completeError(wallets);
      }
      for (var wallet in wallets) {
        this.wallets.add(WalletModel(
            balance: 0,
            wallet: wallet,
            accountName: userPreference
                .get(wallet.privateKey.address.hex.toLowerCase())));
      }
      activeWallet = this.wallets[activeAccountIndex];
      notifyListeners();
      futureCompleter.complete();
    });
    return futureCompleter.future;
  }

  changeNetwork(int index) async {
    final network = Core.networks[index];
    await userPreference.put("NETWORK", network.networkName);
    initWeb3Client(network);
  }

  changeAccount(int index) {
    activeWallet = wallets[index];
    notifyListeners();
  }

  Future<void> openWallet({required password}) async {
    final walletString = await fss.read(key: "wallet");
    if (walletString == null) {
      throw Exception("Something went wrong");
    }
    String activeNetwork = userPreference.get("NETWORK",
        defaultValue: Core.networks[0].networkName);
    initWeb3Client(getNetwork(activeNetwork));
    activeAccountIndex = userPreference.get("ACCOUNT", defaultValue: 0);
    defaultCurrency = userPreference.get("CURRENCY", defaultValue: "usd");
    final walletJson = jsonDecode(walletString);
    await loadWallets(walletJson, password);
    notifyListeners();
  }

  Future<void> createNewAccount() async {
    Completer futureCompleter = Completer();
    String seedPhrase = await fss.read(key: "seed_phrase") ?? "";
    String password = await fss.read(key: "password") ?? "";
    ReceivePort receiverPort = ReceivePort();
    Isolate.spawn(
        createAdditionalWalletWithPasswordIsolate,
        CreateAddtionWalletWithPasswordIsolateType(
            passpharse: seedPhrase,
            index: wallets.length + 1,
            password: password,
            sendPort: receiverPort.sendPort));
    receiverPort.listen((wallet) async {
      final walletString = await fss.read(key: "wallet");
      if (walletString == null) {
        throw Exception("Something went wrong");
      }
      List<dynamic> walletJson = jsonDecode(walletString);
      walletJson.add(wallet.toJson());
      await fss.write(key: "wallet", value: jsonEncode(walletJson));
      userPreference.put(wallet.privateKey.address.hex.toLowerCase(),
          "Account ${walletJson.length}");
      wallets.add(WalletModel(
          balance: 0,
          wallet: wallet,
          accountName: userPreference.get(wallet.privateKey.address.hex)));
      notifyListeners();
      futureCompleter.complete();
    });
    return futureCompleter.future;
  }

  Future<void> logout() async {
    wallets = [];
    notifyListeners();
  }

  Future<void> eraseWallet() async {
    await userPreference.clear();
    await fss.deleteAll();
  }

  Future<void> importAccountFromPrivateKey({required String privateKey}) async {
    final futureCompleter = Completer();
    final password = await fss.read(key: "password") ?? "";
    if (privateKey.contains("0x")) {
      privateKey = privateKey.substring(2);
    }
    ReceivePort receiverPort = ReceivePort();
    Isolate.spawn(
        createWalletWithPasswordIsolate,
        CreatePasswordIsolateType(
            privateKey: privateKey,
            password: password,
            sendPort: receiverPort.sendPort));
    receiverPort.listen((wallet) async {
      if (wallet is Exception) {
        futureCompleter.completeError(wallet);
      }
      try {
        wallets.firstWhere((element) =>
            element.wallet.privateKey.address.hex.toLowerCase() ==
            wallet.privateKey.address.hex);
        notifyListeners();
        futureCompleter.complete();
      } catch (e) {
        dynamic walletString = await fss.read(key: "wallet");
        List<dynamic> walletJson = jsonDecode(walletString);
        walletJson.add(wallet.toJson());
        await fss.write(key: "wallet", value: jsonEncode(walletJson));
        userPreference.put(
            wallet.privateKey.address.hex.toString().toLowerCase(),
            "Account ${walletJson.length}");
        wallets.add(WalletModel(
            balance: 0,
            wallet: wallet,
            accountName: userPreference.get(wallet.privateKey.address.hex)));
        userPreference.put("ACCOUNT", wallets.length - 1);
        notifyListeners();
        futureCompleter.complete();
      }
    });
    return futureCompleter.future;
    // Wallet wallet = Wallet.createNew(
    //     EthPrivateKey.fromHex(privateKey), password!, Random());
    // WalletLoaded curentState = (state as WalletLoaded);
    // try {
    //   curentState.availabeWallet.firstWhere((element) =>
    //       element.wallet.privateKey.address.hex.toLowerCase() ==
    //       wallet.privateKey.address.hex);
    //   alreadyExist();
    //   return;
    // } catch (e) {
    //   dynamic walletExist = await fss.read(key: "wallet");
    //   if (walletExist != null) {
    //     List<dynamic> walletJson = jsonDecode(walletExist);
    //     walletJson.add(wallet.toJson());
    //     await fss.write(key: "wallet", value: jsonEncode(walletJson));
    //     Box box = await Hive.openBox("user_preference");
    //     box.put(wallet.privateKey.address.hex, "Account ${walletJson.length}");
    //     curentState.availabeWallet.add(WalletModel(
    //         balance: 0,
    //         wallet: wallet,
    //         accountName: box.get(wallet.privateKey.address.hex)));
    //     box.put("ACCOUNT", curentState.availabeWallet.length - 1);
    //     box.put(wallet.privateKey.address.hex, "Account ${walletJson.length}");
    //     onsuccess();
    //     emit(
    //       WalletLoaded(
    //           currency: curentState.currency,
    //           collectibles: curentState.collectibles,
    //           tokens: curentState.tokens,
    //           password: curentState.password,
    //           wallet: curentState.wallet,
    //           pendingTransaction: curentState.pendingTransaction,
    //           balanceInUSD: curentState.balanceInUSD,
    //           web3client: curentState.web3client,
    //           currentNetwork: curentState.currentNetwork,
    //           availabeWallet: curentState.availabeWallet),
    //     );
    //   }
  }

  Future<String?> sendTransaction(String to, double value,
      double selectedPriority, double selectedMaxFee, int gasLimit) async {
    try {
      showLoading();
      int nonce = await web3client.getTransactionCount(
          EthereumAddress.fromHex(activeWallet.wallet.privateKey.address.hex));
      BigInt chainID = await web3client.getChainId();
      Transaction transaction = Transaction(
        to: EthereumAddress.fromHex(to),
        value: EtherAmount.fromUnitAndValue(
            EtherUnit.wei, BigInt.from(value * pow(10, 18))),
        nonce: nonce,
        maxPriorityFeePerGas: activeNetwork.supportsEip1559
            ? EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (selectedPriority * pow(10, 9)).toInt())
            : null,
        maxFeePerGas: activeNetwork.supportsEip1559
            ? EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (selectedMaxFee * pow(10, 9)).toInt())
            : null,
        maxGas: gasLimit,
      );
      String transactionHash = await web3client.sendTransaction(
          activeWallet.wallet.privateKey, transaction,
          chainId: chainID.toInt());
      // addPendingTransaction(transactionHash);
      final box = await Hive.openBox("user_preference");

      List<dynamic> recentAddresses =
          box.get("RECENT-TRANSACTION-ADDRESS", defaultValue: []);
      if (recentAddresses.contains(to)) {
        recentAddresses.remove(to);
      }
      recentAddresses.add(to);
      box.put("RECENT-TRANSACTION-ADDRESS", recentAddresses);
      hideLoading();
      return transactionHash;
    } catch (e) {
      return null;
    }
  }
}

class CreateAddtionWalletWithPasswordIsolateType {
  String password;
  int index;
  String passpharse;
  SendPort sendPort;
  CreateAddtionWalletWithPasswordIsolateType(
      {required this.passpharse,
      required this.index,
      required this.password,
      required this.sendPort});
}

void createAdditionalWalletWithPasswordIsolate(
    CreateAddtionWalletWithPasswordIsolateType args) {
  ethers.Wallet newWallet = ethers.Wallet.fromMnemonic(args.passpharse,
      path: "m/44'/60'/0'/0/${args.index}");
  Wallet wallet = Wallet.createNew(
      EthPrivateKey.fromHex(newWallet.privateKey!), args.password, Random());
  args.sendPort.send(wallet);
}

class LoadWalletIsolateType {
  dynamic walletJson;
  String password;
  SendPort sendPort;
  LoadWalletIsolateType(
      {required this.password,
      required this.walletJson,
      required this.sendPort});
}

void loadWalletIsolate(LoadWalletIsolateType args) {
  try {
    List<Wallet> wallets = [];
    for (var element in args.walletJson) {
      Wallet wallet = Wallet.fromJson(element, args.password);
      wallets.add(wallet);
    }
    args.sendPort.send(wallets);
  } catch (e) {
    args.sendPort.send(e);
  }
}
