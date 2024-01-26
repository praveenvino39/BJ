import 'dart:developer' as pd;
import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';

class SetupPassphraseScreen extends StatefulWidget {
  static const route = "setup_passphrase_screen";

  final Function onNext;
  final Function(List<String>) getPassphrase;
  const SetupPassphraseScreen(
      {Key? key, required this.onNext, required this.getPassphrase})
      : super(key: key);

  @override
  State<SetupPassphraseScreen> createState() => _SetupPassphraseScreenState();
}

class _SetupPassphraseScreenState extends State<SetupPassphraseScreen> {
  List<String> passpharse = [];
  bool showPassphrase = false;

  @override
  void initState() {
    List<String> generatedMnemonic = bip39.generateMnemonic().split(" ");
    do {
      generatedMnemonic = bip39.generateMnemonic().split(" ");
    } while (
        generatedMnemonic.toSet().toList().length != generatedMnemonic.length);
    setState(() {
      passpharse = generatedMnemonic;
      pd.log(passpharse.join(" "));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Text(
            AppLocalizations.of(context)!.writeSecretRecoveryPhrase,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            AppLocalizations.of(context)!.yourSecretRecoveryPhrase,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          !showPassphrase
              ? Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5)),
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.tapToReveal,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        AppLocalizations.of(context)!.makeSureNoOneWatching,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(15.0),
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                side: const BorderSide(
                                    width: 1.0, color: Colors.white)),
                            onPressed: () {
                              setState(() {
                                showPassphrase = true;
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.view,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          showPassphrase
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
                    itemCount: passpharse.length,
                    itemBuilder: (context, index) => SizedBox(
                      width: 100,
                      child: Container(
                          padding: const EdgeInsets.all(0),
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border:
                                  Border.all(width: 1, color: kPrimaryColor)),
                          child: Center(
                              child: Text(
                            "${index + 1}. ${passpharse[index]}",
                            style: const TextStyle(color: Colors.black),
                          ))),
                    ),
                  ))
              : const SizedBox(),
          const SizedBox(
            height: 30,
          ),
          WalletButton(
              type: WalletButtonType.filled,
              textContent: AppLocalizations.of(context)!.continueT,
              onPressed: showPassphrase
                  ? () {
                      widget.onNext();
                      widget.getPassphrase(passpharse);
                    }
                  : null)
        ],
      ),
    );
  }
}
