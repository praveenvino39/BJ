// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/avatar_widget.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class ConnectSheet extends StatefulWidget {
  final Function(List<String>) onApprove;
  List<Network>? requestedNetworks;
  final Function() onReject;
  final String connectingOrgin;
  final String imageUrl;
  ConnectSheet(
      {super.key,
      required this.onApprove,
      required this.onReject,
      required this.connectingOrgin,
      required this.imageUrl,
      this.requestedNetworks});

  @override
  State<ConnectSheet> createState() => _ConnectSheetState();
}

class _ConnectSheetState extends State<ConnectSheet>
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
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                addHeight(SpacingSize.m),
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
                addHeight(SpacingSize.s),
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
                      addWidth(SpacingSize.xs),
                      Text(
                        widget.connectingOrgin
                            .replaceAll("https://", "")
                            .replaceAll("http://", ""),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      addWidth(SpacingSize.xs),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      Provider.of<WalletProvider>(context)
                          .activeNetwork
                          .networkName,
                      style: const TextStyle(fontSize: 14),
                    )),
                addHeight(SpacingSize.s),
                addHeight(SpacingSize.xs),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: WalletText(
                        localizeKey: 'connectToThis',
                        size: 16,
                        fontWeight: FontWeight.bold)),
                addHeight(SpacingSize.m),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: WalletText(
                    localizeKey: 'byClicking',
                    align: TextAlign.center,
                  ),
                ),
                addHeight(SpacingSize.s),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          width: 1, color: Colors.grey.withAlpha(60))),
                  child: Row(
                    children: [
                      AvatarWidget(
                        radius: 40,
                        address: Provider.of<WalletProvider>(context)
                            .activeWallet
                            .wallet
                            .privateKey
                            .address
                            .hex,
                      ),
                      addWidth(SpacingSize.s),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${Provider.of<WalletProvider>(context).getAccountName()} (${showEllipse(Provider.of<WalletProvider>(context).activeWallet.wallet.privateKey.address.hex)})",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                  "${getText(context, key: 'balance')}: ${Provider.of<WalletProvider>(context).activeWallet.balance} ${Provider.of<WalletProvider>(context).activeNetwork.currency}"),
                            ],
                          ),
                        ),
                      ),
                      // const Icon(Icons.arrow_drop_down)
                    ],
                  ),
                ),
                addHeight(SpacingSize.m),
                widget.requestedNetworks != null
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                                width: 1, color: Colors.grey.withAlpha(60))),
                        child: WalletText(
                          localizeKey:
                              "${widget.requestedNetworks?.length} ${getText(context, key: 'chainsAreRequried')}",
                        ),
                      )
                    : const SizedBox(),
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
