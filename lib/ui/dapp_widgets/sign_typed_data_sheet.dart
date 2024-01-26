import 'dart:convert';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:web3dart/crypto.dart';

class SignTypedDataSheet extends StatefulWidget {
  final Function(String) onApprove;
  final Function() onReject;
  final String connectingOrgin;
  final dynamic messageToBeSigned;
  final TypedDataVersion version;
  const SignTypedDataSheet(
      {super.key,
      required this.messageToBeSigned,
      required this.onApprove,
      required this.onReject,
      required this.connectingOrgin,
      required this.version});

  @override
  State<SignTypedDataSheet> createState() => _SignTypedDataSheetState();
}

class _SignTypedDataSheetState extends State<SignTypedDataSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var encoder = const JsonEncoder.withIndent("     ");

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.connectingOrgin)),
          const SizedBox(
            height: 10,
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("is requesting personal sign")),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: kPrimaryColor.withAlpha(30)),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text("You're signing"),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          encoder.convert(
                              jsonDecode(widget.messageToBeSigned)["message"]),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
              height: 50,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: WalletButton(
                        textContent: "Reject",
                        onPressed: () async {
                          widget.onReject();
                          Navigator.of(context).pop();
                        }),
                  ),
                  Expanded(
                    child: WalletButton(
                        textContent: "Approve",
                        type: WalletButtonType.filled,
                        onPressed: () async {
                          String signature = EthSigUtil.signTypedData(
                              jsonData: widget.messageToBeSigned,
                              version: TypedDataVersion.V4,
                              privateKey: bytesToHex(
                                  getWalletLoadedState(context)
                                      .wallet
                                      .privateKey
                                      .privateKey,
                                  include0x: true));
                          widget.onApprove(signature);
                          Navigator.of(context).pop();
                          return;
                        }),
                  ),
                ],
              )),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
