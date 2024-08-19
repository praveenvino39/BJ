import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/core/providers/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/screens/token-dashboard-screen/token_dashboard_screen.dart';
import 'package:wallet_cryptomask/ui/tabs/token/widgets/token_tile.dart';

class TokenTab extends StatefulWidget {
  const TokenTab({
    Key? key,
  }) : super(key: key);

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

  setupAndLoadToken() async {
    final tokens = await getTokenProvider(context).loadToken(
        nativeBalance: getWalletProvider(context).nativeBalance,
        address: getWalletProvider(context)
            .activeWallet
            .wallet
            .privateKey
            .address
            .hex,
        network: getWalletProvider(context).activeNetwork);
    if (mounted) {
      getWalletProvider(context)
          .changeFiatBalance(tokens[0].balanceInFiat.toStringAsFixed(5));
    }
  }

  onTokenPressHandler(Token token) {
    context.push(() => TokenDashboardScreen(tokenAddress: token.tokenAddress));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Provider.of<TokenProvider>(context).tokens.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  itemCount: Provider.of<TokenProvider>(context).tokens.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => onTokenPressHandler(
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
                      symbol: Provider.of<TokenProvider>(context, listen: false)
                          .tokens[index]
                          .symbol,
                      balanceInFiat:
                          Provider.of<TokenProvider>(context, listen: false)
                              .tokens[index]
                              .balanceInFiat,
                    ),
                  ),
                ),
              )
            : const Center(
                child: WalletText(
                  localizeKey: 'youDontHaveToken',
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
