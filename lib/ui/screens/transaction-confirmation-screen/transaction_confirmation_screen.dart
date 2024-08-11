// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/avatar_widget.dart';
import 'package:wallet_cryptomask/ui/screens/home-screen/home_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
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
  int? manualEstimation;
  bool isNative = true;

  EtherAmount? estimatedGasInWei;
  EtherAmount? maxFeeInWei;

  double totalAmount = 0;
  int gasLimit = 21000;

  //FEE
  double platformFeePercentage = 0;
  EtherAmount platformFeeForNative = EtherAmount.zero();
  double platformFeeForToken = 0;
  EthereumAddress? adminAddress;

  DeployedContract? _deployedContract;
  Token? selectedToken;
  Collectible? selectedCollectible;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TransactionPriority priority = TransactionPriority.medium;

  estimateGasDetailForNative() async {
    final state = Provider.of<WalletProvider>(context, listen: false);

    final basePriceInNative = await state.web3client.getGasPrice();
    double basePrice = basePriceInNative.getValueInUnit(EtherUnit.gwei);
    setState(() {
      estimatedGasInWei = EtherAmount.fromUnitAndValue(
          EtherUnit.wei, (basePrice * pow(10, 9)).toInt() * gasLimit);
      totalAmount =
          widget.value + estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
    });
    estimatePlatformFee();
  }

  estimateGasDetailsForTokenAndNFT() {
    estimateGasFromContract().then((amount) {
      getWalletProvider(context)
          .web3client
          .getGasPrice()
          .then((basePriceInEthAmount) {
        getWalletProvider(context)
            .web3client
            .getGasPrice()
            .then((basePriceInNative) {
          double basePrice = basePriceInNative.getValueInUnit(EtherUnit.gwei);
          setState(() {
            estimatedGasInWei = EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (basePrice * pow(10, 9)).toInt() * gasLimit);
            totalAmount = widget.value +
                estimatedGasInWei!.getValueInUnit(EtherUnit.ether);
            estimatePlatformFee();
          });
        });
      });
    });
  }

  estimatePlatformFee() {
    RemoteServer.getPlatformFee().then((platformFeeData) {
      setState(() {
        platformFeePercentage = platformFeeData.data.fee;
        adminAddress =
            EthereumAddress.fromHex(platformFeeData.data.adminAddress);
        if (isNative) {
          if (widget.value != 0 && platformFeePercentage != 0) {
            final percentageValue =
                (platformFeePercentage / 100) * widget.value;
            BigInt weiValue = BigInt.from(percentageValue * 1e18);
            platformFeeForNative = EtherAmount.inWei(weiValue);
            totalAmount = totalAmount +
                platformFeeForNative.getValueInUnit(EtherUnit.ether);
          }
        } else {
          platformFeeForToken = (platformFeePercentage / 100) * widget.value;
        }
        readyToConfirm = true;
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
          setState(() {
            isNative = false;
          });
          estimateGasDetailsForTokenAndNFT();
        } else {
          estimateGasDetailForNative();
        }
      });
    });

    super.initState();
  }

  Future<int> estimateGasFromContract() async {
    selectedToken = getTokenProvider(context).tokens.firstWhere(
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
    try {
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
    } catch (e) {
      setState(() {
        gasLimit = 100000;
        manualEstimation = 100000;
      });
      return 100000;
    }
  }

  onConfirmAndApprove() {
    try {
      final walletProvider = getWalletProvider(context);
      getWalletProvider(context).showLoading();

      // Transaction Native currency
      if (isNative) {
        if (platformFeePercentage > 0) {
          // SENDING ADMIN FEE
          walletProvider
              .sendTransaction(
                  adminAddress!.hex,
                  platformFeeForNative.getValueInUnit(EtherUnit.ether),
                  selectedPriority,
                  selectedMaxFee,
                  gasLimit,
                  true)
              .then((feeHash) async {
            if (feeHash == null) {
              walletProvider.hideLoading();
              showErrorSnackBar(context, getText(context, key: 'error'),
                  'Something went wrong, May be you don\'t have enough balance');
              return;
            }
            await getTransactionReceiptFromHash(context, feeHash);

            // SUBMITTING ACTUAL TRANSACTION
            walletProvider
                .sendTransaction(widget.to, widget.value, selectedPriority,
                    selectedMaxFee, gasLimit, false)
                .then((txHash) {
              getWalletProvider(context).hideLoading();
              context.popUntil(HomeScreen);
              showPositiveSnackBar(
                context,
                getText(context, key: 'success'),
                getTextWithPlaceholder(context,
                    key: 'txSubmitted', string: txHash ?? ""),
              );
            }).catchError((e) {
              showErrorSnackBar(
                  context,
                  getText(context, key: 'transactionFailed1'),
                  getText(context, key: 'transactionFailedMessage'));
            });
          }).catchError((e) {
            showErrorSnackBar(
                context,
                getText(context, key: 'transactionFailed1'),
                getText(context, key: 'transactionFailedMessage'));
          });
        } else {
          walletProvider
              .sendTransaction(widget.to, widget.value, selectedPriority,
                  selectedMaxFee, gasLimit, false)
              .then((txHash) {
            getWalletProvider(context).hideLoading();
            context.popUntil(HomeScreen);
            showPositiveSnackBar(
              context,
              getText(context, key: 'success'),
              getTextWithPlaceholder(context,
                  key: 'txSubmitted', string: txHash ?? ""),
            );
          }).catchError((e) {
            showErrorSnackBar(
              context,
              getText(context, key: 'transactionFailed1'),
              getText(context, key: 'transactionFailedMessage'),
            );
          });
        }
      } else {
        final tokenProvider = getTokenProvider(context);
        if (platformFeePercentage > 0) {
          // Submitting fee transaction
          tokenProvider
              .sendTokenTransaction(
                  adminAddress!.hex,
                  platformFeeForToken,
                  gasLimit,
                  selectedPriority,
                  selectedMaxFee,
                  selectedToken!,
                  _deployedContract!,
                  Provider.of<WalletProvider>(context, listen: false)
                      .activeWallet
                      .wallet,
                  Provider.of<WalletProvider>(context, listen: false)
                      .activeNetwork,
                  true)
              .then((feeHash) async {
            if (feeHash == null) {
              return;
            }
            await getTransactionReceiptFromHash(context, feeHash);
            // Submitting actual transaction
            tokenProvider
                .sendTokenTransaction(
                    widget.to,
                    widget.value,
                    gasLimit,
                    selectedPriority,
                    selectedMaxFee,
                    selectedToken!,
                    _deployedContract!,
                    walletProvider.activeWallet.wallet,
                    walletProvider.activeNetwork,
                    false)
                .then((txHash) {
              getWalletProvider(context).hideLoading();
              if (txHash != null) {
                if (kDebugMode) {
                  print(txHash);
                }
                showPositiveSnackBar(
                  context,
                  getText(context, key: 'success'),
                  getTextWithPlaceholder(context,
                      key: 'txSubmitted', string: txHash),
                );
                context.popUntil(HomeScreen);
              }
            }).catchError((e) {
              showErrorSnackBar(context,
                  getText(context, key: 'transactionFailed1'), e.toString());
            });
          }).catchError((e) {
            showErrorSnackBar(context,
                getText(context, key: 'transactionFailed1'), e.toString());
          });
        } else {
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
                  Provider.of<WalletProvider>(context, listen: false)
                      .activeNetwork,
                  false)
              .then((txHash) {
            getWalletProvider(context).hideLoading();
            if (txHash != null) {
              if (kDebugMode) {
                print(txHash);
              }
              showPositiveSnackBar(
                context,
                getText(context, key: 'success'),
                getTextWithPlaceholder(context,
                    key: 'txSubmitted', string: txHash),
              );
              context.popUntil(HomeScreen);
            }
          }).catchError((e) {
            showErrorSnackBar(context,
                getText(context, key: 'transactionFailed1'), e.toString());
          });
        }
      }
    } catch (e) {
      showErrorSnackBar(
          context, getText(context, key: 'transactionFailed1'), e.toString());
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
                const WalletText(
                    localizeKey: 'confirmTransaction',
                    size: 16,
                    fontWeight: FontWeight.w200,
                    color: Colors.black),
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
                    addWidth(SpacingSize.xs),
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
              child:
                  const WalletText(localizeKey: 'cancel', color: kPrimaryColor),
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
                addHeight(SpacingSize.m),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const WalletText(
                        localizeKey: 'from',
                      ),
                      addHeight(SpacingSize.s),
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
                              addWidth(SpacingSize.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      showEllipse(widget.from),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                        "${getText(context, key: 'balance')}: ${getWalletProvider(context).nativeBalance.toStringAsFixed(4)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}"),
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
                addHeight(SpacingSize.s),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text("${getText(context, key: 'to')}:     "),
                      addWidth(SpacingSize.s),
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
                              addWidth(SpacingSize.s),
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
                addHeight(SpacingSize.s),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.withAlpha(60),
                ),
                addHeight(SpacingSize.m),
                widget.token != null
                    ? WalletText(
                        localizeKey:
                            getText(context, key: 'amount').toUpperCase(),
                        size: 14,
                        fontWeight: FontWeight.w100)
                    : Text(
                        "${widget.collectible?.name}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w100),
                      ),
                widget.token != null
                    ? Text(
                        "${widget.value.toString()} ${widget.token ?? getWalletProvider(context).activeNetwork.symbol}",
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.normal),
                      )
                    : Text(
                        "#${widget.collectible?.tokenId}",
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.normal),
                      ),
                addHeight(SpacingSize.s),
                !readyToConfirm
                    ? const SafeArea(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
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
                                const WalletText(
                                    localizeKey: 'estimatedGasFee',
                                    fontWeight: FontWeight.bold),
                                Text(
                                  "${estimatedGasInWei?.getValueInUnit(EtherUnit.ether).toDouble().toStringAsFixed(15)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            addHeight(SpacingSize.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const WalletText(
                                  localizeKey: 'platformFee',
                                  fontWeight: FontWeight.bold,
                                ),
                                Text(
                                  isNative
                                      ? "${platformFeeForNative.getValueInUnit(EtherUnit.ether).toStringAsFixed(8)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol} ($platformFeePercentage%)"
                                      : "$platformFeeForToken ${selectedToken!.symbol}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            addHeight(SpacingSize.xs),
                            addHeight(SpacingSize.s),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.grey.withAlpha(60),
                            ),
                            addHeight(SpacingSize.s),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const WalletText(
                                    localizeKey: 'total',
                                    fontWeight: FontWeight.bold),
                                Text(
                                  "${widget.token != null && widget.token != Provider.of<WalletProvider>(context).activeNetwork.currency ? '${widget.value + platformFeeForToken} ${selectedToken?.symbol} + ' : ''} ${totalAmount.toStringAsFixed(6)} ${Provider.of<WalletProvider>(context).activeNetwork.symbol}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            addHeight(SpacingSize.xs),
                          ],
                        ),
                      ),
                manualEstimation != null
                    ? renderAlert(context, null, null,
                        localizeKey: 'failedToEstimated')
                    : const SizedBox(),
                const Expanded(child: SizedBox()),
                Provider.of<WalletProvider>(context).loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SafeArea(
                        child: WalletButton(
                            type: WalletButtonType.filled,
                            localizeKey: "confirmAndApprove",
                            onPressed:
                                readyToConfirm ? onConfirmAndApprove : null),
                      ),
                addHeight(SpacingSize.m),
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
