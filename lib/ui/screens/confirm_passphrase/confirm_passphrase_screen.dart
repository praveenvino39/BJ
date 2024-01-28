// ignore_for_file: use_build_context_synchronously

import 'package:ethers/signers/wallet.dart';
import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/create_wallet_provider/create_wallet_provider.dart';
import 'package:wallet_cryptomask/ui/home/home_screen.dart';
import 'package:wallet_cryptomask/ui/onboard/component/circle_stepper.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding/onboard_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';
import 'package:provider/provider.dart';

class ConfirmPassPhraseScreen extends StatefulWidget {
  static const route = "confirm_passphrase_screen";
  const ConfirmPassPhraseScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmPassPhraseScreen> createState() =>
      ConfirmPassPhraseScreenState();
}

class ConfirmPassPhraseScreenState extends State<ConfirmPassPhraseScreen> {
  bool isLoading = false;
  bool isAllFilled = false;
  List<String> confirmPassPhrase = List.filled(12, "");
  int currentIndex = 0;
  int continueIndex = 0;
  int? changeIndex;
  List<int> changeOrder = [];
  List<String> passpharse = [];
  String password = "";
  late final CreateWalletProvider createWalletProvider;

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
      createWalletProvider = context.read<CreateWalletProvider>();
      passpharse = createWalletProvider.getPassphrase();
    });
    super.initState();
  }

  createWalletHandler() async {
    try {
      final passPhrase = confirmPassPhrase.join(" ");
      final walletKey = Wallet.fromMnemonic(passPhrase);
      String password = createWalletProvider.getPassword();
      await createWalletProvider.createWalletWithPassword(
          passPhrase, password, walletKey.privateKey!);
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.route, (route) => false);
    } catch (e) {
      showErrorSnackBar(context, "Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const WalletText(
          "",
          localizeKey: "appName",
          textVarient: TextVarient.hero,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CircleStepper(currentIndex: 2),
              addHeight(SpacingSize.s),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: WalletText(
                  '',
                  localizeKey: 'selectEachWord',
                  center: true,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          width: 1, color: Colors.grey.withAlpha(70))),
                  width: MediaQuery.of(context).size.width,
                  child: GridView.builder(
                    key: const Key('passphrase-blank-grid-view'),
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
                                key: Key('challenge-$index'),
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
                key: const Key('passphrase-options-grid-view'),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 50,
                    mainAxisExtent: 30,
                    crossAxisCount: 3),
                itemCount: passpharse.length,
                itemBuilder: (context, index) => SizedBox(
                  width: 100,
                  child: InkWell(
                    key: Key('option-$index'),
                    onTap: () {
                      setState(() {
                        if (!disabledWords.contains(passpharse[index])) {
                          if (changeOrder.isNotEmpty) {
                            disabledWords.add(passpharse[index]);
                            confirmPassPhrase[changeOrder.first] =
                                passpharse[index];
                            changeOrder.removeAt(0);
                          } else {
                            disabledWords.add(passpharse[index]);
                            confirmPassPhrase[currentIndex] = passpharse[index];
                            currentIndex += 1;
                          }
                        } else {
                          var removeIndex =
                              disabledWords.indexOf(passpharse[index]);
                          var confirmIndex =
                              confirmPassPhrase.indexOf(passpharse[index]);
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
                            color: disabledWords.contains(passpharse[index])
                                ? Colors.grey.withAlpha(70)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                width: 1,
                                color:
                                    !disabledWords.contains(passpharse[index])
                                        ? kPrimaryColor
                                        : Colors.transparent)),
                        child: Center(
                            child: Text(
                          passpharse[index],
                          style: const TextStyle(color: Colors.black),
                        ))),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              WalletButton(
                  type: WalletButtonType.filled,
                  localizeKey: 'createWallet',
                  onPressed: isAllFilled ? createWalletHandler : null)
            ],
          ),
        ),
      ),
    );
  }
}
