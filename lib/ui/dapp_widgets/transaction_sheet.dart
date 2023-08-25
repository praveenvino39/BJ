import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/ui/browser/model/web_view_model.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';

class TransactionSheet extends StatefulWidget {
  final Function(String) onApprove;
  final Function() onReject;
  final String connectingOrgin;
  final dynamic transaction;
  final bool fromWalletConnect;
  final String iconUrl;
  // final String messageToBeSigned;
  const TransactionSheet(
      {super.key,
      required this.onApprove,
      required this.onReject,
      required this.connectingOrgin,
      required this.transaction,
      this.fromWalletConnect = false,
      this.iconUrl = ""});

  @override
  State<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends State<TransactionSheet> {
  Transaction? transaction;
  EtherAmount gasPrice = EtherAmount.zero();

  @override
  void initState() {
    log("DAPP REQUST ${jsonEncode(widget.transaction)}");
    prepareTransaction();
    super.initState();
  }

  prepareTransaction() async {
    var currentState = getWalletLoadedState(context);

    var gasPrice = await currentState.web3client.getGasPrice();
    setState(() {
      this.gasPrice = gasPrice;
    });

    transaction = Transaction(
      gasPrice: gasPrice,
      data: widget.transaction["data"] != null
          ? Uint8List.fromList(hexToBytes(widget.transaction["data"]))
          : null,
      from: widget.transaction["from"] != null
          ? EthereumAddress.fromHex(widget.transaction["from"])
          : null,
      to: widget.transaction["to"] != null
          ? EthereumAddress.fromHex(widget.transaction["to"])
          : null,
      value: widget.transaction["value"] != null
          ? EtherAmount.fromUnitAndValue(
              EtherUnit.wei,
              widget.transaction["value"],
            )
          : null,
      maxGas: widget.transaction["gas"] != null
          ? hexToDartInt(widget.transaction["gas"])
          : null,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: transaction != null
              ? !widget.fromWalletConnect
                  ? Consumer<WebViewModel>(
                      builder: (context, value, child) => Column(
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: CachedNetworkImage(
                              imageUrl: value.favicon?.url.toString() ?? "",
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
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.connectingOrgin.contains("https")
                                    ? const Icon(
                                        Icons.lock,
                                        size: 16,
                                      )
                                    : const SizedBox(),
                                Text(
                                  widget.connectingOrgin
                                      .replaceAll("https://", "")
                                      .replaceAll("http://", ""),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text("is requesting a transaction")),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(2)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "CONTRACT INTERACTION",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            widget.transaction["to"].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    )),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          transaction?.data != null
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: kPrimaryColor.withAlpha(30),
                                      borderRadius: BorderRadius.circular(5)),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 16, right: 16, left: 16),
                                        child: Text(
                                          "Hex Data:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 16, left: 16, right: 16),
                                        child: Text(
                                          bytesToHex(transaction!.data!),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          // const Spacer(),
                          const Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Estimated gas fee",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Site suggested",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${widget.transaction["gas"] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0] : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${widget.transaction['gas'] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4) : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]} ${getWalletLoadedState(context).currentNetwork.symbol}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Max fee: ${widget.transaction["gas"] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0] : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${widget.transaction['gas'] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4) : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Total",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Amount + gas fee",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${(EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether) + EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether)).toStringAsFixed(18).split(".")[0]}.${(EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether) + EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether)).toStringAsFixed(18).split(".")[1].substring(0, 4)} ${getWalletLoadedState(context).currentNetwork.symbol}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Max fee: ${EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4)} + ${EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4)} ${getWalletLoadedState(context).currentNetwork.symbol}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          BlocConsumer<WalletCubit, WalletState>(
                            listener: (context, state) {},
                            builder: (context, state) {
                              return state is WalletLoaded
                                  ? state.balanceInNative > 0
                                      ? Column(
                                          children: [
                                            // Text("Warning: ${state.wallet.privateKey.address.hex.toLowerCase() != transaction?.from.toString() ? "You're sending transaction from different account" : ""}"),
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
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }),
                                                    ),
                                                    Expanded(
                                                      child: WalletButton(
                                                          textContent:
                                                              "Approve",
                                                          type: WalletButtonType
                                                              .filled,
                                                          onPressed: () async {
                                                            var currentState =
                                                                getWalletLoadedState(
                                                                    context);
                                                            // widget.transaction.gasPrice =

                                                            var txhash = await currentState
                                                                .web3client
                                                                .sendTransaction(
                                                                    currentState
                                                                        .wallet
                                                                        .privateKey,
                                                                    transaction!,
                                                                    chainId: currentState
                                                                        .currentNetwork
                                                                        .chainId);
                                                            log("DAPP REQUST =====> $txhash");
                                                            widget.onApprove(
                                                                txhash);
                                                            // widget.onApprove("signature");
                                                            // String.fromCharCodes(
                                                            //     hexToBytes(widget.messageToBeSigned));
                                                            // widget.onApprove([
                                                            //   getWalletLoadedState(context)(context)
                                                            //       .wallet
                                                            //       .privateKey
                                                            //       .address
                                                            //       .hex
                                                            // ]);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }),
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        )
                                      : Text(
                                          AppLocalizations.of(context)!
                                              .insufficientFund,
                                          style: const TextStyle(
                                              color: Colors.red))
                                  : const SizedBox();
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        const SizedBox(
                          height: 70,
                        ),
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: CachedNetworkImage(
                            imageUrl: widget.iconUrl,
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
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widget.connectingOrgin.contains("https")
                                  ? const Icon(
                                      Icons.lock,
                                      size: 16,
                                    )
                                  : const SizedBox(),
                              Text(
                                widget.connectingOrgin
                                    .replaceAll("https://", "")
                                    .replaceAll("http://", ""),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text("is requesting a transaction")),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(2)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "CONTRACT INTERACTION",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(widget.transaction["to"].toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: kPrimaryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(5)),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 16, right: 16, left: 16),
                                child: Text(
                                  "Hex Data:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, left: 16, right: 16),
                                child: Text(
                                  bytesToHex(transaction?.data ?? []),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const Spacer(),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Estimated gas fee",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Site suggested",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${widget.transaction["gas"] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0] : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${widget.transaction['gas'] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4) : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]} ${getWalletLoadedState(context).currentNetwork.symbol}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Max fee: ${widget.transaction["gas"] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0] : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${widget.transaction['gas'] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4) : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Total",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Amount + gas fee",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${(EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether) + EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether)).toStringAsFixed(18).split(".")[0]}.${(EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether) + EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether)).toStringAsFixed(18).split(".")[1].substring(0, 4)} ${getWalletLoadedState(context).currentNetwork.symbol}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Max fee: ${EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4)} + ${EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4)} ${getWalletLoadedState(context).currentNetwork.symbol}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        BlocConsumer<WalletCubit, WalletState>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            return state is WalletLoaded
                                ? state.balanceInNative > 0
                                    ? Column(
                                        children: [
                                          // Text("Warning: ${state.wallet.privateKey.address.hex.toLowerCase() != transaction?.from.toString() ? "You're sending transaction from different account" : ""}"),
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
                                                          Navigator.of(context)
                                                              .pop();
                                                        }),
                                                  ),
                                                  Expanded(
                                                    child: WalletButton(
                                                        textContent: "Approve",
                                                        type: WalletButtonType
                                                            .filled,
                                                        onPressed: () async {
                                                          var currentState =
                                                              getWalletLoadedState(
                                                                  context);
                                                          // widget.transaction.gasPrice =

                                                          var txhash = await currentState
                                                              .web3client
                                                              .sendTransaction(
                                                                  currentState
                                                                      .wallet
                                                                      .privateKey,
                                                                  transaction!,
                                                                  chainId: currentState
                                                                      .currentNetwork
                                                                      .chainId);
                                                          log("DAPP REQUST =====> $txhash");
                                                          widget.onApprove(
                                                              txhash);
                                                          // widget.onApprove("signature");
                                                          // String.fromCharCodes(
                                                          //     hexToBytes(widget.messageToBeSigned));
                                                          // widget.onApprove([
                                                          //   getWalletLoadedState(context)(context)
                                                          //       .wallet
                                                          //       .privateKey
                                                          //       .address
                                                          //       .hex
                                                          // ]);
                                                          Navigator.of(context)
                                                              .pop();
                                                        }),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!
                                            .insufficientFund,
                                        style:
                                            const TextStyle(color: Colors.red))
                                : const SizedBox();
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    )
              : const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                ),
        ),
      ),
    );
  }
}
