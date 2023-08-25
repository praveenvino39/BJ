import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/ui/token/component/token_tile.dart';

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
    return BlocConsumer<TokenCubit, TokenState>(
      listener: (context, state) {},
      builder: (context, state) {
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
                itemCount: state.tokens.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    widget.onTokenSelect(state.tokens[index]);
                  },
                  child: TokenTile(
                    decimal: state.tokens[index].decimal,
                      imageUrl: state.tokens[index].imageUrl,
                      symbol: state.tokens[index].symbol,
                      balance: Decimal.zero,
                      balanceInFiat: 0.0,
                      tokenAddress: state.tokens[index].tokenAddress),
                ),
              ))
            ],
          ),
        );
      },
    );
  }
}
