import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/ui/token/component/import_token_tile.dart';
import 'package:wallet/ui/token/component/token_tile.dart';
import 'package:web3dart/web3dart.dart';

class TokenTab extends StatefulWidget {
  final Web3Client web3client;
  final String networkKey;
  final Function(Token token) onTokenPressed;
  const TokenTab(
      {Key? key,
      required this.networkKey,
      required this.onTokenPressed,
      required this.web3client})
      : super(key: key);

  @override
  State<TokenTab> createState() => _TokenTabState();
}

class _TokenTabState extends State<TokenTab> {
  Timer? _tokenBalanceTimer;

  // @override
  // void initState() {
  //   setupAndLoadToken();
  //   super.initState();
  // }

  // setupAndLoadToken({String? updatedAddress}) {
  //   if (_tokenBalanceTimer == null) {
  //     getTokenCubit(context).setupWeb3Client(widget.web3client);
  //     String address = updatedAddress ??
  //         getWalletLoadedState(context).wallet.privateKey.address.hex;
  //     context.read<TokenCubit>().loadToken(
  //         address: address,
  //         network: Core.networks.firstWhere(
  //             (element) => element.networkName == widget.networkKey));
  //     _tokenBalanceTimer = null;
  //     _tokenBalanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
  //       context.read<TokenCubit>().loadToken(
  //           address: address,
  //           network: Core.networks.firstWhere(
  //               (element) => element.networkName == widget.networkKey));
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              BlocConsumer<TokenCubit, TokenState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is TokenLoaded) {
                    return Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.tokens.length + 1,
                              itemBuilder: (context, index) => index ==
                                      state.tokens.length
                                  ? const ImportTokenTile()
                                  : InkWell(
                                      onTap: () => widget
                                          .onTokenPressed(state.tokens[index]),
                                      child: TokenTile(
                                        imageUrl: state.tokens[index].imageUrl,
                                        decimal: state.tokens[index].decimal,
                                        tokenAddress:
                                            state.tokens[index].tokenAddress,
                                        balance: Decimal.parse(state
                                            .tokens[index].balance
                                            .toString()),
                                        symbol: state.tokens[index].symbol,
                                        balanceInFiat:
                                            state.tokens[index].balanceInFiat,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Loading Tokens")
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tokenBalanceTimer?.cancel();
    super.dispose();
  }
}
