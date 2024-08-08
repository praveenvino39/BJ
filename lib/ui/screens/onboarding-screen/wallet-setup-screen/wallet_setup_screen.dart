import 'package:flutter/material.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/ui/screens/import-account-screen/import_account_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding-screen/create-password-screen/create_password_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

import '../../../../constant.dart';

class WalletSetupScreen extends StatefulWidget {
  static String route = "wallet_setup_screen";

  const WalletSetupScreen({Key? key}) : super(key: key);

  @override
  State<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends State<WalletSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [Icon(Icons.arrow_back, color: Colors.transparent)],
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const WalletText(
          localizeKey: 'appName',
          textVarient: TextVarient.hero,
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              addHeight(SpacingSize.xl),
              const WalletText(
                localizeKey: 'walletSetup',
                textVarient: TextVarient.heading,
              ),
              addHeight(SpacingSize.s),
              const WalletText(
                localizeKey: 'importAnExistingWalletOrCreate',
                textVarient: TextVarient.body2,
              ),
              const FillView(),
              WalletButton(
                  localizeKey: 'importUsingSecretRecoveryPhrase',
                  onPressed: () {
                    context.push(() => const ImportAccountScreen());
                  }),
              addHeight(SpacingSize.xs),
              WalletButton(
                localizeKey: 'createANewWallet',
                type: WalletButtonType.filled,
                onPressed: () {
                  context.push(() => const CreatePasswordScreen());
                },
              ),
              addHeight(SpacingSize.xxxl)
            ],
          ),
        ),
      ),
    );
  }
}
