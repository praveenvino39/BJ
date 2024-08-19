// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:ethers/crypto/formatting.dart';
import 'package:ethers/signers/wallet.dart' as ethers;
import 'package:ethers/utils/hdnode/hd_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/core/model/wallet_model.dart';
import 'package:wallet_cryptomask/core/model/wc_ethereum_transaction.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';
import 'package:wallet_cryptomask/ui/screens/wallet-connect-screen/widgets/connect_sheet.dart';
import 'package:wallet_cryptomask/ui/screens/wallet-connect-screen/widgets/transaction_sheet.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/proposal_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_events.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart' as wc;
import 'package:web3dart/web3dart.dart';

WalletProvider getWalletProvider(BuildContext context) =>
    context.read<WalletProvider>();

WalletProvider getLiveWalletProvider(BuildContext context) =>
    Provider.of<WalletProvider>(context);

class CreatePasswordIsolateType {
  String privateKey;
  String password;
  SendPort sendPort;
  CreatePasswordIsolateType(
      {required this.privateKey,
      required this.password,
      required this.sendPort});
}

void createWalletWithPasswordIsolate(CreatePasswordIsolateType args) {
  try {
    Wallet wallet = Wallet.createNew(
        EthPrivateKey.fromHex(args.privateKey), args.password, Random());
    args.sendPort.send(wallet);
  } catch (e) {
    args.sendPort.send(e);
  }
}

class WalletProvider extends ChangeNotifier {
  final List<Network> networks;
  bool loading = false;
  bool switchingChain = false;
  FlutterSecureStorage fss;
  Box userPreference;
  late Web3Client web3client;
  Timer? timer;
  late int activeAccountIndex;
  late String defaultCurrency;
  late WalletModel activeWallet;
  late Network activeNetwork;
  List<WalletModel> wallets = [];
  String balanceInPrefereCurrency = "0";
  double nativeBalance = 0.0;
  wc.Web3Wallet? web3Wallet;

  WalletProvider(this.fss, this.userPreference, this.networks);

  showLoading() {
    loading = true;
    notifyListeners();
  }

  hideLoading() {
    loading = false;
    notifyListeners();
  }

  startNetworkSwitch() {
    switchingChain = true;
    notifyListeners();
  }

  networkSwitched() {
    switchingChain = false;
    notifyListeners();
  }

  Network getNetwork(String networkName) {
    try {
      return networks
          .firstWhere((element) => element.networkName == networkName);
    } catch (e) {
      return networks[0];
    }
  }

  changeNativeBalance(double balance) {
    nativeBalance = balance;
    notifyListeners();
  }

  changeFiatBalance(String balanceInFiat) {
    balanceInPrefereCurrency = balanceInFiat;
    notifyListeners();
  }

  getPrivateKey() {
    return activeWallet.wallet.privateKey;
  }

  initWeb3Client(Network network) {
    Client httpClient = Client();
    activeNetwork = network;
    web3client = Web3Client(network.url, httpClient);
    notifyListeners();
  }

  Future<String?> getSecretRecoveryPhrase() {
    return fss.read(key: "seed_phrase");
  }

  String getAccountName() {
    return userPreference
        .get(activeWallet.wallet.privateKey.address.hex.toLowerCase());
  }

