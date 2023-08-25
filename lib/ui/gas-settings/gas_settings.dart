// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:wallet/ui/transaction-confirmation/transaction_confirmation.dart';
import 'package:web3dart/web3dart.dart';

class GasSettings extends StatefulWidget {
  TransactionPriority priority;
  EtherAmount estimatedGasInWei;
  EtherAmount maxFeeInWei;
  Function(double selectedPriorityPrice, double selectedMaxFee,
      TransactionPriority priority, int gasLimit) changePriority;
  Function? onAdvanceOptionClicked;
  double low;
  double medium;
  double high;
  bool showAdvance;
  int gasLimit;
  double maxPriority;
  double maxFee;
  String token;

  GasSettings(
      {Key? key,
      required this.priority,
      required this.estimatedGasInWei,
      required this.changePriority,
      this.onAdvanceOptionClicked,
      required this.low,
      required this.medium,
      this.showAdvance = false,
      required this.gasLimit,
      required this.maxPriority,
      required this.maxFee,
      required this.high,
      required this.maxFeeInWei,
      required this.token})
      : super(key: key);

  @override
  State<GasSettings> createState() => _GasSettingsState();
}

class _GasSettingsState extends State<GasSettings> {
  final TextEditingController _gasLimit = TextEditingController(text: "");
  final TextEditingController _maxPriorityFee = TextEditingController(text: "");
  final TextEditingController _maxFee = TextEditingController(text: "");
  double maxPriorityInEth = 0.0;
  double maxFeeInEth = 0.0;

  updatePriority(double priority) {
    setState(() {
      widget.estimatedGasInWei = EtherAmount.fromUnitAndValue(
          EtherUnit.wei, (priority * pow(10, 9)).toInt() * widget.gasLimit);
    });
  }

  updateMaxPriorityEth() {
    int ethValue = (widget.maxPriority * pow(10, 9)).toInt();
    widget.estimatedGasInWei =
        EtherAmount.fromUnitAndValue(EtherUnit.wei, ethValue * widget.gasLimit);
    maxPriorityInEth = EtherAmount.fromUnitAndValue(EtherUnit.wei, ethValue)
        .getValueInUnit(EtherUnit.ether);
  }

  updateMaxFeeEth() {
    int ethValue = (widget.maxFee * pow(10, 9)).toInt();
    widget.maxFeeInWei =
        EtherAmount.fromUnitAndValue(EtherUnit.wei, ethValue * widget.gasLimit);
    maxFeeInEth = EtherAmount.fromUnitAndValue(EtherUnit.wei, ethValue)
        .getValueInUnit(EtherUnit.ether);
  }

  updateGasLimit() {
    updateMaxPriorityEth();
    updateMaxFeeEth();
  }

