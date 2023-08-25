import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/abi.dart';
import 'package:wallet/core/bloc/collectible-bloc/cubit/collectible_cubit.dart';
import 'package:wallet/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/core/model/collectible_model.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/core/remote/http.dart';
import 'package:wallet/ui/gas-settings/gas_settings.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';
import 'package:wallet/ui/home/home_screen.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:wallet/utils.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum TransactionPriority { low, medium, high, custom }

class TransactionConfirmationScreen extends StatefulWidget {
  static const route = "transaction_confirmation_screen";
  final String to;
  final String from;
  final double value;
  final double balance;
  final String? contractAddress;
  final String? token;
  final Collectible? collectible;
  const TransactionConfirmationScreen(
      {Key? key,
      required this.to,
      required this.from,
      required this.value,
      required this.balance,
      this.token,
      this.contractAddress,
      this.collectible})
      : super(key: key);

  @override
  State<TransactionConfirmationScreen> createState() =>
      _TransactionConfirmationScreenState();
}

class _TransactionConfirmationScreenState
    extends State<TransactionConfirmationScreen> {
  double low = 1;
  double medium = 1.5;
  double high = 2;
  double selectedPriority = 0;
  double selectedMaxFee = 0;

  EtherAmount? estimatedGasInWei;
  EtherAmount? maxFeeInWei;

  double totalAmount = 0;
  int gasLimit = 21000;

  DeployedContract? _deployedContract;
  Token? selectedToken;
  Collectible? selectedCollectible;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TransactionPriority priority = TransactionPriority.medium;

  @override
  void initState() {
    setState(() {
      selectedPriority = medium;
      selectedMaxFee = medium;
      var state = (context.read<WalletCubit>().state as WalletLoaded);
      selectedMaxFee = (2 * 20) + double.parse("45.0");
      selectedPriority = double.parse("45.0");
      if (widget.token != state.currentNetwork.currency) {
        estimateGasFromContract().then((value) {
          estimatedGasInWei = EtherAmount.fromUnitAndValue(
              EtherUnit.wei, (medium * pow(10, 9)).toInt() * gasLimit);
          maxFeeInWei = EtherAmount.fromUnitAndValue(
              EtherUnit.wei, (medium * pow(10, 9)).toInt() * gasLimit);
          totalAmount = estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
          debugPrint((medium * pow(10, 8)).toString());
        });
      } else {
        getGasTrackerPrice().then((value) {
          setState(() {
            double basePrice = double.parse(value!.result.suggestBaseFee);
            high = double.parse(value.result.fastGasPrice) + basePrice;
            medium = double.parse(value.result.proposeGasPrice) + basePrice;
            low = double.parse(value.result.safeGasPrice) + basePrice;
            selectedMaxFee =
                (2 * basePrice) + double.parse(value.result.fastGasPrice);
            selectedPriority = double.parse(value.result.fastGasPrice);
            estimatedGasInWei = EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (medium * pow(10, 9)).toInt() * gasLimit);
            maxFeeInWei = EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (medium * pow(10, 9)).toInt() * gasLimit);
            totalAmount = widget.value +
                estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
          });
          // debug.log("High gas price $high");
        }).catchError((dynamic error) {
          debugPrint(error);
        });
      }
    });

    super.initState();
  }

  Future<void> estimateGasFromContract() async {
    var tokenCubit = context.read<TokenCubit>();
    var tokenState = context.read<TokenCubit>().state as TokenLoaded;
    var currentState = context.read<WalletCubit>().state as WalletLoaded;

    if (widget.token != null) {
      selectedToken = tokenState.tokens.firstWhere(
          (element) => element.tokenAddress == widget.contractAddress);
      var contractABI =
          ContractAbi.fromJson(jsonEncode(abi), widget.token.toString());
      _deployedContract = DeployedContract(
          contractABI, EthereumAddress.fromHex(selectedToken!.tokenAddress));
      var gasCall = _deployedContract?.function("transfer").encodeCall([
        EthereumAddress.fromHex(widget.to),
        BigInt.from((widget.value * pow(10, selectedToken!.decimal))),
      ]);
      // debugPrint(bytesToHex(gasCall!.toList()).toString());
      var gasRes = await tokenCubit.web3client.estimateGas(
        sender: currentState.wallet.privateKey.address,
        to: EthereumAddress.fromHex(selectedToken!.tokenAddress),
        data: gasCall,
      );
      setState(() {
        gasLimit = gasRes.toInt();
      });
    } else {
      var contractABI =
          ContractAbi.fromJson(jsonEncode(ERC721), widget.collectible!.name);

      _deployedContract = DeployedContract(contractABI,
          EthereumAddress.fromHex(widget.collectible!.tokenAddress));

      var gasRes = await currentState.web3client.estimateGas(
        sender: currentState.wallet.privateKey.address,
        to: EthereumAddress.fromHex(widget.collectible!.tokenAddress),
        data: _deployedContract?.function("transferFrom").encodeCall([
          EthereumAddress.fromHex(widget.from),
          EthereumAddress.fromHex(widget.to),
          BigInt.parse(widget.collectible!.tokenId),
        ]),
      );
      setState(() {
        gasLimit = gasRes.toInt();
      });
    }
  }

  changePriority(double newPriorityPrice, double newMaxFee,
      TransactionPriority newSelectedPriority, int selectedGas) {
    setState(() {
      priority = newSelectedPriority;
      selectedPriority = newPriorityPrice;
      selectedMaxFee = newMaxFee;
      gasLimit = selectedGas;
      estimatedGasInWei = EtherAmount.fromUnitAndValue(
          EtherUnit.wei, (selectedPriority * pow(10, 9)).toInt() * selectedGas);
      maxFeeInWei = EtherAmount.fromUnitAndValue(
          EtherUnit.wei, (newMaxFee * pow(10, 9)).toInt() * selectedGas);
      totalAmount =
          widget.value + estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
      debugPrint(selectedPriority.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            shadowColor: Colors.white,
            elevation: 0,
            backgroundColor: Colors.white,
            title: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Confirm transaction",
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
                            color:
                                (getWalletLoadedState(context)).currentNetwork.dotColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        getWalletLoadedState(context).currentNetwork.networkName,
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
            leading: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                )),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => kPrimaryColor.withAlpha(30)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(color: kPrimaryColor),
                ),
              )
            ]),
        body:
            BlocConsumer<WalletCubit, WalletState>(listener: (context, state) {
          if (state is WalletSendTransactionSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.route, (Route<dynamic> route) => false,
                arguments: {"password": state.password});
            showSuccessSnackbar(
                context,
                AppLocalizations.of(context)!.transactionSubmitted,
                AppLocalizations.of(context)!.waitingForConfirmation);
          }
          if (state is WalletSendTransactionFailed) {
            showErrorSnackBar(context,
                AppLocalizations.of(context)!.transactionFailed, state.error);
          }
        }, builder: (context, state) {
          return BlocListener<CollectibleCubit, CollectibleState>(
            listener: (context, state) async {
              if (state is CollectibleTransfer) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    HomeScreen.route, (Route<dynamic> route) => false,
                    arguments: {
                      "password": getWalletLoadedState(context).password
                    });
                showSuccessSnackbar(
                    context,
                    AppLocalizations.of(context)!.transactionSubmitted,
                    AppLocalizations.of(context)!.waitingForConfirmation);
                return;
              }
              if (state is CollectibleError) {
                showErrorSnackBar(
                    context,
                    AppLocalizations.of(context)!.transactionFailed,
                    state.error);
              }
            },
            child: BlocListener<TokenCubit, TokenState>(
              listener: (context, state) {
                if (state is TokenTransfered) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      HomeScreen.route, (Route<dynamic> route) => false,
                      arguments: {
                        "password": getWalletLoadedState(context).password
                      });
                  showSuccessSnackbar(
                      context,
                      AppLocalizations.of(context)!.transactionSubmitted,
                      AppLocalizations.of(context)!.waitingForConfirmation);
                  return;
                }
                if (state is TokenError) {
                  showErrorSnackBar(
                      context,
                      AppLocalizations.of(context)!.transactionFailed,
                      state.error);
                }
              },
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text("${AppLocalizations.of(context)!.from}:"),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withAlpha(60))),
                                  child: Row(
                                    children: [
                                      AvatarWidget(
                                        radius: 40,
                                        address: getWalletLoadedState(context)
                                            .wallet.privateKey.address.hex,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              showEllipse(widget.from),
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                                "${AppLocalizations.of(context)!.balance}: ${widget.balance} ${getWalletLoadedState(context).currentNetwork.currency}"),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text("${AppLocalizations.of(context)!.to}:     "),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withAlpha(60))),
                                  child: Row(
                                    children: [
                                      AvatarWidget(
                                        radius: 40,
                                        address: widget.to,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  showEllipse(widget.to),
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: Colors.grey.withAlpha(60),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        widget.token != null
                            ? Text(
                                AppLocalizations.of(context)!
                                    .amount
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w100),
                              )
                            : Text(
                                "${widget.collectible?.name}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w100),
                              ),
                        widget.token != null
                            ? Text(
                                "${widget.value.toString()} ${widget.token ?? "ETH"}",
                                style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.normal),
                              )
                            : Text(
                                "#${widget.collectible?.tokenId}",
                                style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.normal),
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: kPrimaryColor),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .estimatedGasFee,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          return GasSettings(
                                            maxFeeInWei: maxFeeInWei!,
                                            maxFee: selectedMaxFee,
                                            maxPriority: selectedPriority,
                                            gasLimit: gasLimit,
                                            priority: priority,
                                            estimatedGasInWei:
                                                estimatedGasInWei!,
                                            changePriority: changePriority,
                                            low: low,
                                            medium: medium,
                                            high: high,
                                            token: widget.collectible
                                                        ?.tokenAddress !=
                                                    null
                                                ? widget
                                                    .collectible!.tokenAddress
                                                : widget.token!,
                                            onAdvanceOptionClicked: () {
                                              Navigator.of(context).pop();
                                              _scaffoldKey.currentState
                                                  ?.showBottomSheet((context) {
                                                return GasSettings(
                                                    maxFeeInWei: maxFeeInWei!,
                                                    maxFee: selectedMaxFee,
                                                    maxPriority:
                                                        selectedPriority,
                                                    gasLimit: gasLimit,
                                                    priority: priority,
                                                    estimatedGasInWei:
                                                        estimatedGasInWei!,
                                                    token: widget.collectible
                                                                ?.tokenAddress !=
                                                            null
                                                        ? widget.collectible!
                                                            .tokenAddress
                                                        : widget.token!,
                                                    changePriority:
                                                        changePriority,
                                                    showAdvance: true,
                                                    low: low,
                                                    medium: medium,
                                                    high: high);
                                              });
                                            },
                                          );
                                        },
                                        enableDrag: false,
                                        isScrollControlled: false,
                                      );
                                    },
                                    child: Text(
                                      "${estimatedGasInWei?.getValueInUnit(EtherUnit.ether).toDouble().toStringAsFixed(6)} ${getWalletLoadedState(context).currentNetwork.currency}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    priority == TransactionPriority.medium
                                        ? AppLocalizations.of(context)!
                                            .likelyIn30Second
                                        : priority == TransactionPriority.low
                                            ? AppLocalizations.of(context)!
                                                .mayBeIn30Second
                                            : priority ==
                                                    TransactionPriority.high
                                                ? AppLocalizations.of(context)!
                                                    .likelyIn15Second
                                                : "Custom gas fee",
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        color: priority ==
                                                    TransactionPriority.low ||
                                                priority ==
                                                    TransactionPriority.custom
                                            ? Colors.red
                                            : Colors.green),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.maxFee}: ",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          "${maxFeeInWei?.getValueInUnit(EtherUnit.ether).toDouble().toStringAsFixed(6)} ${getWalletLoadedState(context).currentNetwork.currency}"),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: Colors.grey.withAlpha(60),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.total,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                   Text(
                                    "$totalAmount ${getWalletLoadedState(context).currentNetwork.currency}",
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(child: SizedBox()),
                                  Row(
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.maxAmount}: ",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          "${maxFeeInWei?.getValueInUnit(EtherUnit.ether)} ${getWalletLoadedState(context).currentNetwork.currency}")
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        WalletButton(
                            type: WalletButtonType.filled,
                            textContent: "Confirm and Approve",
                            onPressed: () {
                              if (widget.token ==
                                  getWalletLoadedState(context).currentNetwork.currency) {
                                context.read<WalletCubit>().sendTransaction(
                                    widget.to,
                                    widget.value,
                                    selectedPriority,
                                    selectedMaxFee,
                                    gasLimit);
                                return;
                              }
                              if (widget.collectible != null) {
                                // print_debug.log("message");
                                context
                                    .read<CollectibleCubit>()
                                    .sendNFTTransaction(
                                        widget.to,
                                        widget.from,
                                        widget.value,
                                        gasLimit,
                                        selectedPriority,
                                        selectedMaxFee,
                                        widget.collectible!,
                                        getWalletLoadedState(context).wallet,
                                        getWalletLoadedState(context)
                                            .currentNetwork);
                              } else {
                                print("GAS LIMIT $gasLimit");
                                context.read<TokenCubit>().sendTokenTransaction(
                                    widget.to,
                                    widget.value,
                                    gasLimit,
                                    selectedPriority,
                                    selectedMaxFee,
                                    selectedToken!,
                                    _deployedContract!,
                                    getWalletLoadedState(context).wallet,
                                    getWalletLoadedState(context)
                                        .currentNetwork);
                              }
                            }),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }));
  }
}

