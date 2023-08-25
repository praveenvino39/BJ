// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slider_button/slider_button.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/abi.dart';
import 'package:wallet/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/core/model/coin_gecko_token_model.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';
import 'package:wallet/ui/home/home_screen.dart';
import 'package:wallet/utils.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SwapConfirmScreen extends StatefulWidget {
  static const route = "swap_confirm_screen";
  final double tokenInAmount;
  final CoinGeckoToken tokenFrom;
  final CoinGeckoToken tokenTo;
  final BigInt tokenOutAmount;
  final BigInt fee;
  const SwapConfirmScreen(
      {Key? key,
      required this.tokenInAmount,
      required this.tokenFrom,
      required this.tokenTo,
      required this.fee,
      required this.tokenOutAmount})
      : super(key: key);

  @override
  State<SwapConfirmScreen> createState() => _SwapConfirmScreenState();
}

class _SwapConfirmScreenState extends State<SwapConfirmScreen> {
  BigInt tokenAmountOut = BigInt.zero;
  BigInt fee = BigInt.zero;
  late Timer quoteTime;
  int countDown = 15;
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<BigInt> getQuote() async {
    var client = (context.read<WalletCubit>().state as WalletLoaded).web3client;
    ContractAbi contractAbi =
        ContractAbi.fromJson(jsonEncode(UNISWAP_SWAP_ROUTER), "");
    DeployedContract deployedContract = DeployedContract(contractAbi,
        EthereumAddress.fromHex("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"));
    var quote = await client.call(
        contract: deployedContract,
        function: deployedContract.function('getAmountsOut'),
        params: [
          // BigInt.parse("1000000000000"),
          EtherAmount.fromUnitAndValue(EtherUnit.wei,
                  (widget.tokenInAmount * math.pow(10, 18)).toInt())
              .getValueInUnitBI(EtherUnit.wei),
          [
            EthereumAddress.fromHex(widget.tokenFrom.address),
            EthereumAddress.fromHex(widget.tokenTo.address)
          ]
        ]);
    log(quote[0][1].toString());
    return quote[0][1];
  }

