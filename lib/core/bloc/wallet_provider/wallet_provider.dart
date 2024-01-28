import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:ethers/signers/wallet.dart' as ethers;
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/core/model/wallet_model.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

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

  initWeb3Client(Network network) {
    Client httpClient = Client();
    activeNetwork = network;
    web3client = Web3Client(network.url, httpClient);
    notifyListeners();
  }

  String getAccountName() {
    return userPreference
        .get(activeWallet.wallet.privateKey.address.hex.toLowerCase());
  }

  String getAccountNameFor(String address) {
    return userPreference.get(address);
  }

  Future<void> copyPublicAddress() async {
    await Clipboard.setData(
      ClipboardData(text: activeWallet.wallet.privateKey.address.hex),
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

  loadWallets(dynamic walletJson, String password) {
    for (var element in walletJson) {
      Wallet wallet = Wallet.fromJson(element, password);
      wallets.add(WalletModel(
          balance: 0,
          wallet: wallet,
          accountName:
              userPreference.get(wallet.privateKey.address.hex.toLowerCase())));
    }
    activeWallet = wallets[activeAccountIndex];
    notifyListeners();
  }

  changeNetwork(int index) {
    final network = Core.networks[index];
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
    loadWallets(walletJson, password);
    notifyListeners();
  }

  createNewAccount() async {
    final secure = Random.secure();
    String seedPhrase = await fss.read(key: "seed_phrase") ?? "";
    String password = await fss.read(key: "seed_phrase") ?? "";
    ethers.Wallet newWallet = ethers.Wallet.fromMnemonic(seedPhrase,
        path: "m/44'/60'/0'/0/${wallets.length + 1}");
    Wallet wallet = Wallet.createNew(
        EthPrivateKey.fromHex(newWallet.privateKey!), password, secure);

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
  }
}
