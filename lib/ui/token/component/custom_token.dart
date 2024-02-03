import 'dart:developer';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class CustomToken extends StatefulWidget {
  const CustomToken({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomToken> createState() => _CustomTokenState();
}

class _CustomTokenState extends State<CustomToken> {
  final TextEditingController _tokenAddress = TextEditingController();
  final TextEditingController _decimalController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();

  @override
  void initState() {
    _tokenAddress.addListener(() async {
      if (_tokenAddress.text.length == 42) getTokenInfo();
    });
    super.initState();
  }

  getTokenInfo() async {
    try {
      List<String> tokenInfo =
          await Provider.of<TokenProvider>(context, listen: false).getTokenInfo(
              tokenAddress: _tokenAddress.text,
              network: Provider.of<WalletProvider>(context, listen: false)
                  .activeNetwork);
      _decimalController.text = tokenInfo[0];
      _symbolController.text = tokenInfo[1];
    } catch (e) {
      log(e.toString());
    }
  }

  addTokenHandler() {
    Provider.of<TokenProvider>(context, listen: false)
        .addToken(
      address: Provider.of<WalletProvider>(context, listen: false)
          .activeWallet
          .wallet
          .privateKey
          .address
          .hex,
      network:
          Provider.of<WalletProvider>(context, listen: false).activeNetwork,
      token: Token(
          balanceInFiat: 0.0,
          tokenAddress: _tokenAddress.text,
          symbol: _symbolController.text,
          decimal: int.parse(_decimalController.text),
          balance: Decimal.fromInt(0).toDouble()),
    )
        .then((value) {
      Navigator.of(context).pop();
      showPositiveSnackBar(context, 'Imported', 'Token imported successfully');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          addHeight(SpacingSize.s),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: kPrimaryColor.withAlpha(50),
                border: Border.all(width: 1, color: kPrimaryColor),
                borderRadius: BorderRadius.circular(7)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error,
                  color: kPrimaryColor,
                ),
                addWidth(SpacingSize.xs),
                const Expanded(
                  child: WalletText(
                    '',
                    localizeKey: 'anyoneCanCreate',
                  ),
                )
              ],
            ),
          ),
          addHeight(SpacingSize.m),
          WalletTextField(
            textFieldType: TextFieldType.input,
            labelLocalizeKey: 'tokenAddress',
            maxLength: 42,
            textEditingController: _tokenAddress,
            validator: (String? string) {
              if (string?.isEmpty == true) {
                return AppLocalizations.of(context)!.thisFeatureInMainnet;
              }
              if (string!.length < 8) {
                return AppLocalizations.of(context)!.passwordMustContain;
              }
              return null;
            },
          ),
          addHeight(SpacingSize.s),
          WalletTextField(
            textFieldType: TextFieldType.input,
            textEditingController: _symbolController,
            labelLocalizeKey: 'tokenSymbol',
            validator: (String? string) {
              if (string?.isEmpty == true) {
                return AppLocalizations.of(context)!.thisFieldNotEmpty;
              }
              if (string!.length < 8) {
                return AppLocalizations.of(context)!.passwordMustContain;
              }
              return null;
            },
          ),
          addHeight(SpacingSize.s),
          WalletTextField(
            textFieldType: TextFieldType.input,
            labelLocalizeKey: 'tokenDecimal',
            textEditingController: _decimalController,
            validator: (String? string) {
              if (string?.isEmpty == true) {
                return AppLocalizations.of(context)!.thisFieldNotEmpty;
              }
              if (string!.length < 8) {
                return AppLocalizations.of(context)!.passwordMustContain;
              }
              return null;
            },
          ),
          addHeight(SpacingSize.s),
          Row(
            children: [
              Expanded(
                  child: WalletButton(
                      localizeKey: 'cancel',
                      onPressed: () => Navigator.of(context).pop())),
              Expanded(
                child: WalletButton(
                  localizeKey: 'import',
                  type: WalletButtonType.filled,
                  onPressed: addTokenHandler,
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }
}
