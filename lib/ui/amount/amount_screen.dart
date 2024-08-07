// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/transaction-confirmation/transaction_confirmation.dart';
import 'package:wallet_cryptomask/utils.dart';

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

  onTokenSelection(selectedTokenFromSheet) {
    selectedToken = selectedTokenFromSheet.symbol;
    widget.token.tokenAddress = selectedTokenFromSheet.tokenAddress;
    setState(() {
      widget.balance = selectedTokenFromSheet.balance.toDouble();
      selectedTokenObj = selectedTokenFromSheet;
    });
    checkIsValidAmount();
    Navigator.of(context).pop();
  }

  onNextHandler() {
    final valueString = inputAmount.text;

    // Check if the value has more than 18 decimal places
    final decimalIndex = valueString.indexOf('.');
    if (decimalIndex != -1 &&
        valueString.length - decimalIndex - 1 > widget.token.decimal) {
      showErrorSnackBar(context, "Invalid input",
          'The value cannot have more than ${widget.token.decimal} decimal places.');
      return;
    }
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
    inputAmount.addListener(checkIsValidAmount);
    super.initState();
  }

  checkIsValidAmount() {
    try {
      double amount = double.parse(inputAmount.text);
      if (widget.token.tokenAddress == "") {
        if (Provider.of<WalletProvider>(context, listen: false).nativeBalance >=
            amount) {
          setState(() {
            isValidAmount = true;
          });
        } else {
          setState(() {
            isValidAmount = false;
          });
        }
      } else {
        if (selectedTokenObj!.balance >= amount) {
          setState(() {
            isValidAmount = true;
          });
        } else {
          setState(() {
            isValidAmount = false;
          });
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  onCancelHandler() async {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                          color: Provider.of<WalletProvider>(context)
                              .activeNetwork
                              .dotColor,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      Provider.of<WalletProvider>(context)
                          .activeNetwork
                          .networkName,
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
          actions: [
            TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => kPrimaryColor.withAlpha(30)),
              ),
              onPressed: onCancelHandler,
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
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
              "${AppLocalizations.of(context)!.balance}: ${selectedToken != Provider.of<WalletProvider>(context).activeNetwork.symbol ? selectedTokenObj!.balance.toString() + selectedToken : Provider.of<WalletProvider>(context).getNativeBalanceFormatted()}"),
          const SizedBox(
            height: 30,
          ),
          const Expanded(child: SizedBox()),
          isValidAmount
              ? SafeArea(
                  child: WalletButton(
                    localizeKey: 'next',
                    onPressed: onNextHandler,
                    type: WalletButtonType.filled,
                  ),
                )
              : const SafeArea(
                  child: Text(
                    "Insufficient fund",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
