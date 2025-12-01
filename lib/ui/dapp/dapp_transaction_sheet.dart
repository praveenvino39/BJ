import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/ui/shared/skeleton_loader.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class DappTransactionSheet extends StatefulWidget {
  final String dapp;
  final Network network;
  final String from;
  final String to;
  final String value;
  final int requestId;
  final String topic;
  String? gas;

  String? data;
  final Function() onApprove;
  final Function() onReject;
  DappTransactionSheet({
    super.key,
    required this.dapp,
    required this.network,
    required this.from,
    required this.to,
    required this.value,
    required this.requestId,
    required this.topic,
    required this.onApprove,
    required this.onReject,
    this.data,
    this.gas,
  });

  @override
  State<DappTransactionSheet> createState() => _DappTransactionSheetState();
}

class _DappTransactionSheetState extends State<DappTransactionSheet> {
  String networkFee = "";

  @override
  void initState() {
    calculateFee();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      calculateFee();
    });
    super.initState();
  }

  void calculateFee() async {
    final tempWeb3Client = Web3Client(widget.network.url, Client());
    final basePriceInNative = await tempWeb3Client.getGasPrice();
    BigInt gasLimit = BigInt.zero;
    if (widget.gas != null) {
      gasLimit = BigInt.parse(widget.gas!);
    } else {
      gasLimit = await tempWeb3Client.estimateGas(
        data: widget.data != null ? hexToBytes(widget.data!) : null,
        to: EthereumAddress.fromHex(widget.to),
        value: EtherAmount.fromBigInt(EtherUnit.wei, hexToInt(widget.value)),
        sender: EthereumAddress.fromHex(widget.from),
      );
    }

    if (!mounted) return;
    setState(() {
      networkFee = EtherAmount.fromBigInt(
        EtherUnit.wei,
        (BigInt.from(basePriceInNative.getValueInUnit(EtherUnit.wei)) *
            gasLimit),
      ).getValueInUnit(EtherUnit.ether).toStringAsFixed(9);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          color: Colors.white,
        ),
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              addHeight(SpacingSize.xxl),
              Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                  const Spacer(),
                  const WalletText(
                    localizeKey: 'Transaction Request',
                    size: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  const IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.close,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
              addHeight(SpacingSize.m),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const WalletText(
                          localizeKey: 'From',
                          size: 16,
                        ),
                        const Spacer(),
                        WalletText(
                          localizeKey: showEllipse(widget.from),
                          size: 16,
                        ),
                      ],
                    ),
                    addHeight(SpacingSize.s),
                    Row(
                      children: [
                        const WalletText(
                          localizeKey: 'To',
                          size: 16,
                        ),
                        const Spacer(),
                        WalletText(
                          localizeKey: showEllipse(widget.to),
                          size: 16,
                        ),
                      ],
                    ),
                    addHeight(SpacingSize.s),
                    Row(
                      children: [
                        const WalletText(
                          localizeKey: 'Value',
                          size: 16,
                        ),
                        const Spacer(),
                        WalletText(
                          localizeKey: EtherAmount.fromInt(
                            EtherUnit.wei,
                            hexToDartInt(widget.value),
                          ).getValueInUnit(EtherUnit.ether).toStringAsFixed(12),
                          size: 16,
                        ),
                      ],
                    ),
                    addHeight(SpacingSize.s),
                    if (widget.gas != null) ...[
                      Row(
                        children: [
                          const WalletText(
                            localizeKey: 'Gas',
                            size: 16,
                          ),
                          const Spacer(),
                          WalletText(
                            localizeKey: EtherAmount.fromInt(
                              EtherUnit.gwei,
                              hexToDartInt(widget.gas!),
                            )
                                .getValueInUnit(EtherUnit.ether)
                                .toStringAsFixed(6),
                            size: 16,
                          ),
                        ],
                      ),
                      addHeight(SpacingSize.s),
                    ]
                  ],
                ),
              ),
              addHeight(SpacingSize.s),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const WalletText(
                          localizeKey: 'Network Fee',
                          size: 16,
                        ),
                        addWidth(SpacingSize.xs),
                        const Icon(
                          Icons.info,
                          color: Colors.black87,
                          size: 20,
                        ),
                        const Spacer(),
                        networkFee.isEmpty
                            ? SkeletonLoader(
                                height: 20,
                                width: 100,
                                duration: const Duration(seconds: 1),
                              )
                            : WalletText(
                                localizeKey: networkFee,
                                size: 16,
                              )
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
                localizeKey: 'Approve Transaction',
                onPressed: networkFee.isEmpty ? null : widget.onApprove,
              ),
              addHeight(SpacingSize.m),
            ],
          ),
        ),
      ),
    );
  }
}
