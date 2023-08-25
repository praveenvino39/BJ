// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:wallet/ui/transaction-confirmation/transaction_confirmation.dart';
import 'package:wallet/ui/widgets/sheets/token_selection_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AmountScreen extends StatefulWidget {
  static const route = "amount_screen";
  double balance;
  final String from;
  final String to;
  final Token token;
  AmountScreen(
      {Key? key,
      required this.balance,
      required this.from,
      required this.to,
      required this.token})
      : super(key: key);

  @override
  State<AmountScreen> createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen> {
  bool isValidAmount = true;
  TextEditingController inputAmount = TextEditingController(text: "0");
  String selectedToken = "ETH";
  Token? selectedTokenObj;

  openTokenSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TokenSelectionSheet(
        onTokenSelect: (selectedTokenFromSheet) {
          widget.balance = selectedTokenFromSheet.balance.toDouble();
          selectedToken = selectedTokenFromSheet.symbol;
          setState(() {
            selectedTokenObj = selectedTokenFromSheet;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  onAmountConfirmed() {
    Navigator.of(context)
        .pushNamed(TransactionConfirmationScreen.route, arguments: {
      "balance": widget.balance,
      "to": widget.to,
      "from": widget.from,
      "value": Decimal.parse(inputAmount.text).toDouble(),
      "token": selectedToken,
      "contractAddress": widget.token.tokenAddress
    });
  }

  @override
  void initState() {
    setState(() {
      selectedToken = widget.token.symbol;
      selectedTokenObj = widget.token;
    });
    inputAmount.addListener(() {
      try {
        double amount = double.parse(inputAmount.text);
        if (widget.token.tokenAddress == "") {
          if (getWalletLoadedState(context).balanceInNative >= amount) {
            setState(() {
              isValidAmount = true;
            });
          } else {
            setState(() {
              isValidAmount = false;
            });
          }
        }else{
          if(widget.token.balance >= amount){
            setState(() {
              isValidAmount = true;
            });
          }else{
            setState(() {
              isValidAmount = false;
            });
          }
        }
        
      } catch (e) {
        log(e.toString());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              shadowColor: Colors.white,
              elevation: 0,
              backgroundColor: Colors.white,
              title: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.amount,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                            color: Colors.black)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              color: (state as WalletLoaded)
                                  .currentNetwork
                                  .dotColor,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          state.currentNetwork.networkName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 12,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              leading: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => kPrimaryColor.withAlpha(30)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.back,
                  style: const TextStyle(color: kPrimaryColor),
                ),
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => kPrimaryColor.withAlpha(30)),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(color: kPrimaryColor),
                  ),
                )
              ]),
          body: Column(
            children: [
              const SizedBox(
                width: double.infinity,
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(child: Text("")),
                  InkWell(
                    onTap: openTokenSelection,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedToken,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ))
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: inputAmount,
                cursorColor: kPrimaryColor,
                decoration: const InputDecoration.collapsed(hintText: '0'),
                style: const TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                  "${AppLocalizations.of(context)!.balance}: ${selectedToken != state.currentNetwork.currency ? selectedTokenObj!.balance.toString() : widget.balance} $selectedToken"),
              const SizedBox(
                height: 30,
              ),
              const Expanded(child: SizedBox()),
              isValidAmount
                  ? WalletButton(
                      textContent: "Next",
                      onPressed: onAmountConfirmed,
                      type: WalletButtonType.filled,
                    )
                  : const Text("Insufficient fund", style: TextStyle(color: Colors.red),),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }
}