  @override
  void initState() {
    fee = widget.fee;
    tokenAmountOut = widget.tokenOutAmount;
    quoteTime = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countDown == 0) {
        getQuote().then((value) {
          setState(() {
            tokenAmountOut = value;
            countDown = 15;
          });
        });
      }
      setState(() {
        countDown -= 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TokenCubit, TokenState>(
      listener: (context, state) {
        if (state is TokenTransfered) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.route, (Route<dynamic> route) => false,
              arguments: {"password": getWalletLoadedState(context).password});
          showSuccessSnackbar(
              context, AppLocalizations.of(context)!.transactionSubmitted, AppLocalizations.of(context)!.waitingForConfirmation);
        }
        if(state is TokenError){
          showErrorSnackBar(context, AppLocalizations.of(context)!.transactionFailed, state.error);
        }
      },
      child: BlocBuilder<WalletCubit, WalletState>(builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
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
                    const Text("Swap Confirm",
                        style: TextStyle(
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
              actions: [
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => kPrimaryColor.withAlpha(30)),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: kPrimaryColor),
                  ),
                )
              ]),
          body: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(countDown > 0
                  ? "${AppLocalizations.of(context)!.getQuotes} in ${countDown}s"
                  : "Getting new quote"),
              const SizedBox(
                width: double.infinity,
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
                  Container(
                    // width: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AvatarWidget(
                          radius: 20,
                          imageUrl: widget.tokenFrom.logoUri,
                          address: widget.tokenFrom.address,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.tokenFrom.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox())
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "${widget.tokenInAmount} ${widget.tokenFrom.symbol}",
                style: const TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                  "${state.balanceInNative} ${state.currentNetwork.currency} ${AppLocalizations.of(context)!.availableToSwap}"),
              const SizedBox(
                height: 10,
              ),
              const Icon(
                Icons.arrow_downward_outlined,
                color: kPrimaryColor,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(child: SizedBox()),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AvatarWidget(
                          radius: 20,
                          imageUrl: widget.tokenTo.logoUri,
                          address: widget.tokenTo.address,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.tokenTo.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "${(tokenAmountOut.toDouble() / math.pow(10, 18)).toStringAsFixed(10)} ${widget.tokenTo.symbol}",
                style: const TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              const Expanded(child: SizedBox()),
              !isLoading
                  ? Row(
                      children: [
                        // Expanded(
                        //   child: WalletButton(
                        //     textContent: "Swap token",
                        //     onPressed: () {
                        //       // var out = tokenAmountOut.toInt();
                        //       // var inAMount = EtherAmount.fromUnitAndValue(EtherUnit.wei, (widget.tokenInAmount* math.pow(10, 18)).toInt()).getValueInUnitBI(EtherUnit.wei).toInt();
                        //       // log("${inAMount.toString()}, ${out.toString()}");

                        //       String swapType = "ETH2TOKEN";
                        //       if (widget.tokenFrom.address ==
                        //           state.currentNetwork.wrappedTokenAddress) {
                        //         swapType = "ETH2TOKEN";
                        //       }
                        //       if (widget.tokenTo.address.toLowerCase() ==
                        //           state.currentNetwork.wrappedTokenAddress
                        //               .toLowerCase()) {
                        //         swapType = "TOKEN2ETH";
                        //       }
                        //       if (widget.tokenFrom.address !=
                        //               state.currentNetwork.wrappedTokenAddress &&
                        //           widget.tokenTo.address !=
                        //               state.currentNetwork.wrappedTokenAddress) {
                        //         swapType = "TOKEN2TOKEN";
                        //       }

                        //       context.read<WalletCubit>().swapToken(
                        //           swapType: swapType,
                        //           web3client: state.web3client,
                        //           tokenFrom: widget.tokenFrom.address,
                        //           tokenTo: widget.tokenTo.address,
                        //           amountOut: tokenAmountOut,
                        //           amount: EtherAmount.fromUnitAndValue(
                        //               EtherUnit.wei,
                        //               (widget.tokenInAmount * math.pow(10, 18))
                        //                   .toInt()),
                        //           fee: fee,
                        //           recipient: state.wallet.privateKey.address.hex);
                        //     },
                        //     type: WalletButtonType.filled,
                        //   ),
                        // ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              child: SliderButton(
                                  width: MediaQuery.of(context).size.width - 20,
                                  buttonSize: 40,
                                  height: 50,
                                  action: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    String swapType = "ETH2TOKEN";
                                    if (widget.tokenFrom.address ==
                                        state.currentNetwork
                                            .wrappedTokenAddress) {
                                      swapType = "ETH2TOKEN";
                                    }
                                    if (widget.tokenTo.address.toLowerCase() ==
                                        state.currentNetwork.wrappedTokenAddress
                                            .toLowerCase()) {
                                      swapType = "TOKEN2ETH";
                                    }
                                    if (widget.tokenFrom.address !=
                                            state.currentNetwork
                                                .wrappedTokenAddress &&
                                        widget.tokenTo.address !=
                                            state.currentNetwork
                                                .wrappedTokenAddress) {
                                      swapType = "TOKEN2TOKEN";
                                    }

                                    context.read<TokenCubit>().swapToken(
                                        swapType: swapType,
                                        web3client: state.web3client,
                                        tokenFrom: widget.tokenFrom.address,
                                        tokenTo: widget.tokenTo.address,
                                        amountOut: tokenAmountOut,
                                        amount: EtherAmount.fromUnitAndValue(
                                            EtherUnit.wei,
                                            (widget.tokenInAmount *
                                                    math.pow(10, 18))
                                                .toInt()),
                                        fee: fee,
                                        recipient:
                                            state.wallet.privateKey.address.hex,
                                        currentState:
                                            getWalletLoadedState(context));
                                  },
                                  label: Text(
                                    AppLocalizations.of(context)!.swipeToSwap,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xff4a4a4a),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                  buttonColor: kPrimaryColor,
                                  backgroundColor: kPrimaryColor.withAlpha(50),
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: const [
                        CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                        Text("Executing swap, Please wait...")
                      ],
                    ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    quoteTime.cancel();
    super.dispose();
  }
}
