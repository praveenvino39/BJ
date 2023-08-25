// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/model/collectible_model.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/ui/amount/amount_screen.dart';
import 'package:wallet/ui/home/component/account_change_sheet.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';
import 'package:wallet/ui/scan/scanner_screen.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:wallet/ui/transaction-confirmation/transaction_confirmation.dart';
import 'package:wallet/ui/transfer/component/receiver_address_suggest_widget.dart';
import 'package:wallet/utils.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TransferScreen extends StatefulWidget {
  static const route = "transfer_screen";
  String balance;
  final Token? token;
  final Collectible? collectible;
  TransferScreen(
      {Key? key, required this.balance, this.token, this.collectible})
      : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  bool isAddressValid = false;
  final TextEditingController _address = TextEditingController();
  List<dynamic> recentTransactionAddress = [];

  @override
  void initState() {
    Hive.openBox("user_preference").then((box) {
      setState(() {
        recentTransactionAddress = box.get("RECENT-TRANSACTION-ADDRESS", defaultValue: []);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
                shadowColor: Colors.white,
                elevation: 0,
                backgroundColor: Colors.white,
                title: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("${AppLocalizations.of(context)!.send} to",
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
                leading: const IconButton(
                    onPressed: null,
                    icon: Icon(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      address:
                                          state.wallet.privateKey.address.hex,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) =>
                                                AccountChangeSheet(
                                              onChange: ((address) async {
                                                var ethBalance = await state
                                                    .web3client
                                                    .getBalance(
                                                        EthereumAddress.fromHex(
                                                            address));
                                                setState(() {
                                                  widget.balance = ethBalance
                                                      .getValueInUnit(
                                                          EtherUnit.ether)
                                                      .toString();
                                                });
                                              }),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Account 1",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                                "${AppLocalizations.of(context)!.balance}: ${widget.balance} ${state.currentNetwork.currency}"),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down)
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
                            Text("${AppLocalizations.of(context)!.to}:"),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _address,
                                      onChanged: (enteredAdress) {
                                        setState(() {
                                          isAddressValid =
                                              isValidAddress(enteredAdress) &&
                                                  enteredAdress.length == 42;
                                        });
                                      },
                                      validator: (String? string) {
                                        if (string?.isEmpty == true) {
                                          return AppLocalizations.of(context)!
                                              .thisFieldNotEmpty;
                                        }
                                        if (string!.length != 42) {
                                          return AppLocalizations.of(context)!
                                              .passwordMustContain;
                                        }
                                        return null;
                                      },
                                      cursorColor: kPrimaryColor,
                                      decoration: InputDecoration(
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .searchPublicAddress,
                                          hintStyle:
                                              const TextStyle(fontSize: 12),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 20),
                                          suffixIcon: isAddressValid
                                              ? SizedBox(
                                                  width: 65,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                      ),
                                                      const SizedBox(
                                                        width: 7,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          _address.text = "";
                                                          setState(() {
                                                            isAddressValid =
                                                                false;
                                                          });
                                                        },
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 7,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : IconButton(
                                                  onPressed: (() => Navigator
                                                          .of(context)
                                                      .push(MaterialPageRoute(
                                                          builder: (context) =>
                                                              ScannerScreen(
                                                                  onQrDecode:
                                                                      (address) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();

                                                                _address.text =
                                                                    address;
                                                                setState(() {
                                                                  isAddressValid =
                                                                      true;
                                                                });
                                                              })))),
                                                  icon: const Icon(
                                                    Icons.qr_code,
                                                    color: kPrimaryColor,
                                                  ),
                                                ),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey
                                                      .withAlpha(70))),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: kPrimaryColor)),
                                          errorBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: kPrimaryColor)),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide())),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ReceiverAddressSuggestionWidget(
                          recentTransactionList: recentTransactionAddress.reversed.toList(),
                          isAddressValid: isAddressValid,
                          onAccountSelect: (address) {
                            _address.text = address;
                            setState(() {
                              isAddressValid = true;
                            });
                          }),
                      WalletButton(
                          type: WalletButtonType.filled,
                          textContent: "Next",
                          onPressed: isAddressValid
                              ? () {
                                  if (widget.token != null) {
                                    Navigator.of(context).pushNamed(
                                        AmountScreen.route,
                                        arguments: {
                                          "balance":
                                              double.parse(widget.balance),
                                          "to": _address.text,
                                          "token": widget.token,
                                          "from": state
                                              .wallet.privateKey.address.hex
                                        });
                                    return;
                                  }
                                  Navigator.of(context).pushNamed(
                                      TransactionConfirmationScreen.route,
                                      arguments: {
                                        "to": _address.text,
                                        "from":
                                            state.wallet.privateKey.address.hex,
                                        "value": 0.0,
                                        "balance": 0.0,
                                        "collectible": widget.collectible
                                      });
                                }
                              : null),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}
