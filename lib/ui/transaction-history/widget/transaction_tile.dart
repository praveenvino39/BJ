import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/core/remote/response-model/transaction_log_result.dart';
import 'package:wallet/ui/block-web-view/block_web_view.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:wallet/utils.dart';

class TransactionTile extends StatefulWidget {
  final DateTime date;
  final TransactionResult data;
  const TransactionTile({Key? key, required this.date, required this.data})
      : super(key: key);

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  Token? selectedToken;


  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Expanded(
                      child: widget.data.from.toLowerCase() ==
                              (state as WalletLoaded)
                                  .wallet
                                  .privateKey
                                  .address
                                  .hex
                                  .toLowerCase()
                          ? Text(
                              "Sent ${state.currentNetwork.symbol}",
                              style: const TextStyle(fontSize: 16),
                            )
                          : Text(
                              "Receive ${state.currentNetwork.symbol}",
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.close))
                  ],
                ),
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                contentPadding: const EdgeInsets.all(0),
                content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SizedBox(
                      // height: MediaQuery.of(context).size.height / 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Status",
                                          style: TextStyle(fontSize: 12)),
                                      widget.data.isError == "0"
                                          ? const Text(
                                              "Confirmed",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                            )
                                          : const Text(
                                              "Failed",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                            )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text("Copy Tranaction ID",
                                              style: TextStyle(fontSize: 12)),
                                          IconButton(
                                              splashRadius: 15,
                                              onPressed: () {
                                                copyAddressToClipBoard(
                                                    widget.data.hash, context);
                                              },
                                              icon: const Icon(
                                                Icons.copy,
                                                size: 14,
                                              ))
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("From", style: TextStyle(fontSize: 12)),
                                  Text("To", style: TextStyle(fontSize: 12))
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      AvatarWidget(
                                          radius: 30,
                                          address: widget.data.from),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(showEllipse(widget.data.from),
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1, color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.grey,
                                      )),
                                  Row(
                                    children: [
                                      AvatarWidget(
                                          radius: 30, address: widget.data.to),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(showEllipse(widget.data.to),
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              WalletButton(
                                  textSize: 12,
                                  textContent: "View on explorer",
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return BlockWebView(
                                          url: state.currentNetwork
                                                  .transactionViewUrl +
                                              widget.data.hash,
                                          title: "Transaction");
                                    }));
                                  }),
                              const SizedBox(
                                height: 20,
                              )
                            ]),
                      ),
                    )),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${DateFormat.yMMMMd().format(widget.date)} at ${widget.date.hour}:${widget.date.minute}"),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1, color: kPrimaryColor)),
                      child: Icon(
                        widget.data.from.toLowerCase() ==
                                (state as WalletLoaded)
                                    .wallet
                                    .privateKey
                                    .address
                                    .hex
                                    .toLowerCase()
                            ? Icons.call_made
                            : Icons.call_received,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.data.from.toLowerCase() ==
                                  (state)
                                      .wallet
                                      .privateKey
                                      .address
                                      .hex
                                      .toLowerCase()
                              ? Text(
                                  "Sent ${state.currentNetwork.symbol}",
                                  style: const TextStyle(fontSize: 16),
                                )
                              : Text(
                                  "Receive ${state.currentNetwork.symbol}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                          widget.data.isError == "0"
                              ? const Text(
                                  "Confirmed",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                )
                              : const Text(
                                  "Failed",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                )
                        ],
                      ),
                    ),
                    Text(
                        "${(Decimal.parse(widget.data.value).toDouble() / pow(10, 18)).toStringAsFixed(5)} ${state.currentNetwork.symbol}"),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Colors.grey.withAlpha(60),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
