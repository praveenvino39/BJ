import 'dart:developer';

import 'package:ethers/signers/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/ui/onboard/component/create-password/bloc/create_wallet_cubit.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmPassphrase extends StatefulWidget {
  final List<String> passpharse;
  final String password;
  const ConfirmPassphrase(
      {Key? key, required this.passpharse, required this.password})
      : super(key: key);

  @override
  State<ConfirmPassphrase> createState() => _ConfirmPassphraseState();
}

class _ConfirmPassphraseState extends State<ConfirmPassphrase> {
  bool isLoading = false;
  bool isAllFilled = false;
  List<String> confirmPassPhrase = List.filled(12, "");
  int currentIndex = 0;
  int continueIndex = 0;
  int? changeIndex;
  List<int> changeOrder = [];

  List<String> disabledWords = [];

  checkAllFilled() {
    var result =
        confirmPassPhrase.firstWhere((element) => element == "", orElse: () {
      return "NOT_FOUND";
    });
    setState(() {
      if (result == "NOT_FOUND") {
        isAllFilled = true;
      } else {
        isAllFilled = false;
      }
    });
  }

  @override
  void initState() {
    setState(() {
      log(widget.passpharse.join(" "));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    AppLocalizations.of(context)!.selectEachWord,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 1, color: Colors.grey.withAlpha(70))),
                    width: MediaQuery.of(context).size.width,
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 50,
                              mainAxisExtent: 30,
                              crossAxisCount: 2),
                      itemCount: confirmPassPhrase.length,
                      itemBuilder: (context, index) => SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            Text("${index + 1}.  "),
                            Container(
                                padding: const EdgeInsets.all(0),
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        width: 1, color: kPrimaryColor)),
                                child: Center(
                                    child: Text(
                                  confirmPassPhrase[index],
                                  style: const TextStyle(color: Colors.black),
                                ))),
                          ],
                        ),
                      ),
                    )),
                TextButton(
                  child: const Text("Reset"),
                  onPressed: () {
                    setState(() {
                      currentIndex = 0;
                      continueIndex = 0;
                      changeIndex = 0;
                      confirmPassPhrase = List.filled(12, "");
                      changeOrder.clear();
                      disabledWords.clear();
                    });
                  },
                ),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 50,
                      mainAxisExtent: 30,
                      crossAxisCount: 3),
                  itemCount: widget.passpharse.length,
                  itemBuilder: (context, index) => SizedBox(
                    width: 100,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (!disabledWords
                              .contains(widget.passpharse[index])) {
                            if (changeOrder.isNotEmpty) {
                              disabledWords.add(widget.passpharse[index]);
                              confirmPassPhrase[changeOrder.first] =
                                  widget.passpharse[index];
                              changeOrder.removeAt(0);
                            } else {
                              disabledWords.add(widget.passpharse[index]);
                              confirmPassPhrase[currentIndex] =
                                  widget.passpharse[index];
                              currentIndex += 1;
                            }
                          } else {
                            var removeIndex =
                                disabledWords.indexOf(widget.passpharse[index]);
                            var confirmIndex = confirmPassPhrase
                                .indexOf(widget.passpharse[index]);
                            disabledWords.removeAt(removeIndex);
                            confirmPassPhrase[confirmIndex] = "";
                            changeIndex = confirmIndex;
                            changeOrder.add(confirmIndex);
                            continueIndex = currentIndex;
                          }
                        });
                        checkAllFilled();
                      },
                      child: Container(
                          padding: const EdgeInsets.all(0),
                          width: 100,
                          decoration: BoxDecoration(
                              color: disabledWords
                                      .contains(widget.passpharse[index])
                                  ? Colors.grey.withAlpha(70)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  width: 1,
                                  color: !disabledWords
                                          .contains(widget.passpharse[index])
                                      ? kPrimaryColor
                                      : Colors.transparent)),
                          child: Center(
                              child: Text(
                            widget.passpharse[index],
                            style: const TextStyle(color: Colors.black),
                          ))),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                !isLoading
                    ? WalletButton(
                        type: WalletButtonType.filled,
                        textContent: "Continue",
                        onPressed: isAllFilled
                            ? () {
                                setState(() {
                                  isLoading = true;
                                });
                                Future.delayed(
                                  const Duration(milliseconds: 200),
                                  () {
                                    var passPhrase =
                                        confirmPassPhrase.join(" ");
                                    try {
                                      var walletKey =
                                          Wallet.fromMnemonic(passPhrase);
                                      context
                                          .read<CreateWalletCubit>()
                                          .createWalletWithPassword(
                                              passPhrase,
                                              widget.password,
                                              walletKey.privateKey!);
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.error,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(e.toString()),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  },
                                );
                              }
                            : null)
                    : const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      )
              ],
            ),
          ),
        );
      },
    );
  }
}
