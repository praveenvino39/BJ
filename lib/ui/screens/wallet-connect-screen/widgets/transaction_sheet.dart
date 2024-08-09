// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/providers/browser_provider/browser_provider.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

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
    var currentState = Provider.of<WalletProvider>(context, listen: false);
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
                  ? Consumer<BrowserProvider>(
                      builder: (context, value, child) => Column(
                        children: [
                          addHeight(SpacingSize.l),

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
                          addHeight(SpacingSize.m),

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
                          addHeight(SpacingSize.s),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: WalletText(
                                localizeKey: 'isRequesting',
                              )),
                          addHeight(SpacingSize.m),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                addHeight(SpacingSize.s),
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
                                addHeight(SpacingSize.s),
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
                          addHeight(SpacingSize.s),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            child: Row(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WalletText(
                                        localizeKey: 'estimateGas',
                                        fontWeight: FontWeight.bold),
                                    WalletText(
                                        localizeKey: 'siteSuggested', size: 12),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${widget.transaction["gas"] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0] : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${widget.transaction['gas'] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4) : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${getText(context, key: 'maxFee')}: ${widget.transaction["gas"] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0] : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${widget.transaction['gas'] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4) : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          addHeight(SpacingSize.s),

                          const Divider(),
                          addHeight(SpacingSize.s),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            child: Row(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WalletText(
                                        localizeKey: 'total',
                                        fontWeight: FontWeight.bold),
                                    WalletText(
                                        localizeKey: 'amountWithFee', size: 12),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${(EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether) + EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether)).toStringAsFixed(18).split(".")[0]}.${(EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether) + EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether)).toStringAsFixed(18).split(".")[1].substring(0, 4)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${getText(context, key: 'maxFee')}: ${EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4)} + ${EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          addHeight(SpacingSize.s),

                          Column(
                            children: [
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
                                      getLiveWalletProvider(context)
                                                  .nativeBalance >
                                              0
                                          ? Expanded(
                                              child: WalletButton(
                                                  localizeKey: "approve",
                                                  type: WalletButtonType.filled,
                                                  onPressed: () async {
                                                    var currentState = Provider
                                                        .of<WalletProvider>(
                                                            context,
                                                            listen: false);

                                                    var txhash = await currentState
                                                        .web3client
                                                        .sendTransaction(
                                                            currentState
                                                                .activeWallet
                                                                .wallet
                                                                .privateKey,
                                                            transaction!,
                                                            chainId: currentState
                                                                .activeNetwork
                                                                .chainId);
                                                    log("DAPP REQUST =====> $txhash");
                                                    widget.onApprove(txhash);
                                                    Navigator.of(context).pop();
                                                  }),
                                            )
                                          : const WalletText(
                                              localizeKey: 'insufficientFund',
                                              color: Colors.red),
                                    ],
                                  )),
                            ],
                          ),
                          addHeight(SpacingSize.l),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        addHeight(SpacingSize.xxxl),

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
                        addHeight(SpacingSize.s),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: WalletText(
                              localizeKey: 'isRequesting',
                            )),
                        addHeight(SpacingSize.m),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              addHeight(SpacingSize.s),
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
                              addHeight(SpacingSize.s),
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
                        addHeight(SpacingSize.s),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,
                          child: Row(
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WalletText(
                                      localizeKey: "estimateGas",
                                      fontWeight: FontWeight.bold),
                                  WalletText(
                                      localizeKey: 'siteSuggested', size: 12),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${widget.transaction["gas"] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0] : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${widget.transaction['gas'] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4) : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${getText(context, key: 'maxFee')}: ${widget.transaction["gas"] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0] : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${widget.transaction['gas'] != null ? EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"]).getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4) : gasPrice.getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        addHeight(SpacingSize.s),
                        const Divider(),
                        addHeight(SpacingSize.s),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,
                          child: Row(
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WalletText(
                                      localizeKey: 'total',
                                      fontWeight: FontWeight.bold),
                                  WalletText(
                                      localizeKey: 'amountWithFee', size: 12),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${(EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether) + EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether)).toStringAsFixed(18).split(".")[0]}.${(EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether) + EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether)).toStringAsFixed(18).split(".")[1].substring(0, 4)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${getText(context, key: 'maxFee')}: ${EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${EtherAmount.fromUnitAndValue(EtherUnit.wei, widget.transaction["value"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4)} + ${EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[0]}.${EtherAmount.fromUnitAndValue(EtherUnit.gwei, widget.transaction["gas"] ?? "0").getValueInUnit(EtherUnit.ether).toStringAsFixed(18).split(".")[1].substring(0, 4)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        addHeight(SpacingSize.l),

                        Provider.of<WalletProvider>(context).nativeBalance > 0
                            ? Column(
                                children: [
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
                                                  var currentState = Provider
                                                      .of<WalletProvider>(
                                                          context,
                                                          listen: false);

                                                  var txhash = await currentState
                                                      .web3client
                                                      .sendTransaction(
                                                          currentState
                                                              .activeWallet
                                                              .wallet
                                                              .privateKey,
                                                          transaction!,
                                                          chainId: currentState
                                                              .activeNetwork
                                                              .chainId);
                                                  log("DAPP REQUST =====> $txhash");
                                                  widget.onApprove(txhash);

                                                  Navigator.of(context).pop();
                                                }),
                                          ),
                                        ],
                                      )),
                                ],
                              )
                            : const WalletText(
                                localizeKey: 'insufficientFund',
                                color: Colors.red),
                        addHeight(SpacingSize.l),
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