  String getCurrentAccountAddress() {
    return activeWallet.wallet.privateKey.address.hex;
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
      this.wallets = [];
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

  Future<void> changeNetwork(int index) async {
    final network = networks[index];
    await userPreference.put("NETWORK", network.networkName);
    initWeb3Client(network);
    emitChainChanged(network.chainId.toString(), network.nameSpace);
  }

  Future<void> changeNetworkWithChainId(int chainId, String topic) async {
    final network =
        networks.firstWhereOrNull((chain) => chain.chainId == chainId);
    initWeb3Client(network!);
  }

  // setupWalletConnect() async {
  //   // if (GetIt.I.isRegistered<WC2Service>(instance: walletConnectSingleTon)) {
  //   await GetIt.I.unregister<WC2Service>(instanceName: walletConnectSingleTon);
  //   // }
  //   WC2Service web3service = WC2Service(
  //       address: activeWallet.wallet.privateKey.address.hex,
  //       chainId: activeNetwork.chainId.toString(),
  //       nameSpace: activeNetwork.nameSpace,
  //       preference: userPreference,
  //       privateKey: activeWallet.wallet.privateKey,
  //       networks: networks);
  //   GetIt.I.registerSingleton<WC2Service>(web3service,
  //       instanceName: walletConnectSingleTon);
  //   web3service.create();
  //   await web3service.init();
  // }

  updateBalance() {
    try {
      web3client
          .getBalance(
        activeWallet.wallet.privateKey.address,
      )
          .then((balance) {
        changeNativeBalance(balance.getValueInUnit(EtherUnit.ether));
        networkSwitched();
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  updateBalanceTimer() {
    updateBalance();
    if (timer != null) {
      timer?.cancel();
    }
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      updateBalance();
    });
  }

  changeAccount(int index) async {
    activeWallet = wallets[index];
    userPreference.put('ACCOUNT', index);
    notifyListeners();
    emitAccountChanged(
        getCurrentAccountAddress(), activeWallet.wallet.privateKey);
  }

  Future<void> openWallet({required password}) async {
    final walletString = await fss.read(key: "wallet");
    if (walletString == null) {
      throw Exception("Something went wrong");
    }
    String activeNetwork =
        userPreference.get("NETWORK", defaultValue: networks[0].networkName);

    activeAccountIndex = userPreference.get("ACCOUNT", defaultValue: 0);
    defaultCurrency = userPreference.get("CURRENCY", defaultValue: "usd");
    final walletJson = jsonDecode(walletString);
    await loadWallets(walletJson, password);
    initWeb3Client(getNetwork(activeNetwork));
    emitAccountChanged(getAccountName(), activeWallet.wallet.privateKey);
    emitChainChanged(this.activeNetwork.chainId.toString(),
        getCurrentNamespaceWithChainId());
    await login();
    updateBalanceTimer();
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
    receiverPort.listen((walletDy) async {
      final wallet = walletDy as Wallet;
      await addAccount(
          wallet.privateKey.address.hex, wallet.privateKey.privateKey);
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

  Future<void> importFromPassphrase(
      {required String seedPhrase, required String password}) async {
    Completer futureCompleter = Completer();
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
    wallets = [];
    balanceInPrefereCurrency = "0";
    nativeBalance = 0.0;
    timer?.cancel();
    timer = null;
    List<SessionData> sessions = web3Wallet?.sessions.getAll() ?? [];
    try {
      for (var session in sessions) {
        await web3Wallet?.sessions.delete(session.topic);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  login() async {
    final message = DateTime.now().toString();
    //ALWAYS USING FIRST WALLET SINCE IT IS THE MAINACCOUNT
    final hash = EthSigUtil.signPersonalMessage(
        message: utf8.encode(message),
        privateKey: bytesToHex(wallets[0].wallet.privateKey.privateKey));
    final userLoginResponse = await RemoteServer.loginUser(
        message: message,
        hash: hash,
        address: wallets[0].wallet.privateKey.address.hex);
    debugPrint(userLoginResponse.data.token ?? "");
    Get.put(userLoginResponse.data);
  }

  addAccount(String address, Uint8List pk) async {
    final message = DateTime.now().toString();
    //ALWAYS USING FIRST WALLET SINCE IT IS THE MAINACCOUNT
    final hash = EthSigUtil.signPersonalMessage(
        message: utf8.encode(message), privateKey: bytesToHex(pk));
    final addLoginResponse = await RemoteServer.addAccount(
        message: message, hash: hash, address: address);
    final user = Get.find<User>();
    addLoginResponse.data.token = user.token;
    await Get.delete<User>();
    Get.put<User>(addLoginResponse.data);
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
        dynamic walletString = (await fss.read(key: "wallet")) ?? "[]";
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
  }

  Future<void> importAccountFromSeedphraseOnboarding(
      {required String seedphrase, required String password}) async {
    FlutterSecureStorage fss = const FlutterSecureStorage();
    Completer futureCompleter = Completer();
    ReceivePort receiverPort = ReceivePort();
    final hdNode = HDNode.fromMnemonic(seedphrase);
    Isolate.spawn(
        createWalletWithPasswordIsolate,
        CreatePasswordIsolateType(
            privateKey: hdNode.privateKey!,
            password: password,
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
        await fss.write(key: "seed_phrase", value: seedphrase);
        await fss.write(key: "password", value: password);
        Box box = await Hive.openBox("user_preference");
        await box.put(
            data.privateKey.address.hex.toString().toLowerCase(), "Account 1");
        await userPreference.put("ACCOUNT", 0);
        notifyListeners();
        return futureCompleter.complete();
      } catch (e) {
        return futureCompleter.completeError(e);
      }
    });
    return futureCompleter.future;
  }

  Future<String?> sendTransaction(
      String to,
      double value,
      double selectedPriority,
      double selectedMaxFee,
      int gasLimit,
      bool fee) async {
    try {
      int nonce = await web3client.getTransactionCount(
          EthereumAddress.fromHex(activeWallet.wallet.privateKey.address.hex));
      BigInt chainID = await web3client.getChainId();
      Transaction transaction = Transaction(
        to: EthereumAddress.fromHex(to),
        value: EtherAmount.fromUnitAndValue(
            EtherUnit.wei, BigInt.from(value * pow(10, 18))),
        nonce: nonce,
        maxGas: gasLimit,
      );
      String transactionHash = await web3client.sendTransaction(
          activeWallet.wallet.privateKey, transaction,
          chainId: chainID.toInt());
      if (fee) {
        return transactionHash;
      }
      final box = await Hive.openBox("user_preference");

      List<dynamic> recentAddresses =
          box.get("RECENT-TRANSACTION-ADDRESS", defaultValue: []);
      if (recentAddresses.contains(to)) {
        recentAddresses.remove(to);
      }
      recentAddresses.add(to);
      box.put("RECENT-TRANSACTION-ADDRESS", recentAddresses);
      return transactionHash;
    } catch (e) {
      return null;
    }
  }

  setupWalletConnect() {
    web3Wallet = wc.Web3Wallet(
      core: wc.Core(
        projectId: projectId,
      ),
      metadata: wc.PairingMetadata(
        name: appName,
        description: appName,
        url: 'https://walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
      ),
    );
    web3Wallet?.onSessionProposal.subscribe(onSessionProposal);
  }

  bool isSupported(int chainId) {
    return networks.firstWhereOrNull((network) => network.chainId == chainId) !=
        null;
  }

  Future<void> init() async {
    await web3Wallet!.init();
    for (var network in networks) {
      initHandlers(network.nameSpace, network.chainId.toString());
    }
  }

  initHandlers(String namespace, String chainId) {
    setupAddChainRequest(namespace, chainId);
    setupPersonalSignHandler(namespace, chainId);
    setupEthSignHandler(namespace, chainId);
    setupSignTransactionHandler(namespace, chainId);
    setupTransactionHandler(namespace, chainId);
    setupSignTypedDataHandler(namespace, chainId);
  }

  onSendTransactionV2(
    String from,
    WCEthereumTransaction ethereumTransaction, {
    required String iconUrl,
    required String origin,
    required Function(String) onApprove,
    required Function() onReject,
  }) {
    Get.dialog(
        AlertDialog(
            insetPadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            content: WillPopScope(
              onWillPop: () async {
                Completer<bool> completor = Completer<bool>();
                Get.dialog(SimpleDialog(
                  title: const WalletText(
                    localizeKey: 'rejectConfirmation',
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: WalletText(
                        localizeKey: 'rejectRequestConfirmation',
                        align: TextAlign.center,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: WalletButton(onPressed: () {
                            Get.back();
                            onReject();
                            completor.complete(false);
                          }),
                        ),
                        Expanded(
                          child: WalletButton(
                              localizeKey: "no",
                              onPressed: () {
                                Get.back();
                                completor.complete(false);
                              }),
                        ),
                      ],
                    )
                  ],
                ));
                return completor.future;
              },
              child: TransactionSheet(
                  fromWalletConnect: true,
                  iconUrl: iconUrl,
                  onApprove: (txHash) {
                    onApprove(txHash);
                  },
                  onReject: () {
                    onReject();
                  },
                  connectingOrgin: origin,
                  transaction: ethereumTransaction.toJson()),
            )),
        barrierDismissible: false);
    if (ethereumTransaction.from.toLowerCase() != from.toLowerCase()) {
      Get.dialog(Center(
        child: WalletButton(
          onPressed: () {
            final wallet = wallets.firstWhereOrNull((wallet) =>
                wallet.wallet.privateKey.address.hex.toLowerCase() ==
                from.toLowerCase());
            if (wallet != null) {
              changeAccount(wallets.indexOf(wallet));
            }
          },
          localizeKey: 'switchAccount',
        ),
      ));
    }
  }

  setupTransactionHandler(String namespace, String chainId) {
    web3Wallet!.registerRequestHandler(
      chainId: "$namespace:$chainId",
      method: "eth_sendTransaction",
      handler: (method, params) {
        Completer sendTransactionFuture = Completer();
        onSendTransactionV2(
          activeWallet.wallet.privateKey.address.hex,
          WCEthereumTransaction.fromJson(params[0]),
          iconUrl: "iconUrl",
          origin: "Current Dapp",
          onApprove: (txHash) {
            sendTransactionFuture.complete(txHash);
          },
          onReject: () {
            sendTransactionFuture.completeError("User rejected");
          },
        );

        return sendTransactionFuture.future;
      },
    );
  }

  setupSignTransactionHandler(String namespace, String chainId) {
    web3Wallet!.registerRequestHandler(
      chainId: "$namespace:$chainId",
      method: "eth_signTransaction",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          title: const WalletText(
            localizeKey: 'ethSign',
          ),
          actions: [
            WalletButton(onPressed: () {
              String sign = EthSigUtil.signPersonalTypedData(
                  jsonData: params[1],
                  version: TypedDataVersion.V4,
                  privateKeyInBytes: activeWallet.wallet.privateKey.privateKey);
              Get.back();
              return signFuture.complete(sign);
            })
          ],
        ));
        return signFuture.future;
      },
    );
  }

  setupSignTypedDataHandler(String namespace, String chainId) {
    web3Wallet!.registerRequestHandler(
      chainId: "$namespace:$chainId",
      method: "eth_signTypedData",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          title: const WalletText(
            localizeKey: 'signData',
          ),
          content: Text(params[1]),
          actions: [
            WalletButton(
                localizeKey: "approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  String sign = EthSigUtil.signTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V4,
                      privateKeyInBytes:
                          activeWallet.wallet.privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                localizeKey: "reject",
                onPressed: () {
                  Get.back();
                  return signFuture.complete(null);
                }),
          ],
        ));
        return signFuture.future;
      },
    );
    web3Wallet!.registerRequestHandler(
      chainId: "${activeNetwork.nameSpace}:${activeNetwork.chainId}",
      method: "eth_signTypedData_v1",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          title: const WalletText(
            localizeKey: "signData",
          ),
          content: Text(params[1]),
          actions: [
            WalletButton(
                localizeKey: "approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  String sign = EthSigUtil.signTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V1,
                      privateKeyInBytes:
                          activeWallet.wallet.privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                localizeKey: "reject",
                onPressed: () {
                  Get.back();
                  return signFuture.complete(null);
                }),
          ],
        ));
        return signFuture.future;
      },
    );
    web3Wallet!.registerRequestHandler(
      chainId: "${activeNetwork.nameSpace}:${activeNetwork.chainId}",
      method: "eth_signTypedData_v3",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          title: const WalletText(
            localizeKey: 'signData',
          ),
          content: Text(params[1]),
          actions: [
            WalletButton(
                type: WalletButtonType.filled,
                localizeKey: "approve",
                onPressed: () {
                  String sign = EthSigUtil.signTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V3,
                      privateKeyInBytes:
                          activeWallet.wallet.privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                type: WalletButtonType.filled,
                localizeKey: "reject",
                onPressed: () {
                  Get.back();
                  return signFuture.complete(null);
                }),
          ],
        ));
        return signFuture.future;
      },
    );
    web3Wallet!.registerRequestHandler(
      chainId: "${activeNetwork.nameSpace}:${activeNetwork.chainId}",
      method: "eth_signTypedData_v4",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          title: const WalletText(
            localizeKey: 'signData',
          ),
          content: Text(params[1]),
          actions: [
            WalletButton(
                localizeKey: "approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  String sign = EthSigUtil.signTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V4,
                      privateKeyInBytes:
                          activeWallet.wallet.privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                localizeKey: "reject",
                onPressed: () {
                  Get.back();
                  return signFuture.complete(null);
                }),
          ],
        ));
        return signFuture.future;
      },
    );
  }

  setupEthSignHandler(String namespace, String chainId) {
    web3Wallet!.registerRequestHandler(
      chainId: "$namespace:$chainId",
      method: "eth_sign",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          content: isHexString(params[1])
              ? Text(String.fromCharCodes(hexToBytes(params[1])))
              : Text(params[1]),
          title: const WalletText(
            localizeKey: 'signMessage',
          ),
          actions: [
            WalletButton(
                localizeKey: "approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  final encodedMessage = hexToBytes(params[1]);
                  String sign = EthSigUtil.signMessage(
                    message: encodedMessage,
                    privateKey:
                        bytesToHex(activeWallet.wallet.privateKey.privateKey),
                  );
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                localizeKey: 'reject',
                onPressed: () {
                  Get.back();
                  return signFuture.complete(null);
                })
          ],
        ));
        return signFuture.future;
      },
    );
  }

  setupAddChainRequest(String namespace, String chainId) {
    web3Wallet!.registerRequestHandler(
      chainId: "$namespace:$chainId",
      method: "wallet_addEthereumChain",
      handler: (method, params) {
        if (hexToDartInt(params[0]['chainId']) == activeNetwork.chainId) {
          return activeNetwork.chainId;
        }
        return null;
      },
    );
  }

  setupPersonalSignHandler(String namespace, String chainId) {
    web3Wallet!.registerRequestHandler(
      chainId: "$namespace:$chainId",
      method: "personal_sign",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          content: isHexString(params[0])
              // ignore: prefer_interpolation_to_compose_strings
              ? Text("${String.fromCharCodes(hexToBytes(params[0]))}/n" +
                  params[1])
              : Text(params[0] + "/n" + params[1]),
          title: const WalletText(
            localizeKey: 'personalSign',
          ),
          actions: [
            WalletButton(
                localizeKey: "approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  final encodedMessage = hexToBytes(params[0]);
                  String sign = EthSigUtil.signPersonalMessage(
                      message: encodedMessage,
                      privateKeyInBytes:
                          activeWallet.wallet.privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                localizeKey: "reject",
                onPressed: () {
                  Get.back();
                  return signFuture.completeError("User rejected");
                })
          ],
        ));
        return signFuture.future;
      },
    );
  }

  void onSessionProposal(SessionProposalEvent? args) async {
    if (args != null) {
      List<String> chains = [];
      for (var key in args.params.requiredNamespaces.keys) {
        final namespace = args.params.requiredNamespaces[key];
        for (var chain in namespace?.chains ?? []) {
          chains.add(chain);
        }
      }

      for (var key in args.params.optionalNamespaces.keys) {
        final namespace = args.params.optionalNamespaces[key];
        for (var chain in namespace?.chains ?? []) {
          chains.add(chain);
        }
      }

      if (chains.isEmpty) {
        return;
      }
      final namespaceExist = chains.contains(getCurrentNamespaceWithChainId());
      if (namespaceExist) {
        Get.dialog(
          AlertDialog(
            insetPadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            backgroundColor: Colors.white,
            content: ConnectSheet(
              imageUrl: args.params.proposer.metadata.icons.isNotEmpty
                  ? args.params.proposer.metadata.icons[0]
                  : "",
              connectingOrgin: args.params.proposer.metadata.url,
              onApprove: (addresses) async {
                Map<String, RequiredNamespace> allNamespace = {};
                allNamespace.addAll(args.params.requiredNamespaces);
                allNamespace.addAll(args.params.optionalNamespaces);
                await web3Wallet!.approveSession(
                    id: args.id,
                    namespaces:
                        getWalletNamespaceForCurrentChain(allNamespace));
              },
              onReject: () async {
                await web3Wallet!.rejectSession(
                  id: args.id,
                  reason: wc.Errors.getSdkError(
                    wc.Errors.USER_REJECTED,
                  ),
                );
              },
            ),
          ),
        );
      } else {
        final networks = this
            .networks
            .where((e) => chains.contains("${e.nameSpace}:${e.chainId}"))
            .toList();
        Get.snackbar("", "",
            backgroundColor: Colors.redAccent,
            snackPosition: SnackPosition.BOTTOM,
            borderRadius: 0,
            margin: const EdgeInsets.all(0),
            titleText: const WalletText(
              localizeKey: "error",
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            messageText: WalletText(
                localizeKey: networks.isNotEmpty
                    ? "Please switch network to ${networks[0].networkName}"
                    : "Unsupported network",
                color: Colors.white));
      }
    }
  }

  emitChainChanged(String chainId, String nameSpace) {
    web3Wallet?.sessions.getAll().forEach((session) {
      web3Wallet?.updateSession(
          topic: session.topic, namespaces: session.namespaces);
      web3Wallet?.emitSessionEvent(
          topic: session.topic,
          chainId: "$nameSpace:$chainId",
          event: wc.SessionEventParams(name: "chainChanged", data: chainId));
    });
  }

  emitAccountChanged(String address, EthPrivateKey privateKey) {
    web3Wallet?.registerAccount(
      chainId: getCurrentNamespaceWithChainId(),
      accountAddress: activeWallet.wallet.privateKey.address.hex,
    );
    web3Wallet?.sessions.getAll().forEach((session) {
      web3Wallet!.emitSessionEvent(
          topic: session.topic,
          chainId: getCurrentNamespaceWithChainId(),
          event: wc.SessionEventParams(
              name: "accountsChanged",
              data: "${getCurrentNamespaceWithChainId()}:$address"));
    });
  }

  getWalletNamespaceForCurrentChain(
      Map<String, RequiredNamespace> requiredNamespaces) {
    Map<String, Namespace> walletNamespaces = {};
    requiredNamespaces.forEach((key, value) {
      List<String> methods =
          requiredNamespaces[activeNetwork.nameSpace]?.methods ?? [];
      List<String> events =
          requiredNamespaces[activeNetwork.nameSpace]?.events ?? [];
      List<String> accounts = [];
      (requiredNamespaces[activeNetwork.nameSpace]?.chains ?? []).map((chain) {
        accounts.add(
            "$chain:${activeWallet.wallet.privateKey.address.hex.toString()}");
      }).toList();

      walletNamespaces[key] =
          Namespace(accounts: accounts, methods: methods, events: events);
    });
    return walletNamespaces;
  }

  getWalletNamesapceForRequested(
    Map<String, RequiredNamespace> requiredNamespaces,
  ) {
    Map<String, Namespace> walletNamespaces = {};
    requiredNamespaces.forEach((key, value) {
      List<String> methods =
          requiredNamespaces[activeNetwork.nameSpace]?.methods ?? [];
      List<String> events =
          requiredNamespaces[activeNetwork.nameSpace]?.events ?? [];
      List<String> accounts = [];
      (requiredNamespaces[activeNetwork.nameSpace]?.chains ?? []).map((chain) {
        accounts.add(
            "$chain:${activeWallet.wallet.privateKey.address.hex.toString()}");
      }).toList();

      walletNamespaces[key] =
          Namespace(accounts: accounts, methods: methods, events: events);
    });
    return walletNamespaces;
  }

  Network? getNetworkFromRequiredChain(String chainIdInEIP) {
    try {
      return networks.firstWhere((Network network) =>
          "${network.nameSpace}:${network.chainId}" == chainIdInEIP);
    } catch (e) {
      return null;
    }
  }

  String getCurrentNamespaceWithChainId() {
    return "${activeNetwork.nameSpace}:${activeNetwork.chainId}";
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
