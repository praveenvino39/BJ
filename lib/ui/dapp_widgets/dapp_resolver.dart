import 'dart:async';

import 'package:eth_sig_util/constant/typed_data_version.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:wallet/core/core.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/ui/browser/model/request.dart';
import 'package:wallet/ui/browser/model/web_view_model.dart';
import 'package:wallet/ui/dapp_widgets/connect_sheet.dart';
import 'package:wallet/ui/dapp_widgets/network_change_sheet.dart';
import 'package:wallet/ui/dapp_widgets/sign_sheet.dart';
import 'package:wallet/ui/dapp_widgets/sign_typed_data_sheet.dart';
import 'package:wallet/ui/dapp_widgets/transaction_sheet.dart';

const String kEthRequestAccounts = "eth_requestAccounts";
const String kEthAccounts = "eth_accounts";
const String kSendTransaction = "eth_sendTransaction";
const String kPersonalSign = "personal_sign";
const String kEthSign = "eth_sign";
const String kEthSendTransaction = "eth_sendTransaction";
const String kWalletSwitchChain = "wallet_switchEthereumChain";
const String kSignTypedDataV4 = "eth_signTypedData_v4";
const String kSignTypedDataV3 = "eth_signTypedData_v3";
const String kSignTypedDataV1 = "eth_signTypedData";

List<String> walletMethods = [
  kEthAccounts,
  kSendTransaction,
  kEthRequestAccounts,
  kPersonalSign,
  kEthSendTransaction,
  kWalletSwitchChain,
  kSignTypedDataV4,
  kSignTypedDataV1,
  kEthSign,
  kSignTypedDataV3,
];

class DappResolver {
  Box box;
  DappResolver({required this.box});
  Future<dynamic> processRequest(requestMap,
      {required BuildContext context, WebViewModel? webViewModel}) async {
    Request request = Request.fromJson(requestMap);
    switch (request.method) {
      case kEthRequestAccounts:
        Completer completer = Completer();
        List connectedSites = box.get("connected-sites", defaultValue: []);
        if (connectedSites.contains(webViewModel!.url!.origin)) {
          // Future.delayed(const Duration(milliseconds: 200), (() {
          completer.complete(
              [getWalletLoadedState(context).wallet.privateKey.address.hex]);
          // }));
          return completer.future;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Material(
              child: ConnectSheet(
                onApprove: (addresses) {
                  completer.complete(addresses);
                },
                imageUrl: "",
                onReject: (() {
                  completer.completeError("User rejected");
                }),
                connectingOrgin: webViewModel.url!.origin,
              ),
            ),
          ),
        );
        return completer.future;

      case kEthAccounts:
        Completer completer = Completer();
        List connectedSites = box.get("connected-sites", defaultValue: []);
        if (connectedSites.contains(webViewModel!.url!.origin)) {
          completer.complete(
              [getWalletLoadedState(context).wallet.privateKey.address.hex]);
          return completer.future;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Material(
              child: ConnectSheet(
                onApprove: (addresses) {
                  completer.complete(addresses);
                },
                imageUrl: "",
                onReject: (() {
                  completer.completeError("User rejected");
                }),
                connectingOrgin: webViewModel.url!.origin,
              ),
            ),
          ),
        );
        return completer.future;
      case kPersonalSign:
        Completer completer = Completer();
        Get.dialog(
          Material(
            child: SignSheet(
              onApprove: (signature) {
                completer.complete(signature);
              },
              favicon: webViewModel!.favicon,
              onReject: (() {
                completer.completeError("User rejected");
              }),
              connectingOrgin: webViewModel.url!.origin,
              messageToBeSigned: request.params[0],
            ),
          ),
        );
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => Material(
        //       child: SignSheet(
        //         onApprove: (signature) {
        //           completer.complete(signature);
        //         },
        //         favicon: webViewModel!.favicon,
        //         onReject: (() {
        //           completer.completeError("User rejected");
        //         }),
        //         connectingOrgin: webViewModel.url!.origin,
        //         messageToBeSigned: request.params[0],
        //       ),
        //     ),
        //   ),
        // );

        return completer.future;
      case kEthSign:
        Completer completer = Completer();
        showBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => SignSheet(
                  onApprove: (signature) {
                    completer.complete(signature);
                  },
                  favicon: webViewModel!.favicon,
                  onReject: (() {
                    completer.completeError("User rejected");
                  }),
                  connectingOrgin: webViewModel.url!.origin,
                  messageToBeSigned: request.params[0],
                ));
        return completer.future;
      case kSignTypedDataV1:
        Completer completer = Completer();
        showBottomSheet(
            context: context,
            builder: (context) => SignTypedDataSheet(
                  onApprove: (signature) {
                    completer.complete(signature);
                  },
                  onReject: (() {
                    completer.completeError("User rejected");
                  }),
                  connectingOrgin: webViewModel!.url!.origin,
                  messageToBeSigned: request.params[1],
                  version: TypedDataVersion.V1,
                ));
        return completer.future;
      case kSignTypedDataV3:
        Completer completer = Completer();
        showBottomSheet(
            context: context,
            builder: (context) => SignTypedDataSheet(
                  onApprove: (signature) {
                    completer.complete(signature);
                  },
                  onReject: (() {
                    completer.completeError("User rejected");
                  }),
                  connectingOrgin: webViewModel!.url!.origin,
                  messageToBeSigned: request.params[1],
                  version: TypedDataVersion.V3,
                ));
        return completer.future;
      case kSignTypedDataV4:
        Completer completer = Completer();
        showBottomSheet(
            context: context,
            builder: (context) => SignTypedDataSheet(
                  onApprove: (signature) {
                    completer.complete(signature);
                  },
                  onReject: (() {
                    completer.completeError("User rejected");
                  }),
                  connectingOrgin: webViewModel!.url!.origin,
                  messageToBeSigned: request.params[1],
                  version: TypedDataVersion.V4,
                ));
        return completer.future;
      case kEthSendTransaction:
        Completer completer = Completer();
        var transaction = request.params[0];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Material(
              child: Scaffold(
                body: TransactionSheet(
                    fromWalletConnect: true,
                    onApprove: (signature) {
                      completer.complete(signature);
                    },
                    onReject: (() {
                      completer.completeError("User rejected");
                    }),
                    connectingOrgin: webViewModel!.url!.origin,
                    transaction: transaction),
              ),
            ),
          ),
        );
        return completer.future;
      case kWalletSwitchChain:
        Completer completer = Completer();
        try {
          final network = Core.networks.firstWhere((element) =>
              intToHex(element.chainId) ==
              intToHex(int.parse(request.params[0]["chainId"])));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: NetworkChangeSheet(
                  onApprove: (signature) {
                    Navigator.of(context).pop();
                    completer.complete(null);
                  },
                  onReject: (() {
                    completer.completeError("User rejected");
                  }),
                  imageUrl: "",
                  connectingOrgin: webViewModel!.url!.origin,
                  chainId: request.params[0]["chainId"],
                ),
              ),
            ),
          );
        } catch (e) {}
        return completer.future;

      default:
    }
  }
}
