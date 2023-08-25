// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:ethers/crypto/formatting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:wallet/core/model/network_model.dart';
import 'package:wallet/core/model/wc_ethereum_transaction.dart';
import 'package:wallet/ui/dapp_widgets/connect_sheet.dart';
import 'package:wallet/ui/dapp_widgets/network_change_sheet.dart';
import 'package:wallet/ui/dapp_widgets/transaction_sheet.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:wallet/ui/shared/wallet_text.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';
import 'package:wallet/core/core.dart' as i_core;

class WC2Service {
  Web3Wallet? web3Wallet;
  String address;
  EthPrivateKey privateKey;
  final Box preference;
  String nameSpace;
  String chainId;
  bool walletInitialized = false;
  List<Network> networks;

  WC2Service(
      {required this.address,
      required this.privateKey,
      required this.preference,
      required this.nameSpace,
      required this.chainId,
      required this.networks}) {
    walletInitialized = true;
  }

  ValueNotifier<List<SessionData>> sessions =
      ValueNotifier<List<SessionData>>([]);

  void create() {
    web3Wallet = Web3Wallet(
      core: Core(
        projectId: '3304b720b5bb3ee4918ff6cf62f6262a',
      ),
      metadata: const PairingMetadata(
        name: 'Example Wallet',
        description: 'Example Wallet',
        url: 'https://walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
      ),
    );

    // Setup our listeners
    web3Wallet!.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
    web3Wallet!.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
    web3Wallet!.pairings.onSync.subscribe(_onPairingsSync);
    web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
    web3Wallet!.onSessionProposalError.subscribe(_onSessionProposalError);
    web3Wallet!.onSessionConnect.subscribe(_onSessionConnect);
    web3Wallet!.onAuthRequest.subscribe(_onAuthRequest);
    initHandlers(nameSpace, chainId);
  }

  initHandlers(String namespace, String chainId) {
    setupPersonalSignHandler(namespace, chainId);
    setupEthSignHandler(namespace, chainId);
    setupSignTransactionHandler(namespace, chainId);
    setupTransactionHandler(namespace, chainId);
    setupSignTypedDataHandler(namespace, chainId);
  }

