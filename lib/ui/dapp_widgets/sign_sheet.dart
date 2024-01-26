import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:ethers/crypto/formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/shared/chain_change_sheet.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/utils.dart';

class SignSheet extends StatefulWidget {
  final Function(String) onApprove;
  final Function() onReject;
  final String connectingOrgin;
  final String messageToBeSigned;
  final Favicon? favicon;
  const SignSheet(
      {super.key,
      required this.onApprove,
      required this.onReject,
      required this.messageToBeSigned,
      required this.connectingOrgin,
      this.favicon});

  @override
  State<SignSheet> createState() => _SignSheetState();
}

class _SignSheetState extends State<SignSheet> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            widget.favicon != null
                ? Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(100)),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl: widget.favicon!.url.toString(),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          // radius: 35,
                          child: Center(
                            child: Icon(
                              Icons.public,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    // radius: 35,
                    child: Center(
                      child: Icon(
                        Icons.public,
                        size: 40,
                      ),
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.connectingOrgin.contains("https")
                      ? const Icon(
                          Icons.lock,
                          size: 16,
                        )
                      : const SizedBox(),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.connectingOrgin
                        .replaceAll("https://", "")
                        .replaceAll("http://", ""),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border:
                      Border.all(width: 1, color: Colors.grey.withAlpha(60))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarWidget(
                    radius: 40,
                    address: getWalletLoadedState(context)
                        .wallet
                        .privateKey
                        .address
                        .hex,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${getAccountName(getWalletLoadedState(context))} (${showEllipse(getWalletLoadedState(context).wallet.privateKey.address.hex)})",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // const Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NetworkDot(
                        color: getWalletLoadedState(context)
                            .currentNetwork
                            .dotColor),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      getWalletLoadedState(context)
                          .currentNetwork
                          .networkName
                          .replaceAll("_", " "),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                )),
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
                    height: 150,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            isHexString(widget.messageToBeSigned)
                                ? String.fromCharCodes(
                                    hexToBytes(widget.messageToBeSigned))
                                : widget.messageToBeSigned,
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
            const SizedBox(
              height: 20,
            ),
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
                            String signature = EthSigUtil.signPersonalMessage(
                                message: isHexString(widget.messageToBeSigned)
                                    ? hexToBytes(widget.messageToBeSigned)
                                    : Uint8List.fromList(
                                        utf8.encode(widget.messageToBeSigned)),
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
      ),
    );
  }
}
