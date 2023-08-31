// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as debug;
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:ethers/signers/wallet.dart' as ethers;
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart'; //You can also import the browser version
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wallet/core/ERC20.dart';
import 'package:wallet/core/abi.dart';
import 'package:wallet/core/core.dart';
import 'package:wallet/core/model/collectible_model.dart';
import 'package:wallet/core/model/network_model.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/core/model/wallet_model.dart';
import 'package:wallet/core/remote/http.dart';
import 'package:web3dart/web3dart.dart';

part 'wallet_state.dart';

enum SwapType { ethForToken, tokenForToken, tokenForEth }

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial()) {
    // initialize();
  }

  initialize(String password, {required Function(String) onError}) {
    FlutterSecureStorage fss = const FlutterSecureStorage();
    fss.write(key: "password", value: password).then((value) => {
          fss.read(key: "wallet").then((value) {
            if (value != null) {
              Hive.openBox("user_preference").then((box) {
                String? network = box.get("NETWORK");
                int? accountIndex = box.get("ACCOUNT");
                String currency = box.get("CURRENCY") ?? "usd";

                late Web3Client web3client;
                Client httpClient = Client();
                Network? preferedNetwork;
                if (network != null) {
                  try {
                    preferedNetwork = Core.networks.firstWhere(
                        (element) => element.networkName == network);
                    web3client = Web3Client(preferedNetwork.url, httpClient);
                  } catch (e) {
                    preferedNetwork = Core.networks[0];
                    web3client = Web3Client(Core.networks[0].url, httpClient);
                  }
                } else {
                  preferedNetwork = Core.networks[0];
                  web3client = Web3Client(Core.networks[0].url, httpClient);
                }

                List<WalletModel> availabeWallet = [];
                List<dynamic> walletJson = jsonDecode(value);
                late Wallet wallet;

                try {
                  if (accountIndex != null) {
                    wallet =
                        Wallet.fromJson(walletJson[accountIndex], password);
                  } else {
                    wallet = Wallet.fromJson(walletJson[0], password);
                  }
                } catch (e) {
                  onError((e as dynamic).message.toString());
                }

                for (var element in walletJson) {
                  Wallet newWallet = Wallet.fromJson(element, password);
                  availabeWallet.add(WalletModel(
                      balance: 0,
                      wallet: newWallet,
                      accountName: box.get(newWallet.privateKey.address.hex)));
                }

                emit(WalletUnlocked(
                    tokens: const [],
                    pendingTransaction: const [],
                    collectibles: const [],
                    wallet: wallet,
                    balanceInUSD: 0,
                    web3client: web3client,
                    currentNetwork: preferedNetwork,
                    availabeWallet: availabeWallet,
                    currency: currency,
                    password: password));
              });
            }
          })
        });
  }

  Future<void> createNewAccount(String password,
      {bool isImported = false}) async {
    var rng = Random.secure();
    WalletLoaded curentState = (state as WalletLoaded);
    FlutterSecureStorage fss = const FlutterSecureStorage();
    String? seedPhrase = await fss.read(key: "seed_phrase");
    late ethers.Wallet newWallet;
    if (isImported) {
      newWallet = ethers.Wallet.fromMnemonic(seedPhrase!);
    } else {
      newWallet = ethers.Wallet.fromMnemonic(seedPhrase!,
          path: "m/44'/60'/0'/0/${curentState.availabeWallet.length + 1}");
    }

    Wallet wallet = Wallet.createNew(
        EthPrivateKey.fromHex(newWallet.privateKey!), password, rng);

    // receivePort.listen((data) async {
    dynamic walletExist = await fss.read(key: "wallet");
    if (walletExist != null) {
      List<dynamic> walletJson = jsonDecode(walletExist);
      walletJson.add(wallet.toJson());
      await fss.write(key: "wallet", value: jsonEncode(walletJson));
      Box box = await Hive.openBox("user_preference");
      box.put(wallet.privateKey.address.hex, "Account ${walletJson.length}");
      curentState.availabeWallet.add(WalletModel(
          balance: 0,
          wallet: wallet,
          accountName: box.get(wallet.privateKey.address.hex)));
      box.put("ACCOUNT", curentState.availabeWallet.length - 1);
      box.put(wallet.privateKey.address.hex, "Account ${walletJson.length}");
      emit(
        WalletLoaded(
            currency: curentState.currency,
            collectibles: curentState.collectibles,
            tokens: curentState.tokens,
            password: curentState.password,
            wallet: curentState.wallet,
            pendingTransaction: curentState.pendingTransaction,
            balanceInUSD: curentState.balanceInUSD,
            web3client: curentState.web3client,
            currentNetwork: curentState.currentNetwork,
            availabeWallet: curentState.availabeWallet),
      );
    }
    // });
  }

  Future<void> importAccountFromPrivateKey(String privateKey,
      {bool isImported = true,
      required Function onsuccess,
      required Function alreadyExist}) async {
    FlutterSecureStorage fss = const FlutterSecureStorage();
    if (privateKey.contains("0x")) {
      privateKey = privateKey.substring(2);
    }
    var password = await fss.read(key: "password");
    Wallet wallet = Wallet.createNew(
        EthPrivateKey.fromHex(privateKey), password!, Random());
    WalletLoaded curentState = (state as WalletLoaded);
    try {
      curentState.availabeWallet.firstWhere((element) =>
          element.wallet.privateKey.address.hex.toLowerCase() ==
          wallet.privateKey.address.hex);
      alreadyExist();
      return;
    } catch (e) {
      dynamic walletExist = await fss.read(key: "wallet");
      if (walletExist != null) {
        List<dynamic> walletJson = jsonDecode(walletExist);
        walletJson.add(wallet.toJson());
        await fss.write(key: "wallet", value: jsonEncode(walletJson));
        Box box = await Hive.openBox("user_preference");
        box.put(wallet.privateKey.address.hex, "Account ${walletJson.length}");
        curentState.availabeWallet.add(WalletModel(
            balance: 0,
            wallet: wallet,
            accountName: box.get(wallet.privateKey.address.hex)));
        box.put("ACCOUNT", curentState.availabeWallet.length - 1);
        box.put(wallet.privateKey.address.hex, "Account ${walletJson.length}");
        onsuccess();
        emit(
          WalletLoaded(
              currency: curentState.currency,
              collectibles: curentState.collectibles,
              tokens: curentState.tokens,
              password: curentState.password,
              wallet: curentState.wallet,
              pendingTransaction: curentState.pendingTransaction,
              balanceInUSD: curentState.balanceInUSD,
              web3client: curentState.web3client,
              currentNetwork: curentState.currentNetwork,
              availabeWallet: curentState.availabeWallet),
        );
      }
    }

    // });
  }

  Future<void> changeNetwork(Network network) async {
    WalletLoaded curentState = (state as WalletLoaded);
    Client httpClient = Client();
    Web3Client web3client = Web3Client(network.url, httpClient);
    Box box = await Hive.openBox("user_preference");
    box.put("NETWORK", network.networkName);
    curentState.currentNetwork = network;
    curentState.web3client = web3client;
    emit(WalletNetworkChanged(
        currency: curentState.currency,
        tokens: curentState.tokens,
        collectibles: curentState.collectibles,
        password: curentState.password,
        wallet: curentState.wallet,
        pendingTransaction: curentState.pendingTransaction,
        balanceInUSD: curentState.balanceInUSD,
        web3client: curentState.web3client,
        currentNetwork: curentState.currentNetwork,
        availabeWallet: curentState.availabeWallet));
  }

  Future<void> changeAccount(int accountIndex) async {
    WalletLoaded curentState = (state as WalletLoaded);
    Box box = await Hive.openBox("user_preference");
    box.put("ACCOUNT", accountIndex);
    curentState.wallet = curentState.availabeWallet[accountIndex].wallet;
    emit(WalletAccountChanged(
        currency: curentState.currency,
        tokens: curentState.tokens,
        pendingTransaction: curentState.pendingTransaction,
        collectibles: curentState.collectibles,
        password: curentState.password,
        wallet: curentState.wallet,
        balanceInUSD: curentState.balanceInUSD,
        web3client: curentState.web3client,
        currentNetwork: curentState.currentNetwork,
        availabeWallet: curentState.availabeWallet));
  }

  // Future<double> getFiatBalance(
  //     EthereumAddress address, EtherAmount amount) async {
  //   double currentPrice = (await getPrice())!.currentPrice;
  //   return amount.getValueInUnit(EtherUnit.ether) * currentPrice;
  // }

  Future<void> eraseWallet() async {
    FlutterSecureStorage fss = const FlutterSecureStorage();
    Box box = await Hive.openBox("user_preference");
    await box.clear();
    await fss.deleteAll();
    emit(WalletErased());
  }

  Future<EtherAmount> getNativeBalane(EthereumAddress address) async {
    Network network = (state as WalletLoaded).currentNetwork;
    var httpClient = Client();
    Web3Client ethClient = Web3Client(network.url, httpClient);
    EtherAmount amount = await ethClient.getBalance(address);
    return amount;
  }

  importAccount(String passpharse) async {
    WalletLoaded curentState = (state as WalletLoaded);

    var walletFromMnemonic = ethers.Wallet.fromMnemonic(passpharse);
    Wallet wallet = Wallet.createNew(
        EthPrivateKey.fromHex(walletFromMnemonic.privateKey!),
        curentState.password!,
        Random());
    var isExist = curentState.availabeWallet.firstWhere(
        (element) =>
            element.wallet.privateKey.address.hex ==
            wallet.privateKey.address.hex, orElse: () {
      return WalletModel(balance: -1, wallet: wallet, accountName: "");
    });
    if (isExist.balance == -1) {
      FlutterSecureStorage fss = const FlutterSecureStorage();
      dynamic walletExist = await fss.read(key: "wallet");
      if (walletExist != null) {
        List<dynamic> walletJson = jsonDecode(walletExist);
        walletJson.add(wallet.toJson());
        await fss.write(key: "wallet", value: jsonEncode(walletJson));
        Box box = await Hive.openBox("user_preference");

        curentState.availabeWallet.add(WalletModel(
            balance: 0,
            wallet: wallet,
            accountName: box.get(wallet.privateKey.address.hex)));
        box.put("ACCOUNT", curentState.availabeWallet.length - 1);
        emit(
          WalletImported(
              currency: curentState.currency,
              tokens: curentState.tokens,
              wallet: curentState.wallet,
              pendingTransaction: curentState.pendingTransaction,
              balanceInUSD: curentState.balanceInUSD,
              collectibles: curentState.collectibles,
              web3client: curentState.web3client,
              currentNetwork: curentState.currentNetwork,
              availabeWallet: curentState.availabeWallet,
              password: curentState.password),
        );
      }
    } else {
      emit(WalletImported(
          currency: curentState.currency,
          tokens: curentState.tokens,
          wallet: curentState.wallet,
          collectibles: curentState.collectibles,
          balanceInUSD: curentState.balanceInUSD,
          pendingTransaction: curentState.pendingTransaction,
          web3client: curentState.web3client,
          currentNetwork: curentState.currentNetwork,
          availabeWallet: curentState.availabeWallet,
          password: curentState.password));
    }
  }

  Future logout() async {
    // emit(WalletLogout());
    // FlutterSecureStorage fss = const FlutterSecureStorage();
    // await fss.delete(key: "wallet");
    // var box = await Hive.openBox("user_preference");
    // box.clear();
    emit(WalletLogout());
  }

  Future<Decimal> getTokenBalance(Token token) async {
    WalletLoaded curentState = state as WalletLoaded;
    var contractABI = ContractAbi.fromJson(
        await getAbiFromContract(
            token.tokenAddress, curentState.currentNetwork),
        "");
    var contract = DeployedContract(
        contractABI, EthereumAddress.fromHex(token.tokenAddress));
    var balanceCall = contract.function('balanceOf');
    var balance = await curentState.web3client.call(
      contract: contract,
      function: balanceCall,
      params: [curentState.wallet.privateKey.address],
      // params: [EthereumAddress.fromHex("0xAf08a180AE95d12542aDb7ed9e2A85DF651eF94e")],
    );
    var decimalValue = Decimal.parse(balance[0].toString());
    return (decimalValue / Decimal.fromInt(pow(10, token.decimal).toInt()))
        .toDecimal();
  }

  addToken(String networkKey, Token token) async {
    WalletLoaded curentState = state as WalletLoaded;
    String tokenStoragekey =
        "TOKEN-${curentState.currentNetwork.networkName}-${curentState.wallet.privateKey.address.hex}";
    Box box = await Hive.openBox("user_preference");
    String? isExist = await box.get(tokenStoragekey);

    if (isExist == null) {
      var tokenBalance = await getTokenBalance(token);
      token.balance = tokenBalance.toDouble();
      await box.put(tokenStoragekey, jsonEncode([token]));
    } else {
      var tokenObject = jsonDecode(isExist);
      var tokenArray = (tokenObject as List<dynamic>);
      var isAlreadyAdded = tokenArray.firstWhere(
          (element) => element["tokenAddress"] == token.tokenAddress,
          orElse: () {
        return "NOT_FOUND";
      });
      if (isAlreadyAdded == "NOT_FOUND") {
        var tokenBalance = await getTokenBalance(token);
        token.balance = tokenBalance.toDouble();
        tokenArray.add(token);
      }
      await box.put(tokenStoragekey, jsonEncode(tokenObject));
      // }
    }
    emit(WalletTokenAdded(
        currency: curentState.currency,
        tokens: curentState.tokens,
        pendingTransaction: curentState.pendingTransaction,
        wallet: curentState.wallet,
        balanceInUSD: curentState.balanceInUSD,
        web3client: curentState.web3client,
        collectibles: curentState.collectibles,
        currentNetwork: curentState.currentNetwork,
        availabeWallet: curentState.availabeWallet,
        password: curentState.password));
  }

  Future<String> getCollectibleDetails(String collectibleAddress) async {
    WalletLoaded curentState = state as WalletLoaded;
    var contractAbi = ContractAbi.fromJson(jsonEncode(ERC721), "");
    var contract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(collectibleAddress));
    var nameFunction = contract.function('name');
    var nameResult = await curentState.web3client
        .call(contract: contract, function: nameFunction, params: []);
    return (nameResult as dynamic)[0].toString();
  }

  addCollectibles(Collectible collectible) async {
    WalletLoaded curentState = state as WalletLoaded;
    String collectibleStoragekey =
        "COLLECTIBLE-${curentState.currentNetwork.networkName}-${curentState.wallet.privateKey.address.hex}";
    var contractAbi = ContractAbi.fromJson(jsonEncode(ERC721), "");
    var contract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(collectible.tokenAddress));
    var function = contract.function('ownerOf');
    var nameFunction = contract.function('name');
    var uriTokenFunction = contract.function('tokenURI');
    var ownerResult = await curentState.web3client
        .call(contract: contract, function: function, params: [
      BigInt.parse(collectible.tokenId),
    ]);
    debug.log(
        "my address ===> ${curentState.wallet.privateKey.address.hex.toLowerCase()}");
    debug.log(
        "token address ===> ${(ownerResult as dynamic)[0].toString().toLowerCase()}");

    if ((ownerResult as dynamic)[0].toString().toLowerCase() ==
        curentState.wallet.privateKey.address.hex.toLowerCase()) {
      var nameResult = await curentState.web3client
          .call(contract: contract, function: nameFunction, params: []);
      var uriResult = await curentState.web3client
          .call(contract: contract, function: uriTokenFunction, params: [
        BigInt.parse(collectible.tokenId),
      ]);
      Box box = await Hive.openBox("user_preference");
      String? isExist = await box.get(collectibleStoragekey);
      debug.log((ownerResult as dynamic)[0].toString().toLowerCase());
      debug.log(nameResult.toString());
      debug.log(uriResult.toString());
      var response = await Dio().get((uriResult as dynamic)[0].toString());
      collectible.imageUrl = response.data["image"];
      collectible.description = response.data["description"];
      debug.log(jsonEncode(collectible));
      if (isExist == null) {
        await box.put(collectibleStoragekey, jsonEncode([collectible]));
      } else {
        var collectiblesJson = jsonDecode(isExist);
        var collectiblesArray = (collectiblesJson as List<dynamic>);
        var isAlreadyAdded = collectiblesArray.firstWhere(
            (element) =>
                element["tokenAddress"] == collectible.tokenAddress &&
                element["tokenId"] == collectible.tokenId, orElse: () {
          return "NOT_FOUND";
        });
        if (isAlreadyAdded == "NOT_FOUND") {
          collectiblesArray.add(collectible);
        }
        debug.log(isExist);
        await box.put(collectibleStoragekey, jsonEncode(collectiblesArray));
      }
      emit(WalletCollectibleAdded(
          currency: curentState.currency,
          collectibles: curentState.collectibles,
          tokens: curentState.tokens,
          wallet: curentState.wallet,
          balanceInUSD: curentState.balanceInUSD,
          web3client: curentState.web3client,
          currentNetwork: curentState.currentNetwork,
          availabeWallet: curentState.availabeWallet,
          pendingTransaction: curentState.pendingTransaction,
          password: curentState.password));
    } else {
      debug.log(ownerResult[0].toString());
      emit(WalletCollectibleNotOwned(
          pendingTransaction: curentState.pendingTransaction,
          collectibles: curentState.collectibles,
          tokens: curentState.tokens,
          wallet: curentState.wallet,
          currency: curentState.currency,
          balanceInUSD: curentState.balanceInUSD,
          web3client: curentState.web3client,
          currentNetwork: curentState.currentNetwork,
          availabeWallet: curentState.availabeWallet,
          password: curentState.password));
    }
  }

  loadCollectibles() async {
    debug.log("Collectibles LOADING...");
    WalletLoaded curentState = state as WalletLoaded;
    String collectibleStoragekey =
        "COLLECTIBLE-${curentState.currentNetwork.networkName}-${curentState.wallet.privateKey.address.hex}";
    Box box = await Hive.openBox("user_preference");
    String? isExist = await box.get(collectibleStoragekey);
    List<Collectible> collectibleObjList = [];
    var contractAbi = ContractAbi.fromJson(jsonEncode(ERC721), "");

    if (isExist != null) {
      var collectibleList = jsonDecode(isExist);
      for (var collectible in collectibleList) {
        var collectibleObj = Collectible.fromJson(collectible);
        var contract = DeployedContract(
            contractAbi, EthereumAddress.fromHex(collectible["tokenAddress"]));
        var function = contract.function('ownerOf');
        var ownerResult = await curentState.web3client
            .call(contract: contract, function: function, params: [
          BigInt.from(collectible["tokenId"]),
        ]);
        if (ownerResult[0].toString().toLowerCase() ==
            curentState.wallet.privateKey.address.hex.toLowerCase()) {
          collectibleObjList.add(collectibleObj);
        }
      }

      emit(
        WalletCollectiblesLoaded(
            tokens: curentState.tokens,
            collectibles: collectibleObjList,
            wallet: curentState.wallet,
            balanceInUSD: curentState.balanceInUSD,
            web3client: curentState.web3client,
            currentNetwork: curentState.currentNetwork,
            availabeWallet: curentState.availabeWallet,
            pendingTransaction: curentState.pendingTransaction,
            currency: curentState.currency,
            password: curentState.password),
      );
    } else {
      emit(
        WalletCollectiblesLoaded(
            currency: curentState.currency,
            tokens: curentState.tokens,
            collectibles: const [],
            wallet: curentState.wallet,
            balanceInUSD: curentState.balanceInUSD,
            web3client: curentState.web3client,
            currentNetwork: curentState.currentNetwork,
            pendingTransaction: curentState.pendingTransaction,
            availabeWallet: curentState.availabeWallet,
            password: curentState.password),
      );
    }
  }

  addPendingTransaction(String txHash) {
    WalletLoaded curentState = state as WalletLoaded;
    curentState.pendingTransaction.add(txHash);
    emit(
      WalletLoaded(
          tokens: curentState.tokens,
          collectibles: curentState.collectibles,
          currency: curentState.currency,
          wallet: curentState.wallet,
          balanceInUSD: curentState.balanceInUSD,
          web3client: curentState.web3client,
          pendingTransaction: curentState.pendingTransaction,
          currentNetwork: curentState.currentNetwork,
          availabeWallet: curentState.availabeWallet,
          password: curentState.password),
    );
  }

  updatePendingTransaction(List<String> pendingList) {
    WalletLoaded curentState = state as WalletLoaded;
    emit(
      WalletTokenLoaded(
          tokens: curentState.tokens,
          collectibles: curentState.collectibles,
          wallet: curentState.wallet,
          balanceInUSD: curentState.balanceInUSD,
          web3client: curentState.web3client,
          currency: curentState.currency,
          pendingTransaction: pendingList,
          currentNetwork: curentState.currentNetwork,
          availabeWallet: curentState.availabeWallet,
          password: curentState.password),
    );
  }

  loadTokenForNetwork(String networkKey) async {
    debug.log("TOKEN LOADING...");
    WalletLoaded curentState = state as WalletLoaded;
    String tokenStoragekey =
        "TOKEN-${curentState.currentNetwork.networkName}-${curentState.wallet.privateKey.address.hex}";
    Box box = await Hive.openBox("user_preference");
    String? isExist = await box.get(tokenStoragekey);
    List<String> tokensSymbol = [];

    List<Token> tokens = [
      Token(
          balanceInFiat: 0.0,
          tokenAddress: "",
          symbol: curentState.currentNetwork.currency,
          decimal: 18,
          balance: Decimal.parse((await curentState.web3client
                      .getBalance(curentState.wallet.privateKey.address))
                  .getValueInUnit(EtherUnit.ether)
                  .toString())
              .toDouble())
    ];
    tokensSymbol.add(curentState.currentNetwork.currency);

    if (isExist != null) {
      var tokensList = jsonDecode(isExist);
      for (var token in tokensList) {
        var tokenObject = Token.fromJson(token);
        var balance = await getTokenBalance(tokenObject);
        tokenObject.balance = balance.toDouble();
        tokens.add(tokenObject);
        tokensSymbol.add(tokenObject.symbol);
      }

      emit(
        WalletTokenLoaded(
            tokens: tokens,
            collectibles: curentState.collectibles,
            currency: curentState.currency,
            wallet: curentState.wallet,
            balanceInUSD: curentState.balanceInUSD,
            web3client: curentState.web3client,
            pendingTransaction: curentState.pendingTransaction,
            currentNetwork: curentState.currentNetwork,
            availabeWallet: curentState.availabeWallet,
            password: curentState.password),
      );
    } else {
      emit(
        WalletTokenLoaded(
            tokens: tokens,
            collectibles: curentState.collectibles,
            wallet: curentState.wallet,
            balanceInUSD: curentState.balanceInUSD,
            pendingTransaction: curentState.pendingTransaction,
            currency: curentState.currency,
            web3client: curentState.web3client,
            currentNetwork: curentState.currentNetwork,
            availabeWallet: curentState.availabeWallet,
            password: curentState.password),
      );
    }
  }

  sendTransaction(String to, double value, double selectedPriority,
      double selectedMaxFee, int gasLimit, Network network) async {
    WalletLoaded state = this.state as WalletLoaded;

    try {
      int nonce = await state.web3client.getTransactionCount(
          EthereumAddress.fromHex(state.wallet.privateKey.address.hex));
      BigInt chainID = await state.web3client.getChainId();
      Transaction transaction = Transaction(
        gasPrice: network.chainId == 144
            ? EtherAmount.inWei(BigInt.parse("2"))
            : null,
        to: EthereumAddress.fromHex(to),
        value: EtherAmount.fromUnitAndValue(
            EtherUnit.wei, BigInt.from(value * pow(10, 18))),
        nonce: nonce,
        maxPriorityFeePerGas: network.supportsEip1559
            ? EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (selectedPriority * pow(10, 9)).toInt())
            : null,
        maxFeePerGas: network.supportsEip1559
            ? EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (selectedMaxFee * pow(10, 9)).toInt())
            : null,
        maxGas: gasLimit,
      );
      String transactionHash = await state.web3client.sendTransaction(
          state.wallet.privateKey, transaction,
          chainId: chainID.toInt());
      showTransactionStatus(transactionHash, state.web3client);
      // addPendingTransaction(transactionHash);
      Hive.openBox("user_preference").then((box) {
        List<dynamic> recentAddresses =
            box.get("RECENT-TRANSACTION-ADDRESS", defaultValue: []);
        if (recentAddresses.contains(to)) {
          recentAddresses.remove(to);
        }
        recentAddresses.add(to);
        box.put("RECENT-TRANSACTION-ADDRESS", recentAddresses);
      });
      emit(WalletSendTransactionSuccess(
          availabeWallet: state.availabeWallet,
          balanceInUSD: state.balanceInUSD,
          pendingTransaction: [...state.pendingTransaction, transactionHash],
          collectibles: state.collectibles,
          currentNetwork: state.currentNetwork,
          currency: state.currency,
          tokens: state.tokens,
          wallet: state.wallet,
          web3client: state.web3client,
          transactionHash: transactionHash,
          password: state.password));
      debug.log(
          "$selectedPriority $selectedMaxFee TRANSACTION HASH $transactionHash");
    } catch (e) {
      emit(
        WalletSendTransactionFailed(
          error: e.toString(),
          availabeWallet: state.availabeWallet,
          balanceInUSD: state.balanceInUSD,
          pendingTransaction: state.pendingTransaction,
          collectibles: state.collectibles,
          currentNetwork: state.currentNetwork,
          tokens: state.tokens,
          wallet: state.wallet,
          currency: state.currency,
          web3client: state.web3client,
          password: state.password,
        ),
      );
      debug.log(e.toString());
    }
  }

  sendTokenTransaction(
      String to,
      double value,
      int gasLimit,
      double selectedPriority,
      double selectedMaxFee,
      Token selectedToken,
      DeployedContract deployedContract) async {
    WalletLoaded state = this.state as WalletLoaded;
    try {
      BigInt chainID = await state.web3client.getChainId();
      var sendResult = await state.web3client.sendTransaction(
          state.wallet.privateKey,
          Transaction(
            maxGas: gasLimit,
            maxPriorityFeePerGas: EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (selectedPriority * pow(10, 9)).toInt()),
            maxFeePerGas: EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (selectedMaxFee * pow(10, 9)).toInt()),
            to: EthereumAddress.fromHex(selectedToken.tokenAddress),
            data: deployedContract.function("transfer").encodeCall([
              EthereumAddress.fromHex(to),
              BigInt.from((value * pow(10, selectedToken.decimal))),
            ]),
          ),
          chainId: chainID.toInt());
      debug.log("TRANSACTION RESULT ====> $sendResult");
      showTransactionStatus(sendResult, state.web3client);
      // addPendingTransaction(sendResult);
      emit(
        WalletSendTransactionSuccess(
          availabeWallet: state.availabeWallet,
          balanceInUSD: state.balanceInUSD,
          pendingTransaction: [...state.pendingTransaction, sendResult],
          collectibles: state.collectibles,
          currentNetwork: state.currentNetwork,
          tokens: state.tokens,
          wallet: state.wallet,
          web3client: state.web3client,
          currency: state.currency,
          transactionHash: sendResult,
          password: state.password,
        ),
      );
      debug.log(
          "$selectedPriority $selectedMaxFee TRANSACTION HASH $sendResult");
    } catch (e) {
      debug.log((e as dynamic).toString());
      emit(WalletSendTransactionFailed(
        error: e.toString(),
        availabeWallet: state.availabeWallet,
        balanceInUSD: state.balanceInUSD,
        pendingTransaction: state.pendingTransaction,
        collectibles: state.collectibles,
        currentNetwork: state.currentNetwork,
        tokens: state.tokens,
        currency: state.currency,
        wallet: state.wallet,
        web3client: state.web3client,
        password: state.password,
      ));
    }
  }

  changeAccountName(String name) async {
    WalletLoaded state = this.state as WalletLoaded;
    Box box = await Hive.openBox("user_preference");
    box.put(state.wallet.privateKey.address.hex, name);
    initialize(state.password!, onError: (e) {});
  }

  swapToken(
      {required String swapType,
      required Web3Client web3client,
      required String tokenFrom,
      required String tokenTo,
      required EtherAmount amount,
      required BigInt fee,
      required String recipient,
      required BigInt amountOut}) async {
    WalletLoaded currentState = (state as WalletLoaded);

    const routerContractAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    String swapReceipt = "";

    //APPROVING ROUTER TO TRANSACT FROM TOKEN
    Erc20 token = Erc20(
        address: EthereumAddress.fromHex(swapType == "ETH2TOKEN"
            ? currentState.currentNetwork.wrappedTokenAddress
            : tokenFrom),
        client: web3client,
        chainId: (await web3client.getChainId()).toInt());
    await token.approve(
      EthereumAddress.fromHex(routerContractAddress),
      amount.getValueInUnitBI(EtherUnit.wei),
      credentials: currentState.wallet.privateKey,
      transaction: Transaction(),
    );

    //SWAPING TOKEN
    ContractAbi contractAbi =
        ContractAbi.fromJson(jsonEncode(UNISWAP_SWAP_ROUTER), "");
    DeployedContract deployedContract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(routerContractAddress));
    if (swapType == "ETH2TOKEN") {
      debug.log("SWAPING ETH FOR TOKEN");
      var swapResult = await web3client.sendTransaction(
          (state as WalletLoaded).wallet.privateKey,
          Transaction.callContract(
            gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxFeePerGas: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxPriorityFeePerGas:
                EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxGas: 1000000,
            value: amount,
            contract: deployedContract,
            function: deployedContract.function("swapETHForExactTokens"),
            parameters: [
              amountOut,
              [
                EthereumAddress.fromHex(tokenFrom),
                EthereumAddress.fromHex(tokenTo),
              ],
              EthereumAddress.fromHex(recipient),
              BigInt.from(DateTime.now()
                  .add(const Duration(minutes: 10))
                  .millisecondsSinceEpoch),
            ],
          ),
          chainId: (await web3client.getChainId()).toInt());
      debug.log(swapResult);
      swapReceipt = swapResult;
    }
    if (swapType == "TOKEN2TOKEN") {
      debug.log(amount.toString());
      var swapResult = await web3client.sendTransaction(
          (state as WalletLoaded).wallet.privateKey,
          Transaction.callContract(
            gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxFeePerGas: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxPriorityFeePerGas:
                EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxGas: 1000000,
            value: amount,
            contract: deployedContract,
            function: deployedContract.function("swapExactTokensForTokens"),
            parameters: [
              amountOut,
              BigInt.one,
              [
                EthereumAddress.fromHex(tokenFrom),
                EthereumAddress.fromHex(tokenTo),
              ],
              EthereumAddress.fromHex(recipient),
              BigInt.from(DateTime.now()
                  .add(const Duration(minutes: 10))
                  .millisecondsSinceEpoch),
            ],
          ),
          chainId: (await web3client.getChainId()).toInt());
      debug.log(swapResult);
      swapReceipt = swapResult;
    }
    if (swapType == "TOKEN2ETH") {
      debug.log(swapType);
      var swapResult = await web3client.sendTransaction(
          (state as WalletLoaded).wallet.privateKey,
          Transaction.callContract(
            gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxFeePerGas: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxPriorityFeePerGas:
                EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
            maxGas: 1000000,
            // value: amount,
            contract: deployedContract,
            function: deployedContract.function("swapTokensForExactETH"),
            parameters: [
              amountOut,
              amount.getValueInUnitBI(EtherUnit.wei),
              [
                EthereumAddress.fromHex(tokenFrom),
                EthereumAddress.fromHex(tokenTo),
              ],
              EthereumAddress.fromHex(recipient),
              BigInt.from(DateTime.now()
                  .add(const Duration(minutes: 10))
                  .millisecondsSinceEpoch),
            ],
          ),
          chainId: (await web3client.getChainId()).toInt());
      debug.log(swapResult);
      swapReceipt = swapResult;
    }
    emit(WalletSendTransactionSuccess(
        availabeWallet: currentState.availabeWallet,
        balanceInUSD: currentState.balanceInUSD,
        pendingTransaction: [...currentState.pendingTransaction, swapReceipt],
        collectibles: currentState.collectibles,
        currentNetwork: currentState.currentNetwork,
        transactionHash: swapReceipt,
        tokens: currentState.tokens,
        currency: currentState.currency,
        wallet: currentState.wallet,
        web3client: currentState.web3client,
        password: currentState.password));
  }

  Future<String> getCurrenctCurrency() async {
    var box = await Hive.openBox("user_preference");
    var currency = box.get("CURRENCY");
    if (currency != null) {
      return currency;
    } else {
      return "usd";
    }
  }

  void changeVsCurrency(String currency) async {
    Box box = await Hive.openBox("user_preference");
    box.put("CURRENCY", currency);
    var currentState = state as WalletLoaded;
    emit(WalletCurrencyChanged(
        availabeWallet: currentState.availabeWallet,
        balanceInUSD: currentState.balanceInUSD,
        pendingTransaction: [...currentState.pendingTransaction],
        collectibles: currentState.collectibles,
        currentNetwork: currentState.currentNetwork,
        tokens: currentState.tokens,
        currency: currency,
        wallet: currentState.wallet,
        web3client: currentState.web3client,
        password: currentState.password));
  }

  static showTransactionStatus(String txHash, Web3Client web3client) {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      var receipt = await web3client.getTransactionReceipt(txHash);
      if (receipt != null) {
        if (receipt.status == true) {
          Get.showSnackbar(GetSnackBar(
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.green.shade500,
            titleText: const Text(
              "Success",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            messageText: Text(
              "Transaction with $txHash was successful.",
              style: const TextStyle(color: Colors.white),
            ),
          ));
          timer.cancel();
        } else {
          Get.showSnackbar(GetSnackBar(
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.red.shade500,
            titleText: const Text(
              "Failed",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            messageText: Text(
              "Transaction $txHash was failed.",
              style: const TextStyle(color: Colors.white),
            ),
          ));
          timer.cancel();
        }
      }
    });
  }
}
