import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/ui/screens/wallet_setup/wallet_setup_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';
import 'package:wallet_cryptomask/utils/update_utils.dart';

class OnboardScreen extends StatefulWidget {
  static String route = "onboard_screen";
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int index = 0;

  @override
  void initState() {
    checkForUpdate(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    WalletText(
                      '',
                      key: Key('app-name-text'),
                      localizeKey: 'appName',
                      textVarient: TextVarient.hero,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IntroductionScreen(
                  initialPage: index,
                  key: const Key('introduction-slides'),
                  pages: onBoardScreenContent(context),
                  showNextButton: false,
                  showDoneButton: false,
                  onDone: () {
                    // When done button is press
                  },
                ),
              ),
              WalletButton(
                key: const Key('get-started-button'),
                localizeKey: 'getStarted',
                onPressed: () {
                  Navigator.of(context).pushNamed(WalletSetupScreen.route);
                },
              ),
              addHeight(SpacingSize.m)
            ],
          ),
        ),
      ),
    );
  }
}