  setupTransactionHandler(String namespace, String chainId) {
    web3Wallet!.registerRequestHandler(
      chainId: "$namespace:$chainId",
      method: "eth_sendTransaction",
      handler: (method, params) {
        Completer sendTransactionFuture = Completer();
        WC2Service.onSendTransactionV2(
          WCEthereumTransaction.fromJson(params[0]),
          iconUrl: "iconUrl",
          origin: "origin",
          onApprove: (txHash) {
            sendTransactionFuture.complete(txHash);
          },
          onReject: () {
            Get.back();
            sendTransactionFuture.complete(null);
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
          title: const Text("Eth Sign"),
          actions: [
            WalletButton(
                textContent: "Approve",
                onPressed: () {
                  String sign = EthSigUtil.signPersonalTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V4,
                      privateKeyInBytes: privateKey.privateKey);
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
          title: const Text("Sign Data"),
          content: Text(params[1]),
          actions: [
            WalletButton(
                textContent: "Approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  String sign = EthSigUtil.signTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V4,
                      privateKeyInBytes: privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                textContent: "Reject",
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
      chainId: "${getCurrentNamespace()}:${getCurrentChainId()}",
      method: "eth_signTypedData_v1",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          title: const Text("Sign Data"),
          content: Text(params[1]),
          actions: [
            WalletButton(
                textContent: "Approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  String sign = EthSigUtil.signTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V1,
                      privateKeyInBytes: privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                textContent: "Reject",
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
      chainId: "${getCurrentNamespace()}:${getCurrentChainId()}",
      method: "eth_signTypedData_v3",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          title: const Text("Sign Data"),
          content: Text(params[1]),
          actions: [
            WalletButton(
                type: WalletButtonType.filled,
                textContent: "Approve",
                onPressed: () {
                  String sign = EthSigUtil.signTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V3,
                      privateKeyInBytes: privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                type: WalletButtonType.filled,
                textContent: "Reject",
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
      chainId: "${getCurrentNamespace()}:${getCurrentChainId()}",
      method: "eth_signTypedData_v4",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          title: const Text("Sign Data"),
          content: Text(params[1]),
          actions: [
            WalletButton(
                textContent: "Approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  String sign = EthSigUtil.signTypedData(
                      jsonData: params[1],
                      version: TypedDataVersion.V4,
                      privateKeyInBytes: privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                textContent: "Reject",
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
          title: const Text("Sign Message"),
          actions: [
            WalletButton(
                textContent: "Approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  final encodedMessage = hexToBytes(params[1]);
                  String sign = EthSigUtil.signMessage(
                      message: encodedMessage,
                      privateKeyInBytes: privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                textContent: "Reject",
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

  setupPersonalSignHandler(String namespace, String chainId) {
    web3Wallet!.registerRequestHandler(
      chainId: "$namespace:$chainId",
      method: "personal_sign",
      handler: (method, params) {
        Completer signFuture = Completer();
        Get.dialog(AlertDialog(
          content: isHexString(params[0])
              ? Text(String.fromCharCodes(hexToBytes(params[0])))
              : Text(params[0]),
          title: const Text("Personal sign"),
          actions: [
            WalletButton(
                textContent: "Approve",
                type: WalletButtonType.filled,
                onPressed: () {
                  final encodedMessage = hexToBytes(params[0]);
                  String sign = EthSigUtil.signPersonalMessage(
                      message: encodedMessage,
                      privateKeyInBytes: privateKey.privateKey);
                  Get.back();
                  return signFuture.complete(sign);
                }),
            WalletButton(
                textContent: "Reject",
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

  Future<void> init() async {
    await web3Wallet!.init();
  }

  getCurrentNamespace() {
    return nameSpace;
  }

  getCurrentChainId() {
    return chainId;
  }

  FutureOr onDispose() {
    web3Wallet!.core.pairing.onPairingInvalid.unsubscribe(_onPairingInvalid);
    web3Wallet!.pairings.onSync.unsubscribe(_onPairingsSync);
    web3Wallet!.onSessionProposal.unsubscribe(_onSessionProposal);
    web3Wallet!.onSessionProposalError.unsubscribe(_onSessionProposalError);
    web3Wallet!.onSessionConnect.unsubscribe(_onSessionConnect);
    web3Wallet!.onAuthRequest.unsubscribe(_onAuthRequest);
  }

  void _onPairingsSync(StoreSyncEvent? args) {}

  void _onSessionProposalError(SessionProposalErrorEvent? args) {}

  getWalletNamespaceForCurrentChain(dynamic requiredNamespaces) {
    Map<String, Namespace> walletNamespaces = {};
    requiredNamespaces.forEach((key, value) {
      List<String> methods =
          requiredNamespaces[getCurrentNamespace()]?.methods ?? [];
      List<String> events =
          requiredNamespaces[getCurrentNamespace()]?.events ?? [];
      List<String> accounts = [];
      (requiredNamespaces[getCurrentNamespace()]?.chains ?? []).map((chain) {
        accounts.add("$chain:${privateKey.address.hex.toString()}");
      }).toList();

      walletNamespaces[key] =
          Namespace(accounts: accounts, methods: methods, events: events);
    });
    return walletNamespaces;
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    if (args != null) {
      String requiredNamespaceKey =
          args.params.requiredNamespaces.keys.toList()[0];
      String requiredChain =
          args.params.requiredNamespaces[requiredNamespaceKey]?.chains![0] ??
              "eip:155:5";
      Network? network = getNetworkFromRequiredChain(requiredChain);
      if (network != null) {
        if (network.chainId.toString() == chainId) {
          Get.bottomSheet(
              ConnectSheet(
                imageUrl: args.params.proposer.metadata.icons[0],
                connectingOrgin: args.params.proposer.metadata.url,
                onApprove: (addresses) async {
                  try {
                    await web3Wallet!.approveSession(
                        id: args.id,
                        namespaces: getWalletNamespaceForCurrentChain(
                            args.params.requiredNamespaces));
                  } catch (e) {
                    log(e.toString());
                    String requiredNamespaceKey =
                        args.params.requiredNamespaces.keys.toList()[0];
                    String requiredChain = args
                            .params
                            .requiredNamespaces[requiredNamespaceKey]
                            ?.chains![0] ??
                        "eip:155:5";
                    Network? network =
                        getNetworkFromRequiredChain(requiredChain);
                    Get.snackbar("", "",
                        backgroundColor: Colors.redAccent,
                        snackPosition: SnackPosition.BOTTOM,
                        borderRadius: 0,
                        margin: const EdgeInsets.all(0),
                        titleText: const WalletText(
                          "Error",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        messageText: network != null
                            ? WalletText(
                                "Please switch to ${network.networkName}",
                                color: Colors.white,
                              )
                            : const WalletText("Something went wrong",
                                color: Colors.white));
                  }
                },
                onReject: () async {
                  await web3Wallet!.rejectSession(
                    id: args.id,
                    reason: Errors.getSdkError(
                      Errors.USER_REJECTED,
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white);
        } else {
          Get.bottomSheet(
              NetworkChangeSheet(
                  imageUrl: args.params.proposer.metadata.icons[0],
                  onApprove: (p0) {
                    Get.back();
                    Completer networkSwitchCompleter = Completer();
                    Get.bottomSheet(
                        ConnectSheet(
                          imageUrl: args.params.proposer.metadata.icons[0],
                          connectingOrgin: args.params.proposer.metadata.url,
                          onApprove: (addresses) async {
                            await web3Wallet!.approveSession(
                                id: args.id,
                                namespaces: getWalletNamespaceForCurrentChain(
                                    args.params.requiredNamespaces));
                          },
                          onReject: () async {
                            await web3Wallet!.rejectSession(
                              id: args.id,
                              reason: Errors.getSdkError(
                                Errors.USER_REJECTED,
                              ),
                            );
                          },
                        ),
                        backgroundColor: Colors.white);
                    return networkSwitchCompleter.future;
                  },
                  onReject: () {},
                  connectingOrgin: args.params.proposer.metadata.url,
                  chainId: network.chainId.toString()),
              backgroundColor: Colors.white);
        }
      }
    }
  }

  void _onPairingInvalid(PairingInvalidEvent? args) {}

  Network? getNetworkFromRequiredChain(String chainIdInEIP) {
    try {
      return i_core.Core.networks.firstWhere((Network network) =>
          "${network.nameSpace}:${network.chainId}" == chainIdInEIP);
    } catch (e) {
      return null;
    }
  }

  void _onPairingCreate(PairingEvent? args) {}

  void _onSessionConnect(SessionConnect? args) {
    if (args != null) {
      List<dynamic> existingSessions =
          jsonDecode(preference.get("wallet_connect_v2_session") ?? "[]");
      existingSessions.add(args.session.toJson());
      preference.put("wallet_connect_v2_session", jsonEncode(existingSessions));
    }
  }

  List<dynamic> getSessions() {
    return jsonDecode(preference.get("wallet_connect_v2_session") ?? "[]");
  }

  bool isSessionExist(String topicId) {
    bool exist = false;
    getSessions().forEach((session) {
      if (session["topic"] == topicId) {
        exist = true;
      }
      log(jsonEncode(session));
    });
    return exist;
  }

  loadExistingSessions() {
    getSessions().forEach((session) {
      sessions.value.add(web3Wallet!.sessions.fromJson(session));
    });
  }

  emitAccountChanged(String address, EthPrivateKey privateKey) {
    this.address = address;
    this.privateKey = privateKey;
    getSessions().forEach((session) {
      web3Wallet!.emitSessionEvent(
          topic: session["topic"],
          chainId: "${getCurrentNamespace()}:${getCurrentChainId()}",
          event: SessionEventParams(
              name: "accountsChanged",
              data:
                  "${getCurrentNamespace()}:${getCurrentChainId()}:$address"));
    });
  }

  emitChainChanged(String chainId, String nameSpace) {
    this.chainId = chainId;
    this.nameSpace = nameSpace;
    initHandlers(nameSpace, chainId);
    getSessions().forEach((session) {
      web3Wallet!.emitSessionEvent(
          topic: session["topic"],
          chainId: "$nameSpace:$chainId",
          event: SessionEventParams(
              name: "chainChanged", data: "$nameSpace:$chainId:$address"));
    });
  }

  Future<void> _onAuthRequest(AuthRequest? args) async {}

  static onSendTransactionV2(
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
                  title: const Text("Reject Cofirmation"),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Are you surely want to reject this request ?",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: WalletButton(
                              textContent: "Yes, Reject",
                              onPressed: () {
                                Get.back();
                                completor.complete(true);
                              }),
                        ),
                        Expanded(
                          child: WalletButton(
                              textContent: "No",
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
  }
}