var abi = [
  {"type": "constructor", "stateMutability": "nonpayable", "inputs": []},
  {
    "type": "event",
    "name": "Approval",
    "inputs": [
      {
        "type": "address",
        "name": "owner",
        "internalType": "address",
        "indexed": true
      },
      {
        "type": "address",
        "name": "spender",
        "internalType": "address",
        "indexed": true
      },
      {
        "type": "uint256",
        "name": "value",
        "internalType": "uint256",
        "indexed": false
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Transfer",
    "inputs": [
      {
        "type": "address",
        "name": "from",
        "internalType": "address",
        "indexed": true
      },
      {
        "type": "address",
        "name": "to",
        "internalType": "address",
        "indexed": true
      },
      {
        "type": "uint256",
        "name": "value",
        "internalType": "uint256",
        "indexed": false
      }
    ],
    "anonymous": false
  },
  {
    "type": "function",
    "stateMutability": "view",
    "outputs": [
      {"type": "uint256", "name": "", "internalType": "uint256"}
    ],
    "name": "allowance",
    "inputs": [
      {"type": "address", "name": "owner", "internalType": "address"},
      {"type": "address", "name": "spender", "internalType": "address"}
    ]
  },
  {
    "type": "function",
    "stateMutability": "nonpayable",
    "outputs": [
      {"type": "bool", "name": "", "internalType": "bool"}
    ],
    "name": "approve",
    "inputs": [
      {"type": "address", "name": "spender", "internalType": "address"},
      {"type": "uint256", "name": "amount", "internalType": "uint256"}
    ]
  },
  {
    "type": "function",
    "stateMutability": "view",
    "outputs": [
      {"type": "uint256", "name": "", "internalType": "uint256"}
    ],
    "name": "balanceOf",
    "inputs": [
      {"type": "address", "name": "account", "internalType": "address"}
    ]
  },
  {
    "type": "function",
    "stateMutability": "view",
    "outputs": [
      {"type": "uint8", "name": "", "internalType": "uint8"}
    ],
    "name": "decimals",
    "inputs": []
  },
  {
    "type": "function",
    "stateMutability": "nonpayable",
    "outputs": [
      {"type": "bool", "name": "", "internalType": "bool"}
    ],
    "name": "decreaseAllowance",
    "inputs": [
      {"type": "address", "name": "spender", "internalType": "address"},
      {"type": "uint256", "name": "subtractedValue", "internalType": "uint256"}
    ]
  },
  {
    "type": "function",
    "stateMutability": "nonpayable",
    "outputs": [
      {"type": "bool", "name": "", "internalType": "bool"}
    ],
    "name": "increaseAllowance",
    "inputs": [
      {"type": "address", "name": "spender", "internalType": "address"},
      {"type": "uint256", "name": "addedValue", "internalType": "uint256"}
    ]
  },
  {
    "type": "function",
    "stateMutability": "view",
    "outputs": [
      {"type": "string", "name": "", "internalType": "string"}
    ],
    "name": "name",
    "inputs": []
  },
  {
    "type": "function",
    "stateMutability": "view",
    "outputs": [
      {"type": "string", "name": "", "internalType": "string"}
    ],
    "name": "symbol",
    "inputs": []
  },
  {
    "type": "function",
    "stateMutability": "view",
    "outputs": [
      {"type": "uint256", "name": "", "internalType": "uint256"}
    ],
    "name": "totalSupply",
    "inputs": []
  },
  {
    "type": "function",
    "stateMutability": "nonpayable",
    "outputs": [
      {"type": "bool", "name": "", "internalType": "bool"}
    ],
    "name": "transfer",
    "inputs": [
      {"type": "address", "name": "recipient", "internalType": "address"},
      {"type": "uint256", "name": "amount", "internalType": "uint256"}
    ]
  },
  {
    "type": "function",
    "stateMutability": "nonpayable",
    "outputs": [
      {"type": "bool", "name": "", "internalType": "bool"}
    ],
    "name": "transferFrom",
    "inputs": [
      {"type": "address", "name": "sender", "internalType": "address"},
      {"type": "address", "name": "recipient", "internalType": "address"},
      {"type": "uint256", "name": "amount", "internalType": "uint256"}
    ]
  }
];
