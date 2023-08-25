// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:wallet/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectSheet extends StatefulWidget {
  // final BrowserView browser;
  final Function(List<String>) onApprove;
  final Function() onReject;
  final String connectingOrgin;
  final String imageUrl;
  const ConnectSheet(
      {super.key,
      required this.onApprove,
      required this.onReject,
      required this.connectingOrgin,
      required this.imageUrl});

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
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        state as WalletLoaded;
        return Container(
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
                    const SizedBox(
                      height: 20,
                    ),
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
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          state.currentNetwork.networkName,
                          style: const TextStyle(fontSize: 14),
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Connect to this site?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "By clicking connect, you allow this dapp to view your public address. This is an important security step to protect your data from potential phishing risks.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                              width: 1, color: Colors.grey.withAlpha(60))),
                      child: Row(
                        children: [
                          AvatarWidget(
                            radius: 40,
                            address: state.wallet.privateKey.address.hex,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {},
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${getAccountName(state)} (${showEllipse(state.wallet.privateKey.address.hex)})",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                      "${AppLocalizations.of(context)!.balance}: ${state.balanceInNative} ${state.currentNetwork.currency}"),
                                ],
                              ),
                            ),
                          ),
                          // const Icon(Icons.arrow_drop_down)
                        ],
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10),
                    //   color: kPrimaryColor.withAlpha(30),
                    //   child: Column(
                    //     children: [
                    //       const SizedBox(
                    //         height: 10,
                    //       ),
                    //       const Text("Connecting account"),
                    //       const SizedBox(
                    //         height: 10,
                    //       ),
                    //       Text(
                    //         getWalletLoadedState(context).wallet.privateKey.address.hex,
                    //         style: const TextStyle(
                    //             fontSize: 14, fontWeight: FontWeight.bold),
                    //       ),
                    //       const SizedBox(
                    //         height: 10,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const Spacer(),
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
                                    Box box =
                                        await Hive.openBox("user_preference");
                                    List<dynamic> connectedSites = box.get(
                                        "connected-sites-${getWalletLoadedState(context).wallet.privateKey.address.hex}",
                                        defaultValue: []);
                                    connectedSites.add(widget.connectingOrgin);
                                    box.put(
                                        "connected-sites-${getWalletLoadedState(context).wallet.privateKey.address.hex}",
                                        connectedSites);
                                    widget.onApprove([
                                      getWalletLoadedState(context)
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
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
