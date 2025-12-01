import 'dart:convert';

import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/ui/dapp/json_viewer.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class SignSheet extends StatelessWidget {
  final String method;
  final String message;
  final String address;
  final Network network;
  final String dapp;
  final int requestId;
  final Function() onSign;
  final Function() onCancel;
  const SignSheet(
      {super.key,
      required this.method,
      required this.message,
      required this.address,
      required this.network,
      required this.dapp,
      required this.requestId,
      required this.onSign,
      required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final displayMessage = isHexString(message)
        ? String.fromCharCodes(hexToBytes(message))
        : message;
    dynamic data =
        method == "eth_signTypedData_v4" ? jsonDecode(message) : null;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            addHeight(SpacingSize.xxl),
            Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
                const Spacer(),
                const WalletText(
                  localizeKey: 'Signature Request',
                  size: 18,
                  fontWeight: FontWeight.bold,
                ),
                const Spacer(),
                IconButton(
                    onPressed: onCancel,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.transparent,
                    )),
              ],
            ),
            addHeight(SpacingSize.s),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const WalletText(
                        localizeKey: 'Asset',
                        size: 16,
                      ),
                      const Spacer(),
                      WalletText(
                        localizeKey:
                            "${network.networkName} (${network.symbol})",
                        size: 16,
                      ),
                    ],
                  ),
                  addHeight(SpacingSize.s),
                  Row(
                    children: [
                      const WalletText(
                        localizeKey: 'Account',
                        size: 16,
                      ),
                      const Spacer(),
                      WalletText(
                        localizeKey: showEllipse(address),
                        size: 16,
                      ),
                    ],
                  ),
                  addHeight(SpacingSize.s),
                  Row(
                    children: [
                      const WalletText(
                        localizeKey: 'Network',
                        size: 16,
                      ),
                      const Spacer(),
                      WalletText(
                        localizeKey: network.networkName,
                        size: 16,
                      ),
                    ],
                  ),
                  addHeight(SpacingSize.s),
                  Row(
                    children: [
                      const WalletText(
                        localizeKey: 'DApp',
                        size: 16,
                      ),
                      const Spacer(),
                      WalletText(
                        localizeKey: Uri.parse(dapp).host,
                        size: 16,
                      ),
                    ],
                  ),
                  addHeight(SpacingSize.s),
                  method == "eth_signTypedData_v4" && data != null
                      ? SizedBox(
                          height: 300,
                          child: JsonViewer(data),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: WalletText(
                                localizeKey: displayMessage,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const Spacer(),
            WalletButton(
              textSize: 16,
              padding: const EdgeInsets.symmetric(vertical: 12),
              type: WalletButtonType.filled,
              localizeKey: 'Sign Message',
              onPressed: onSign,
            ),
            addHeight(SpacingSize.m),
          ],
        ),
      ),
    );
  }
}
