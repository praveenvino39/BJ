// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class ConnectSheetNew extends StatefulWidget {
  bool isScam = false;
  String applicationName;
  final Function(List<String>) onApprove;
  List<Network>? requestedNetworks;
  final Function() onReject;
  final String connectingOrgin;
  final String imageUrl;
  ConnectSheetNew(
      {super.key,
      required this.onApprove,
      required this.onReject,
      required this.connectingOrgin,
      required this.imageUrl,
      required this.applicationName,
      this.requestedNetworks,
      this.isScam = false});

  @override
  State<ConnectSheetNew> createState() => _ConnectSheetNewState();
}

class _ConnectSheetNewState extends State<ConnectSheetNew>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
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
                      imageUrl: widget.imageUrl,
                      errorWidget: (context, url, error) => const CircleAvatar(
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
                ),
                addHeight(SpacingSize.xs),
                WalletText(
                  fontWeight: FontWeight.bold,
                  size: 18,
                  align: TextAlign.center,
                  localizeKey:
                      "${widget.applicationName} wants to connect to you wallet",
                ),
                addHeight(SpacingSize.xxs),
                const WalletText(
                  size: 12,
                  align: TextAlign.center,
                  localizeKey: "https://example.com",
                ),
                addHeight(SpacingSize.xs),
                if (widget.isScam)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      WalletText(
                        size: 12,
                        color: Colors.red,
                        align: TextAlign.center,
                        localizeKey: "Security Risk",
                      ),
                    ],
                  ),
                addHeight(SpacingSize.m),
                ...[
                  ...widget.requestedNetworks!
                      .map((network) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.grey.shade200,
                            ),
                            child: ListTile(
                              title: WalletText(
                                localizeKey: network.networkName,
                                fontWeight: FontWeight.bold,
                              ),
                              subtitle: Text(
                                showEllipse(
                                  getLiveWalletProvider(context)
                                      .getCurrentAccountAddress(),
                                ),
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.grey.shade100,
                                ),
                                child: Center(
                                  child: CachedNetworkImage(
                                    width: 30,
                                    height: 30,
                                    imageUrl: network.logo,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ],
                addHeight(SpacingSize.m),
                Row(
                  children: [
                    const Icon(Icons.outbound),
                    addWidth(SpacingSize.xxs),
                    const Expanded(
                      child: WalletText(
                        localizeKey: "View your wallet balance and activity",
                        size: 12,
                      ),
                    ),
                  ],
                ),
                addHeight(SpacingSize.xxs),
                Row(
                  children: [
                    const Icon(Icons.check),
                    addWidth(SpacingSize.xxs),
                    const Expanded(
                      child: WalletText(
                        localizeKey: "Request approval for transactions",
                        size: 12,
                      ),
                    ),
                  ],
                ),
                addHeight(SpacingSize.l),
                if (widget.isScam)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red.shade300),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.white70,
                        ),
                        addWidth(SpacingSize.xs),
                        const Expanded(
                          child: WalletText(
                            color: Colors.white,
                            localizeKey:
                                "This domain is flagged as unsafe by multiple security providers. Proceed with caution.",
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                addHeight(SpacingSize.m),
                SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: WalletButton(
                              localizeKey: "reject",
                              onPressed: () async {
                                widget.onReject();
                                Navigator.of(context).pop();
                              }),
                        ),
                        Expanded(
                          child: WalletButton(
                              localizeKey: "approve",
                              type: WalletButtonType.filled,
                              onPressed: () async {
                                Box box = await Hive.openBox("user_preference");
                                List<dynamic> connectedSites = box
                                    .get("connected-sites", defaultValue: []);
                                connectedSites.add(widget.connectingOrgin);
                                box.put("connected-sites", connectedSites);
                                widget.onApprove([
                                  Provider.of<WalletProvider>(context,
                                          listen: false)
                                      .activeWallet
                                      .wallet
                                      .privateKey
                                      .address
                                      .hex
                                ]);
                                Navigator.of(context).pop();
                              }),
                        ),
                      ],
                    )),
                addHeight(SpacingSize.l),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