  @override
  void initState() {
    _gasLimit.text = widget.gasLimit.toString();
    _maxPriorityFee.text = widget.maxPriority.toString();
    _maxFee.text = widget.maxFee.toString();
    updateMaxPriorityEth();
    updateMaxFeeEth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: double.infinity,
        height: double.infinity,
        child: BlocConsumer<WalletCubit, WalletState>(
          listener: (context, state) {},
          builder: (context, state) {
            (state as WalletLoaded);
            return SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                     const  SizedBox(
                        height: 20,
                        width: double.infinity,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
                          children: const [
                            Positioned(
                              left: 0,
                              child: Icon(Icons.arrow_back_ios),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                "Edit priority",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                        width: double.infinity,
                      ),
                      Text(
                          "${widget.estimatedGasInWei.getValueInUnit(EtherUnit.ether)} ETH",
                          style:const  TextStyle(
                              fontSize: 40, fontWeight: FontWeight.normal)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Max fee: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${widget.maxFeeInWei.getValueInUnit(EtherUnit.ether)} ${state.currentNetwork.currency} (\$${state.balanceInUSD})",
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                        width: double.infinity,
                      ),
                      Text(
                        widget.priority == TransactionPriority.medium
                            ? "Likely in < 30 seconds"
                            : widget.priority == TransactionPriority.low
                                ? "Maybe in 30 seconds"
                                : "Likely in 15 seconds",
                        style: TextStyle(
                            color: widget.priority == TransactionPriority.low
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                                value: TransactionPriority.low,
                                groupValue: widget.priority,
                                activeColor: kPrimaryColor,
                                onChanged: (v) {
                                  setState(() {
                                    widget.priority = v as TransactionPriority;
                                    if (widget.token ==
                                        state.currentNetwork.currency) {
                                      widget.gasLimit = 21000;
                                      _gasLimit.text = "21000";
                                    }
                                    _maxFee.text = widget.low.toString();
                                    _maxPriorityFee.text = widget.low.toString();
                                    widget.maxFee = widget.low;
                                    widget.maxPriority = widget.low;
              
                                    updatePriority(widget.low);
                                    updateGasLimit();
                                    updateMaxPriorityEth();
                                    updateMaxFeeEth();
                                  });
                                }),
                            const Expanded(child: SizedBox()),
                            Radio(
                                activeColor: kPrimaryColor,
                                value: TransactionPriority.medium,
                                groupValue: widget.priority,
                                onChanged: (v) {
                                  setState(() {
                                    widget.priority = v as TransactionPriority;
                                    if (widget.token ==
                                        state.currentNetwork.currency) {
                                      widget.gasLimit = 21000;
                                      _gasLimit.text = "21000";
                                    }
              
                                    _maxFee.text = widget.medium.toString();
                                    widget.maxFee = widget.medium;
                                    widget.maxPriority = widget.medium;
              
                                    _maxPriorityFee.text = widget.medium.toString();
                                    updatePriority(widget.medium);
                                    updateGasLimit();
                                    updateMaxPriorityEth();
                                    updateMaxFeeEth();
                                  });
                                }),
                            const Expanded(child: SizedBox()),
                            Radio(
                                activeColor: kPrimaryColor,
                                value: TransactionPriority.high,
                                groupValue: widget.priority,
                                onChanged: (v) {
                                  setState(() {
                                    widget.priority = v as TransactionPriority;
                                    if (widget.token ==
                                        state.currentNetwork.currency) {
                                      widget.gasLimit = 21000;
                                      _gasLimit.text = "21000";
                                    }
              
                                    _maxFee.text = widget.high.toString();
                                    widget.maxFee = widget.high;
                                    widget.maxPriority = widget.high;
                                    _maxPriorityFee.text = widget.high.toString();
                                    updatePriority(widget.high);
                                    updateGasLimit();
                                    updateMaxPriorityEth();
                                    updateMaxFeeEth();
                                  });
                                }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 52.25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 8,
                              width: 3,
                              color: Colors.grey,
                            ),
                            Expanded(
                                child: Container(
                              width: double.infinity,
                              height: 3,
                              color: Colors.grey,
                            )),
                            Container(
                              height: 8,
                              width: 3,
                              color: Colors.grey,
                            ),
                            Expanded(
                                child: Container(
                              width: double.infinity,
                              height: 3,
                              color: Colors.grey,
                            )),
                            Container(
                              height: 8,
                              width: 3,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                     const  SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:const [
                            Text("Low"),
                            Expanded(
                                child: SizedBox(
                              width: double.infinity,
                              height: 3,
                            )),
                            Text("Market"),
                            Expanded(
                                child: SizedBox(
                              width: double.infinity,
                              height: 3,
                            )),
                           Text("High"),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 17,
                      ),
                      !widget.showAdvance
                          ? Column(
                              children: [
                                InkWell(
                                  onTap: () => widget.onAdvanceOptionClicked!(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:const  [
                                      Text(
                                        "Advance options",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: kPrimaryColor,
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                  "How should I choose",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w100),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  child: Column(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: const [
                                              Text(
                                                "Gas limit",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                width: 1, color: kPrimaryColor)),
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.priority =
                                                        TransactionPriority.custom;
                                                    _gasLimit.text =
                                                        (widget.gasLimit -= 1000)
                                                            .toString();
                                                    updateGasLimit();
                                                  });
                                                },
                                                icon:const  Icon(Icons.remove_circle)),
                                            Expanded(
                                                child: TextFormField(
                                              textAlign: TextAlign.center,
                                              controller: _gasLimit,
                                              decoration:
                                                  const InputDecoration.collapsed(
                                                      hintText: '0'),
                                            )),
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.priority =
                                                        TransactionPriority.custom;
                                                    _gasLimit.text =
                                                        (widget.gasLimit += 1000)
                                                            .toString();
                                                    updateGasLimit();
                                                  });
                                                },
                                                icon: const Icon(Icons.add_circle)),
                                          ],
                                        ),
                                      ),
                                     const  SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: const [
                                              Text(
                                                "Max priority fee (GWEI)",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                width: 1, color: kPrimaryColor)),
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.priority =
                                                        TransactionPriority.custom;
                                                    _maxPriorityFee.text =
                                                        (widget.maxPriority -= 1)
                                                            .toString();
                                                    updateMaxPriorityEth();
                                                  });
                                                },
                                                icon: const Icon(Icons.remove_circle)),
                                            Expanded(
                                                child: TextFormField(
                                              textAlign: TextAlign.center,
                                              controller: _maxPriorityFee,
                                              decoration:
                                                  const InputDecoration.collapsed(
                                                      hintText: '0'),
                                            )),
                                            Expanded(
                                                child: Text(
                                              "${maxPriorityInEth.toStringAsFixed(10)} ETH",
                                              textAlign: TextAlign.center,
                                            )),
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.priority =
                                                        TransactionPriority.custom;
              
                                                    _maxPriorityFee.text =
                                                        (widget.maxPriority += 1)
                                                            .toString();
                                                    updateMaxPriorityEth();
                                                  });
                                                },
                                                icon:const  Icon(Icons.add_circle)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: const [
                                              Text(
                                                "Max fee (GWEI)",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                width: 1, color: kPrimaryColor)),
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.priority =
                                                        TransactionPriority.custom;
              
                                                    _maxFee.text = (widget.maxFee -=
                                                            1)
                                                        .toString();
                                                    updateMaxFeeEth();
                                                  });
                                                },
                                                icon: const Icon(Icons.remove_circle)),
                                            Expanded(
                                                child: TextFormField(
                                              textAlign: TextAlign.center,
                                              controller: _maxFee,
                                              decoration:
                                                  const InputDecoration.collapsed(
                                                      hintText: '0'),
                                            )),
                                            Expanded(
                                                child: Text(
                                              "${maxFeeInEth.toStringAsFixed(10)} ETH",
                                              textAlign: TextAlign.center,
                                            )),
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.priority =
                                                        TransactionPriority.custom;
              
                                                    _maxFee.text = (widget.maxFee +=
                                                            1)
                                                        .toString();
                                                    updateMaxFeeEth();
                                                  });
                                                },
                                                icon:const  Icon(Icons.add_circle)),
                                          ],
                                        ),
                                      )
                                      // Padding(
                                      //     padding: const EdgeInsets.symmetric(
                                      //         horizontal: 16),
                                      //     child: Expanded(
                                      //       child: Row(
                                      //         children: [
                                      //           IconButton(
                                      //                     onPressed: () {
                                      //                       setState(() {
                                      //                         _gasLimit.text =
                                      //                             (widget.gasLimit -= 1000)
                                      //                                 .toString();
                                      //                       });
                                      //                     },
                                      //                     icon: Icon(
                                      //                         Icons.remove_circle)),
                                      //           TextFormField(
                                      //             controller: _gasLimit,
                                      //             cursorColor: kPrimaryColor,
                                      //             decoration: InputDecoration(
              
                                      //               fillColor: Colors.red,
                                      //                 contentPadding: EdgeInsets.all(0),
                                      //                 suffix: IconButton(
                                      //                     onPressed: () {
                                      //                       setState(() {
                                      //                         _gasLimit.text =
                                      //                             (widget.gasLimit += 1000)
                                      //                                 .toString();
                                      //                       });
                                      //                     },
                                      //                     icon: Icon(Icons.add_circle)),
                                      //                 prefix: IconButton(
                                      //                     onPressed: () {
                                      //                       setState(() {
                                      //                         _gasLimit.text =
                                      //                             (widget.gasLimit -= 1000)
                                      //                                 .toString();
                                      //                       });
                                      //                     },
                                      //                     icon: Icon(
                                      //                         Icons.remove_circle)),
                                      //                 enabledBorder: OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: Colors.grey)),
                                      //                 focusedBorder: OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: kPrimaryColor)),
                                      //                 errorBorder: OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: kPrimaryColor)),
                                      //                 border: OutlineInputBorder(
                                      //                     borderSide: BorderSide())),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     )),
                                      // SizedBox(
                                      //   height: 10,
                                      // ),
                                      // Padding(
                                      //     padding: const EdgeInsets.symmetric(
                                      //         horizontal: 16),
                                      //     child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.spaceBetween,
                                      //       children: [
                                      //         const Text(
                                      //           "Max priority fee (GWEI)",
                                      //           style: TextStyle(
                                      //               fontSize: 14,
                                      //               fontWeight: FontWeight.bold),
                                      //         ),
                                      //       ],
                                      //     )),
                                      // const SizedBox(
                                      //   height: 5,
                                      // ),
                                      // Padding(
                                      //     padding: const EdgeInsets.symmetric(
                                      //         horizontal: 16),
                                      //     child: TextFormField(
                                      //       controller: _maxPriorityFee,
                                      //       cursorColor: kPrimaryColor,
                                      //       decoration: InputDecoration(
                                      //           contentPadding: EdgeInsets.all(0),
                                      //           suffix: IconButton(
                                      //               onPressed: () {
                                      //                 setState(() {
                                      //                   _maxPriorityFee.text =
                                      //                       (widget.maxPriority += 1)
                                      //                           .toString();
                                      //                 });
                                      //               },
                                      //               icon: Icon(Icons.add_circle)),
                                      //           prefix: IconButton(
                                      //               onPressed: () {
                                      //                 setState(() {
                                      //                   _maxPriorityFee.text =
                                      //                       (widget.maxPriority -= 1)
                                      //                           .toString();
                                      //                 });
                                      //               },
                                      //               icon: Icon(
                                      //                   Icons.remove_circle)),
                                      //           enabledBorder: OutlineInputBorder(
                                      //               borderSide: BorderSide(
                                      //                   color: Colors.grey)),
                                      //           focusedBorder: OutlineInputBorder(
                                      //               borderSide: BorderSide(
                                      //                   color: kPrimaryColor)),
                                      //           errorBorder: OutlineInputBorder(
                                      //               borderSide: BorderSide(
                                      //                   color: kPrimaryColor)),
                                      //           border: OutlineInputBorder(
                                      //               borderSide: BorderSide())),
                                      //     )),
                                      // SizedBox(
                                      //   height: 15,
                                      // ),
                                      // Padding(
                                      //     padding: const EdgeInsets.symmetric(
                                      //         horizontal: 16),
                                      //     child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.spaceBetween,
                                      //       children: [
                                      //         const Text(
                                      //           "Max fee (GWEI)",
                                      //           style: TextStyle(
                                      //               fontSize: 14,
                                      //               fontWeight: FontWeight.bold),
                                      //         ),
                                      //       ],
                                      //     )),
                                      // const SizedBox(
                                      //   height: 5,
                                      // ),
                                      // Padding(
                                      // padding: const EdgeInsets.symmetric(
                                      //     horizontal: 16),
                                      // child: TextFormField(
                                      //   controller: _maxFee,
                                      //   cursorColor: kPrimaryColor,
                                      //   decoration: InputDecoration(
                                      //       contentPadding: EdgeInsets.all(0),
                                      //       suffix: IconButton(
                                      //           onPressed: () {
                                      //             setState(() {
                                      //               _maxFee.text =
                                      //                   (widget.maxFee += 1)
                                      //                       .toString();
                                      //             });
                                      //           },
                                      //           icon: Icon(Icons.add_circle)),
                                      //       prefix: IconButton(
                                      //           onPressed: () {
                                      //             setState(() {
                                      //               _maxFee.text =
                                      //                   (widget.maxFee -= 1)
                                      //                       .toString();
                                      //             });
                                      //           },
                                      //           icon: Icon(
                                      //               Icons.remove_circle)),
                                      //       enabledBorder: OutlineInputBorder(
                                      //           borderSide: BorderSide(
                                      //               color: Colors.grey)),
                                      //       focusedBorder: OutlineInputBorder(
                                      //           borderSide: BorderSide(
                                      //               color: kPrimaryColor)),
                                      //       errorBorder: OutlineInputBorder(
                                      //           borderSide: BorderSide(
                                      //               color: kPrimaryColor)),
                                      //       border: OutlineInputBorder(
                                      //           borderSide: BorderSide())),
                                      // )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                      const SizedBox(height: 20,),
                      WalletButton(
                          type: WalletButtonType.filled,
                          textContent: "Save",
                          onPressed: () async {
                            if (widget.showAdvance) {
                              widget.changePriority(
                                  double.parse(_maxPriorityFee.text),
                                  double.parse(_maxFee.text),
                                  widget.priority,
                                  widget.gasLimit);
                              Navigator.of(context).pop();
                            } else {
                              if (widget.priority == TransactionPriority.low) {
                                widget.changePriority(widget.low, widget.low,
                                    widget.priority, widget.gasLimit);
                                Navigator.of(context).pop();
                              }
                              if (widget.priority == TransactionPriority.medium) {
                                widget.changePriority(widget.medium, widget.medium,
                                    widget.priority, widget.gasLimit);
                                Navigator.of(context).pop();
                              }
                              if (widget.priority == TransactionPriority.high) {
                                widget.changePriority(widget.high, widget.high,
                                    widget.priority, widget.gasLimit);
                                Navigator.of(context).pop();
                              }
                            }
                          }),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
