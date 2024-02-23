// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/abi.dart';
import 'package:wallet_cryptomask/core/bloc/collectible_provider/collectible_provider.dart';
import 'package:wallet_cryptomask/core/bloc/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/gas-settings/gas_settings.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/home/home_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:web3dart/web3dart.dart';

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
  bool readyToConfirm = false;

  EtherAmount? estimatedGasInWei;
  EtherAmount? maxFeeInWei;

  double totalAmount = 0;
  int gasLimit = 21000;

  DeployedContract? _deployedContract;
  Token? selectedToken;
  Collectible? selectedCollectible;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TransactionPriority priority = TransactionPriority.medium;

  estimateGasDetailForNative() async {
    final state = Provider.of<WalletProvider>(context, listen: false);
    if (state.activeNetwork.supportsEip1559) {
      final basePriceInNative = await state.web3client.getGasPrice();
      final basePrice = basePriceInNative.getValueInUnit(EtherUnit.gwei);
      setState(() {
        high = double.parse("3") + basePrice;
        medium = double.parse("2") + basePrice;
        low = double.parse("1") + basePrice;
        selectedMaxFee = double.parse("2");
        selectedPriority = double.parse("2");
        estimatedGasInWei = EtherAmount.fromUnitAndValue(
            EtherUnit.wei, (medium * pow(10, 9)).toInt() * gasLimit);
        maxFeeInWei = EtherAmount.fromUnitAndValue(
            EtherUnit.wei, (medium * pow(10, 9)).toInt() * gasLimit);
        totalAmount =
            widget.value + estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
        readyToConfirm = true;
      });
    } else {
      final basePriceInNative = await state.web3client.getGasPrice();
      double basePrice = basePriceInNative.getValueInUnit(EtherUnit.gwei);
      setState(() {
        estimatedGasInWei = EtherAmount.fromUnitAndValue(
            EtherUnit.wei, (basePrice * pow(10, 9)).toInt() * gasLimit);
        totalAmount =
            widget.value + estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
        readyToConfirm = true;
      });
    }
  }

  estimateGasDetailsForTokenAndNFT() {
    estimateGasFromContract().then((amount) {
      Provider.of<WalletProvider>(context, listen: false)
          .web3client
          .getGasPrice()
          .then((basePriceInEthAmount) {
        if (Provider.of<WalletProvider>(context, listen: false)
            .activeNetwork
            .supportsEip1559) {
          double basePrice =
              basePriceInEthAmount.getValueInUnit(EtherUnit.gwei);
          high = double.parse("3") + basePrice;
          medium = double.parse("2") + basePrice;
          low = double.parse("1") + basePrice;
          selectedMaxFee = double.parse("2");
          selectedPriority = double.parse("2");
          estimatedGasInWei = EtherAmount.fromUnitAndValue(
              EtherUnit.wei, (medium * pow(10, 9)).toInt() * amount);
          maxFeeInWei = EtherAmount.fromUnitAndValue(
              EtherUnit.wei, (medium * pow(10, 9)).toInt() * amount);
          totalAmount = estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
          readyToConfirm = true;
          setState(() {});
        } else {
          Provider.of<WalletProvider>(context)
              .web3client
              .getGasPrice()
              .then((basePriceInNative) {
            double basePrice = basePriceInNative.getValueInUnit(EtherUnit.gwei);
            setState(() {
              estimatedGasInWei = EtherAmount.fromUnitAndValue(
                  EtherUnit.wei, (basePrice * pow(10, 9)).toInt() * gasLimit);
              totalAmount = widget.value +
                  estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
              readyToConfirm = true;
            });
          });
        }
      });
    });
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        selectedPriority = medium;
        selectedMaxFee = medium;
        selectedMaxFee = (2 * 20) + double.parse("45.0");
        selectedPriority = double.parse("45.0");
        if (widget.token !=
            Provider.of<WalletProvider>(context, listen: false)
                .activeNetwork
                .currency) {
          estimateGasDetailsForTokenAndNFT();
        } else {
          estimateGasDetailForNative();
        }
      });
    });

    super.initState();
  }

  Future<int> estimateGasFromContract() async {
    if (widget.token != null) {
      selectedToken = Provider.of<TokenProvider>(context, listen: false)
          .tokens
          .firstWhere(
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
      var gasRes = await Provider.of<WalletProvider>(context, listen: false)
          .web3client
          .estimateGas(
            sender: Provider.of<WalletProvider>(context, listen: false)
                .activeWallet
                .wallet
                .privateKey
                .address,
            to: EthereumAddress.fromHex(selectedToken!.tokenAddress),
            data: gasCall,
          );
      setState(() {
        gasLimit = gasRes.toInt();
      });
      return gasRes.toInt();
    } else {
      var contractABI =
          ContractAbi.fromJson(jsonEncode(ERC721), widget.collectible!.name);
      _deployedContract = DeployedContract(contractABI,
          EthereumAddress.fromHex(widget.collectible!.tokenAddress));

      var gasRes = await Provider.of<WalletProvider>(context, listen: false)
          .web3client
          .estimateGas(
            sender: Provider.of<WalletProvider>(context, listen: false)
                .activeWallet
                .wallet
                .privateKey
                .address,
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
      return gasRes.toInt();
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

  onConfirmAndApprove() {
    // Transaction Native currency
    try {
      if (widget.token ==
          Provider.of<WalletProvider>(context, listen: false)
              .activeNetwork
              .symbol) {
        Provider.of<WalletProvider>(context, listen: false)
            .sendTransaction(widget.to, widget.value, selectedPriority,
                selectedMaxFee, gasLimit)
            .then((txHash) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          showPositiveSnackBar(context, 'Success',
              'Transaction with $txHash is sumbitted to the network');
        }).catchError((e) {
          showErrorSnackBar(context, "Transaction failed",
              'Transaction is failed sumbit to the network');
        });

        return;
      }
      // Transaction NFT
      if (widget.collectible != null) {
        Provider.of<CollectibleProvider>(context, listen: false)
            .sendNFTTransaction(
                widget.to,
                widget.from,
                widget.value,
                gasLimit,
                selectedPriority,
                selectedMaxFee,
                widget.collectible!,
                Provider.of<WalletProvider>(context, listen: false)
                    .activeWallet
                    .wallet,
                Provider.of<WalletProvider>(context, listen: false)
                    .activeNetwork)
            .then((txHash) {
          if (txHash != null) {
            if (kDebugMode) {
              print(txHash);
            }
            showPositiveSnackBar(context, "Transaction sumbitted",
                "Transaction with hash ${showEllipse(txHash)} has been submitted successfully");
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.route,
              (route) => false,
            );
          }
        }).catchError((e) {
          showErrorSnackBar(context, "Transaction failed", e.toString());
        });
        return;
      }
      // Transaction Token
      Provider.of<TokenProvider>(context, listen: false)
          .sendTokenTransaction(
              widget.to,
              widget.value,
              gasLimit,
              selectedPriority,
              selectedMaxFee,
              selectedToken!,
              _deployedContract!,
              Provider.of<WalletProvider>(context, listen: false)
                  .activeWallet
                  .wallet,
              Provider.of<WalletProvider>(context, listen: false).activeNetwork)
          .then((txHash) {
        if (txHash != null) {
          if (kDebugMode) {
            print(txHash);
          }
          showPositiveSnackBar(context, "Transaction sumbitted",
              "Transaction with hash ${showEllipse(txHash)} has been submitted successfully");
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.route,
            (route) => false,
          );
        }
      }).catchError((e) {
        showErrorSnackBar(context, "Transaction failed", e.toString());
      });
    } catch (e) {
      showErrorSnackBar(context, "Failed", e.toString());
    }
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
                          color: (Provider.of<WalletProvider>(context)
                              .activeNetwork
                              .dotColor),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      Provider.of<WalletProvider>(context)
                          .activeNetwork
                          .networkName,
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
      body: SizedBox(
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
                                  width: 1, color: Colors.grey.withAlpha(60))),
                          child: Row(
                            children: [
                              AvatarWidget(
                                radius: 40,
                                address: Provider.of<WalletProvider>(context)
                                    .activeWallet
                                    .wallet
                                    .privateKey
                                    .address
                                    .hex,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      showEllipse(widget.from),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                        "${AppLocalizations.of(context)!.balance}: ${widget.balance} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}"),
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
                                  width: 1, color: Colors.grey.withAlpha(60))),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          showEllipse(widget.to),
                                          style: const TextStyle(fontSize: 16),
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
                        AppLocalizations.of(context)!.amount.toUpperCase(),
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
                            fontSize: 40, fontWeight: FontWeight.normal),
                      )
                    : Text(
                        "#${widget.collectible?.tokenId}",
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.normal),
                      ),
                const SizedBox(
                  height: 10,
                ),
                !readyToConfirm
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.estimatedGasFee,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    Provider.of<WalletProvider>(context,
                                                listen: false)
                                            .activeNetwork
                                            .supportsEip1559
                                        ? showModalBottomSheet(
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
                                                    ? widget.collectible!
                                                        .tokenAddress
                                                    : widget.token!,
                                                onAdvanceOptionClicked: () {
                                                  Navigator.of(context).pop();
                                                  _scaffoldKey.currentState
                                                      ?.showBottomSheet(
                                                          (context) {
                                                    return GasSettings(
                                                        maxFeeInWei:
                                                            maxFeeInWei!,
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
                                                            ? widget
                                                                .collectible!
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
                                          )
                                        : null;
                                  },
                                  child: Text(
                                    "${estimatedGasInWei?.getValueInUnit(EtherUnit.ether).toDouble().toStringAsFixed(15)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
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
                            Provider.of<WalletProvider>(context)
                                    .activeNetwork
                                    .supportsEip1559
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        priority == TransactionPriority.medium
                                            ? AppLocalizations.of(context)!
                                                .likelyIn30Second
                                            : priority ==
                                                    TransactionPriority.low
                                                ? AppLocalizations.of(context)!
                                                    .mayBeIn30Second
                                                : priority ==
                                                        TransactionPriority.high
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .likelyIn15Second
                                                    : "Custom gas fee",
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.bold,
                                            color: priority ==
                                                        TransactionPriority
                                                            .low ||
                                                    priority ==
                                                        TransactionPriority
                                                            .custom
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
                                              "${maxFeeInWei?.getValueInUnit(EtherUnit.ether).toDouble().toStringAsFixed(6)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}"),
                                        ],
                                      ),
                                    ],
                                  )
                                : SizedBox(),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.total,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${widget.token != null ? '${widget.value} ${selectedToken?.symbol} + ' : ''} ${totalAmount.toStringAsFixed(6)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Provider.of<WalletProvider>(context)
                                    .activeNetwork
                                    .supportsEip1559
                                ? Row(
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
                                              "${maxFeeInWei?.getValueInUnit(EtherUnit.ether).toStringAsFixed(6)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}")
                                        ],
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                const Expanded(child: SizedBox()),
                Provider.of<WalletProvider>(context).loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : WalletButton(
                        type: WalletButtonType.filled,
                        localizeKey: "confirmAndApprove",
                        onPressed: readyToConfirm ? onConfirmAndApprove : null),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
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
