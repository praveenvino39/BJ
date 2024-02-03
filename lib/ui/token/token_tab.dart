import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/bloc/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/token/component/import_token_tile.dart';
import 'package:wallet_cryptomask/ui/token/component/token_tile.dart';

class TokenTab extends StatefulWidget {
  final String networkKey;
  final Function(Token token) onTokenPressed;
  const TokenTab(
      {Key? key, required this.networkKey, required this.onTokenPressed})
      : super(key: key);

  @override
  State<TokenTab> createState() => _TokenTabState();
}

class _TokenTabState extends State<TokenTab> {
  Timer? _tokenBalanceTimer;

  @override
  void initState() {
    super.initState();
    setupAndLoadToken();
  }

  setupAndLoadToken() {
    if (_tokenBalanceTimer == null) {
      String address = Provider.of<WalletProvider>(context, listen: false)
          .activeWallet
          .wallet
          .privateKey
          .address
          .hex;
      Provider.of<TokenProvider>(context, listen: false).loadToken(
          address: address,
          network: Provider.of<WalletProvider>(context, listen: false)
              .activeNetwork);
      _tokenBalanceTimer = null;
      _tokenBalanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        Provider.of<TokenProvider>(context, listen: false).loadToken(
            address: address,
            network: Provider.of<WalletProvider>(context, listen: false)
                .activeNetwork);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: Provider.of<TokenProvider>(context).tokens.length + 1,
            itemBuilder: (context, index) =>
                index == Provider.of<TokenProvider>(context).tokens.length
                    ? const ImportTokenTile()
                    : InkWell(
                        onTap: () => widget.onTokenPressed(
                            Provider.of<TokenProvider>(context, listen: false)
                                .tokens[index]),
                        child: TokenTile(
                          imageUrl:
                              Provider.of<TokenProvider>(context, listen: false)
                                  .tokens[index]
                                  .imageUrl,
                          decimal:
                              Provider.of<TokenProvider>(context, listen: false)
                                  .tokens[index]
                                  .decimal,
                          tokenAddress:
                              Provider.of<TokenProvider>(context, listen: false)
                                  .tokens[index]
                                  .tokenAddress,
                          balance: Decimal.parse(
                              Provider.of<TokenProvider>(context, listen: false)
                                  .tokens[index]
                                  .balance
                                  .toString()),
                          symbol:
                              Provider.of<TokenProvider>(context, listen: false)
                                  .tokens[index]
                                  .symbol,
                          balanceInFiat:
                              Provider.of<TokenProvider>(context, listen: false)
                                  .tokens[index]
                                  .balanceInFiat,
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tokenBalanceTimer?.cancel();
    super.dispose();
  }
}
