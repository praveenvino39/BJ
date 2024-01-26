// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/ERC20.dart';
import 'package:wallet_cryptomask/core/abi.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/model/coin_gecko_token_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/swap_confirm_screen.dart/swap_confirm_screen.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SwapScreen extends StatefulWidget {
  static const route = "swap_screen";
  const SwapScreen({Key? key}) : super(key: key);

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  TextEditingController inputAmount = TextEditingController(text: "0");
  TextEditingController searchtokenController = TextEditingController();
  String tokenAmountOut = "0";
  String selectedToken = "ETH";
  Token? selectedTokenObj;
  double slippage = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<CoinGeckoToken> tokenList = [];
  CoinGeckoToken? tokenFrom;
  CoinGeckoToken? tokenTo;
  BigInt? tokenBalance;

  openTokenSelectionSheet(bool isFrom, WalletState state) {
    getAllToken().then((value) async {
      if (value != null) {
        setState(() {
          tokenList = value;
        });
        var chainId = await (state as WalletLoaded).web3client.getChainId();
        List<CoinGeckoToken> filteredList = value
            .where((element) => element.chainId == chainId.toInt())
            .toList();
        _scaffoldKey.currentState?.showBottomSheet(
            (context) => StatefulBuilder(
                  builder: (context, setSheetState) => Container(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5))),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              isFrom
                                  ? AppLocalizations.of(context)!.convertFrom
                                  : AppLocalizations.of(context)!.convertTo,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.search,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: searchtokenController,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                filteredList = tokenList;
                                return;
                              }
                              var filtered = tokenList.where((element) =>
                                  element.name
                                      .toLowerCase()
                                      .contains(value.toLowerCase()));
                              setSheetState(() {
                                filteredList = filtered.toList();
                              });
                              log(jsonEncode(filtered.toList()));
                            },
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!
                                    .enterTokenName,
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kPrimaryColor)),
                                errorBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kPrimaryColor)),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide())),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) => ListTile(
                                onTap: () {
                                  setState(() {
                                    if (isFrom) {
                                      tokenFrom = filteredList[index];
                                      var token = Erc20(
                                          address: EthereumAddress.fromHex(
                                              tokenFrom!.address),
                                          client: (context
                                                  .read<WalletCubit>()
                                                  .state as WalletLoaded)
                                              .web3client);
                                      token
                                          .balanceOf((context
                                                  .read<WalletCubit>()
                                                  .state as WalletLoaded)
                                              .wallet
                                              .privateKey
                                              .address)
                                          .then((value) => {
                                                setState(() {
                                                  tokenBalance = value;
                                                })
                                              });
                                    } else {
                                      tokenTo = filteredList[index];
                                    }

                                    Navigator.of(context).pop();
                                  });
                                },
                                leading: AvatarWidget(
                                    radius: 30,
                                    iconType: "identicon",
                                    imageUrl: filteredList[index].logoUri,
                                    address: filteredList[index].address),
                                title: Text(filteredList[index].name),
                                subtitle: Text(filteredList[index].symbol),
                                trailing: Text(
                                    "Chain ID ${filteredList[index].chainId.toString()}"),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            backgroundColor: Colors.transparent);
      }
    });
  }

  getQuote() async {
    try {
      var client =
          (context.read<WalletCubit>().state as WalletLoaded).web3client;
      if (tokenFrom!.address ==
          (context.read<WalletCubit>().state as WalletLoaded)
              .currentNetwork
              .wrappedTokenAddress) {
        log("SWAPPING ETH FOR TOKEN");
      } else {
        log("SWAPPING TOKEN FOR TOKEN");
      }

      DeployedContract uniswapFactoryContract = DeployedContract(
          ContractAbi.fromJson(
              jsonEncode(UNISWAP_FACTORY_ABI), "UNISWAP_FACTORY"),
          EthereumAddress.fromHex(
              "0x1F98431c8aD98523631AE4a59f267346ea31F984"));

      var result = await client.call(
          contract: uniswapFactoryContract,
          function: uniswapFactoryContract.function("getPool"),
          params: [
            EthereumAddress.fromHex(tokenFrom!.address),
            EthereumAddress.fromHex(tokenTo!.address),
            BigInt.from(3000)
          ]);
      DeployedContract uniswapPoolContract = DeployedContract(
          ContractAbi.fromJson(jsonEncode(UNISWAP_POOL), ""),
          EthereumAddress.fromHex(result[0].toString()));
      var fee = await client.call(
          contract: uniswapPoolContract,
          function: uniswapPoolContract.function("fee"),
          params: []);
      ContractAbi contractAbi =
          ContractAbi.fromJson(jsonEncode(UNISWAP_SWAP_ROUTER), "");
      DeployedContract deployedContract = DeployedContract(
          contractAbi,
          EthereumAddress.fromHex(
              "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"));
      var quote = await client.call(
          contract: deployedContract,
          function: deployedContract.function('getAmountsOut'),
          params: [
            // BigInt.parse("1000000000000"),
            EtherAmount.fromUnitAndValue(EtherUnit.wei,
                    (double.parse(inputAmount.text) * math.pow(10, 18)).toInt())
                .getValueInUnitBI(EtherUnit.wei),
            [
              EthereumAddress.fromHex(tokenFrom!.address),
              EthereumAddress.fromHex(tokenTo!.address),
            ]
          ]);

      log("Fee = ${fee[0].toString()} quote = ${quote.toString()}");
      log(tokenFrom!.address.toString());
      log(tokenTo!.address.toString());
      Navigator.of(context).pushNamed(SwapConfirmScreen.route, arguments: {
        "tokenInAmount": double.parse(inputAmount.text),
        "tokenOutAmount": (quote[0][1] as BigInt),
        "tokenFrom": tokenFrom,
        "tokenTo": tokenTo,
        "fee": fee[0]
      });
    } catch (e) {
      showErrorSnackBar(context, "Error in Get quotes", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
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
                    Text(AppLocalizations.of(context)!.swap,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(child: Text("")),
                  InkWell(
                    onTap: () {
                      openTokenSelectionSheet(true, state);
                    },
                    child: Container(
                      // width: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tokenFrom == null
                                ? AppLocalizations.of(context)!
                                    .selectTokenToSwap
                                : tokenFrom!.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox())
                ],
              ),
              const SizedBox(
                height: 10,
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
                height: 10,
              ),
              tokenBalance != null
                  ? Text(
                      "${EtherAmount.fromUnitAndValue(EtherUnit.wei, tokenBalance).getValueInUnit(EtherUnit.ether).toStringAsFixed(10)} ${tokenFrom?.symbol} ${AppLocalizations.of(context)!.availableToSwap}")
                  : const SizedBox(),
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
              InkWell(
                onTap: () {
                  openTokenSelectionSheet(false, state);
                },
                child: Container(
                  width: 170,
                  decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tokenTo == null
                            ? AppLocalizations.of(context)!.selectaToken
                            : tokenTo!.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(
                        Icons.arrow_drop_down_outlined,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Row(
                children: [
                  Expanded(
                    child: WalletButton(
                      textContent: AppLocalizations.of(context)!.getQuotes,
                      onPressed: tokenFrom != null && tokenTo != null
                          ? () {
                              getQuote();
                            }
                          : null,
                      type: WalletButtonType.filled,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }
}
