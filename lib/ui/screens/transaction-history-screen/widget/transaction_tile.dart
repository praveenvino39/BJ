import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_transaction_response.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/block-web-view-screen/block_web_view.dart';
import 'package:wallet_cryptomask/ui/shared/avatar_widget.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class TransactionTile extends StatefulWidget {
  final DateTime date;
  final MoralisTransaction data;
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
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                addHeight(SpacingSize.xl),
                Expanded(
                  child: widget.data.from.toLowerCase() ==
                          getWalletProvider(context)
                              .activeWallet
                              .wallet
                              .privateKey
                              .address
                              .hex
                              .toLowerCase()
                      ? Text(
                          "${getText(context, key: 'send')} ${getWalletProvider(context).activeNetwork.symbol}",
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(
                          "${getText(context, key: 'receive')} ${getWalletProvider(context).activeNetwork.symbol}",
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          addHeight(SpacingSize.m),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WalletText(localizeKey: 'status', size: 12),
                                  WalletText(
                                      localizeKey: 'confirmed',
                                      color: Colors.green,
                                      size: 12,
                                      fontWeight: FontWeight.w700)
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const WalletText(
                                          localizeKey: 'copyTxId', size: 12),
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
                          addHeight(SpacingSize.s),
                          addHeight(SpacingSize.xs),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              WalletText(localizeKey: 'from', size: 12),
                              WalletText(localizeKey: 'to', size: 12)
                            ],
                          ),
                          addHeight(SpacingSize.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  AvatarWidget(
                                      radius: 30, address: widget.data.from),
                                  addWidth(SpacingSize.xs),
                                  Text(showEllipse(widget.data.from),
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  AvatarWidget(
                                      radius: 30, address: widget.data.to),
                                  addWidth(SpacingSize.xs),
                                  Text(showEllipse(widget.data.to),
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                          addHeight(SpacingSize.s),
                          addHeight(SpacingSize.xs),
                          WalletButton(
                              textSize: 12,
                              localizeKey: 'viewOnExplorer',
                              onPressed: () {
                                context.push(
                                  () => BlockWebView(
                                      url: getWalletProvider(context)
                                              .activeNetwork
                                              .transactionViewUrl +
                                          widget.data.hash,
                                      title:
                                          getText(context, key: 'transaction')),
                                );
                              }),
                          addHeight(SpacingSize.m),
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
            addHeight(SpacingSize.s),
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
                            getWalletProvider(context)
                                .activeWallet
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
                addWidth(SpacingSize.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.data.from.toLowerCase() ==
                              getWalletProvider(context)
                                  .activeWallet
                                  .wallet
                                  .privateKey
                                  .address
                                  .hex
                                  .toLowerCase()
                          ? Text(
                              "${getText(context, key: 'send')} ${getWalletProvider(context).activeNetwork.symbol}",
                              style: const TextStyle(fontSize: 16),
                            )
                          : Text(
                              "${getText(context, key: 'receive')} ${getWalletProvider(context).activeNetwork.symbol}",
                              style: const TextStyle(fontSize: 16),
                            ),
                      const WalletText(
                          localizeKey: 'confirmed',
                          color: Colors.green,
                          size: 12,
                          fontWeight: FontWeight.w700)
                    ],
                  ),
                ),
                Text(
                    "${(Decimal.parse(widget.data.value).toDouble() / pow(10, 18)).toStringAsFixed(5)} ${getWalletProvider(context).activeNetwork.symbol}"),
              ],
            ),
            addHeight(SpacingSize.s),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Colors.grey.withAlpha(60),
            ),
            addHeight(SpacingSize.m),
          ],
        ),
      ),
    );
  }
}
