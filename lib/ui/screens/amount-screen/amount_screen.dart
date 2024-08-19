// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/screens/transaction-confirmation-screen/transaction_confirmation_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

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
      showErrorSnackBar(
          context,
          getText(context, key: 'invalidInput'),
          getTextWithPlaceholder(context,
              key: 'key', string: widget.token.decimal.toString()));
      return;
    }
    context.push(() => TransactionConfirmationScreen(
        balance: widget.balance,
        to: widget.to,
        from: widget.from,
        value: Decimal.parse(inputAmount.text).toDouble(),
        token: selectedToken,
        contractAddress: widget.token.tokenAddress));
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const WalletText(
                  localizeKey: 'amount',
                  size: 16,
                  fontWeight: FontWeight.w200,
                  color: Colors.black),
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
                  addWidth(SpacingSize.xs),
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
          actions: [
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateColor.resolveWith(
                    (states) => kPrimaryColor.withAlpha(30)),
              ),
              onPressed: onCancelHandler,
              child:
                  const WalletText(localizeKey: 'cancel', color: kPrimaryColor),
            )
          ]),
      body: Column(
        children: [
          addHeight(SpacingSize.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [addWidth(SpacingSize.xs)],
              ))
            ],
          ),
          addWidth(SpacingSize.m),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: inputAmount,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration.collapsed(hintText: '0'),
            style: const TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          addHeight(SpacingSize.m),
          Text(
              "${getText(context, key: 'balance')}: ${selectedToken != Provider.of<WalletProvider>(context).activeNetwork.symbol ? selectedTokenObj!.balance.toString() + selectedToken : Provider.of<WalletProvider>(context).getNativeBalanceFormatted()}"),
          addHeight(SpacingSize.m),
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
                  child: WalletText(
                      localizeKey: 'insufficientFund', color: Colors.red),
                ),
          addHeight(SpacingSize.s),
        ],
      ),
    );
  }
}
