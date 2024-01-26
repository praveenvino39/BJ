import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/onboard/component/circle_stepper.dart';
import 'package:wallet_cryptomask/ui/screens/confirm_passphrase/confirm_passphrase_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/webview/web_view_screen.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class GeneratePassPhraseScreen extends StatefulWidget {
  static const route = "generate_passphrase_screen";
  const GeneratePassPhraseScreen({Key? key}) : super(key: key);

  @override
  State<GeneratePassPhraseScreen> createState() => _GeneratePassPhraseScreen();
}

class _GeneratePassPhraseScreen extends State<GeneratePassPhraseScreen> {
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
    });
    super.initState();
  }

  continueHandler() {
    Navigator.pushNamed(context, ConfirmPassPhraseScreen.route, arguments: {
      'password': Get.find<String>(tag: "password"),
      'passphrase': Get.put(passpharse, tag: "passphrase")
    });
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
              CircleStepper(currentIndex: 1),
              addHeight(SpacingSize.m),
              WalletText(
                AppLocalizations.of(context)!.writeSecretRecoveryPhrase,
                localizeKey: 'writeSecretRecoveryPhrase',
                bold: true,
                textVarient: TextVarient.body1,
              ),
              addHeight(SpacingSize.xs),
              WalletText(
                AppLocalizations.of(context)!.yourSecretRecoveryPhrase,
                localizeKey: 'yourSecretRecoveryPhrase',
                center: true,
                textVarient: TextVarient.body2,
              ),
              addHeight(SpacingSize.xs),
              !showPassphrase
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5)),
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 50),
                      child: Column(
                        children: [
                          addHeight(SpacingSize.xs),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.visibility_off,
                                color: Colors.white,
                              )),
                          addHeight(SpacingSize.xs),
                          WalletText(
                            AppLocalizations.of(context)!.tapToReveal,
                            localizeKey: 'tapToReveal',
                            center: true,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          addHeight(SpacingSize.s),
                          const WalletText(
                            '',
                            localizeKey: 'makeSureNoOneWatching',
                            center: true,
                            textVarient: TextVarient.body3,
                            color: Colors.white,
                          ),
                          addHeight(SpacingSize.xs),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(15.0),
                                    foregroundColor: Colors.white,
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
                                child: const WalletText(
                                  '',
                                  localizeKey: 'view',
                                  color: Colors.white,
                                  textVarient: TextVarient.body3,
                                  bold: true,
                                ),
                              ),
                            ),
                          ),
                          addHeight(SpacingSize.s),
                        ],
                      ),
                    )
                  : const SizedBox(),
              showPassphrase
                  ? Container(
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
                        itemCount: passpharse.length,
                        itemBuilder: (context, index) => SizedBox(
                          width: 100,
                          child: Container(
                              padding: const EdgeInsets.all(0),
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 1, color: kPrimaryColor)),
                              child: Center(
                                  child: WalletText(
                                '',
                                localizeKey:
                                    "${index + 1}. ${passpharse[index]}",
                              ))),
                        ),
                      ))
                  : const SizedBox(),
              addHeight(SpacingSize.m),
              WalletButton(
                type: WalletButtonType.filled,
                localizeKey: 'continueT',
                onPressed: showPassphrase ? continueHandler : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}
