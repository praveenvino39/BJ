import 'dart:developer';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomToken extends StatefulWidget {
  final WalletLoaded state;
  const CustomToken({
    Key? key,
    required this.state,
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
      List<String> tokenInfo = await context.read<TokenCubit>().getTokenInfo(
          tokenAddress: _tokenAddress.text,
          network: widget.state.currentNetwork);
      _decimalController.text = tokenInfo[0];
      _symbolController.text = tokenInfo[1];
    } catch (e) {
      log(e.toString());
    }
  }

  addTokenHandler() {
    context.read<TokenCubit>().addToken(
          address: getWalletLoadedState(context).wallet.privateKey.address.hex,
          network: getWalletLoadedState(context).currentNetwork,
          token: Token(
              balanceInFiat: 0.0,
              tokenAddress: _tokenAddress.text,
              symbol: _symbolController.text,
              decimal: int.parse(_decimalController.text),
              balance: Decimal.fromInt(0).toDouble()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocConsumer<TokenCubit, TokenState>(
        listener: (context, state) {
          if (state is TokenAdded) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.tokenAddedSuccesfully),
              backgroundColor: Colors.green,
            ));
          }
        },
        builder: (context, state) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            // width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width - 90,
                          child: Text(
                              AppLocalizations.of(context)!.anyoneCanCreate))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppLocalizations.of(context)!.tokenAddress,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    maxLength: 42,
                    controller: _tokenAddress,
                    validator: (String? string) {
                      if (string?.isEmpty == true) {
                        return AppLocalizations.of(context)!
                            .thisFeatureInMainnet;
                      }
                      if (string!.length < 8) {
                        return AppLocalizations.of(context)!
                            .passwordMustContain;
                      }
                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                        hintText: "0x...",
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor)),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor)),
                        border: OutlineInputBorder(borderSide: BorderSide())),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppLocalizations.of(context)!.tokenSymbol,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _symbolController,
                    validator: (String? string) {
                      if (string?.isEmpty == true) {
                        return AppLocalizations.of(context)!.thisFieldNotEmpty;
                      }
                      if (string!.length < 8) {
                        return AppLocalizations.of(context)!
                            .passwordMustContain;
                      }
                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                        hintText: "EGC",
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor)),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor)),
                        border: OutlineInputBorder(borderSide: BorderSide())),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppLocalizations.of(context)!.tokenDecimal,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _decimalController,
                    validator: (String? string) {
                      if (string?.isEmpty == true) {
                        return AppLocalizations.of(context)!.thisFieldNotEmpty;
                      }
                      if (string!.length < 8) {
                        return AppLocalizations.of(context)!
                            .passwordMustContain;
                      }
                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                        hintText: "18",
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor)),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor)),
                        border: OutlineInputBorder(borderSide: BorderSide())),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: WalletButton(
                            textContent: AppLocalizations.of(context)!.cancel,
                            onPressed: () => Navigator.of(context).pop())),
                    Expanded(
                      child: WalletButton(
                        textContent: AppLocalizations.of(context)!.import,
                        type: WalletButtonType.filled,
                        onPressed: addTokenHandler,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
