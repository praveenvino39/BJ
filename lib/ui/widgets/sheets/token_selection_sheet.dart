import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/core/bloc/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/token/component/token_tile.dart';

class TokenSelectionSheet extends StatefulWidget {
  final Function(Token selectedToken) onTokenSelect;
  const TokenSelectionSheet({Key? key, required this.onTokenSelect})
      : super(key: key);

  @override
  State<TokenSelectionSheet> createState() => _TokenSelectionSheetState();
}

class _TokenSelectionSheetState extends State<TokenSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withAlpha(60),
            ),
            width: 50,
            height: 4,
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.withAlpha(60),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: getTokenProvider(context).tokens.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                widget.onTokenSelect(getTokenProvider(context).tokens[index]);
              },
              child: TokenTile(
                  decimal: getTokenProvider(context).tokens[index].decimal,
                  imageUrl: getTokenProvider(context).tokens[index].imageUrl,
                  symbol: getTokenProvider(context).tokens[index].symbol,
                  balance: Decimal.parse(getTokenProvider(context)
                      .tokens[index]
                      .balance
                      .toString()),
                  balanceInFiat: 0.0,
                  tokenAddress:
                      getTokenProvider(context).tokens[index].tokenAddress),
            ),
          ))
        ],
      ),
    );
  }
}
