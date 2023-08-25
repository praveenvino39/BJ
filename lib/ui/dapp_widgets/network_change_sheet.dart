import 'package:cached_network_image/cached_network_image.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/core.dart';
import 'package:wallet/core/model/network_model.dart';
import 'package:wallet/ui/shared/chain_change_sheet.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkChangeSheet extends StatefulWidget {
  final Function(dynamic) onApprove;
  final Function() onReject;
  final String connectingOrgin;
  final String chainId;
  final String imageUrl;
  // final String messageToBeSigned;
  const NetworkChangeSheet(
      {super.key,
      required this.onApprove,
      required this.onReject,
      required this.connectingOrgin,
      required this.chainId,
      required this.imageUrl});

  @override
  State<NetworkChangeSheet> createState() => _NetworkChangeSheetState();
}

class _NetworkChangeSheetState extends State<NetworkChangeSheet> {
  Network? requestNetwork;

  @override
  void initState() {
    try {
      requestNetwork = Core.networks.firstWhere(
        (network) {
          return intToHex(network.chainId) ==
              intToHex(int.parse(widget.chainId));
        },
      );
      setState(() {});
    } catch (e) {
      widget.onReject();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        state as WalletLoaded;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(10)
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
                        fit: BoxFit.contain,
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
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NetworkDot(color: state.currentNetwork.dotColor),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            state.currentNetwork.networkName
                                .replaceAll("_", " "),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "This site would like to switch the network",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "This will switch the selected network within EgonWallet to a proviously added network.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: 1, color: Colors.black45.withAlpha(40))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NetworkDot(
                          color: requestNetwork!.dotColor,
                          radius: 12,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(requestNetwork!.networkName)
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
                                  context
                                      .read<WalletCubit>()
                                      .changeNetwork(requestNetwork!);
                                  widget.onApprove(null);
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
        );
      },
    );
  }
}
