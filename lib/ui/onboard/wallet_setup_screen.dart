import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet/ui/import-account/import_account_screen.dart';
import 'package:wallet/ui/onboard/create_wallet_screen.dart';
import 'package:wallet/ui/onboard/component/create-password/bloc/create_wallet_cubit.dart';
import 'package:wallet/ui/shared/wallet_button.dart';

import '../../constant.dart';

class WalletSetupScreen extends StatefulWidget {
  static String route = "wallet_setup_screen";

  const WalletSetupScreen({Key? key}) : super(key: key);

  @override
  State<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends State<WalletSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateWalletCubit, CreateWalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            title:  const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 70, 10),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    appName,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                        letterSpacing: 5),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    AppLocalizations.of(context)!.walletSetup,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    AppLocalizations.of(context)!.importAnExistingWalletOrCreate,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  const Expanded(child: SizedBox()),
                  WalletButton(
                      textContent: AppLocalizations.of(context)!.importUsingSecretRecoveryPhrase,
                      onPressed: () {
                        Navigator.of(context).pushNamed(ImportAccount.route);
                      }),
                  const SizedBox(
                    height: 7,
                  ),
                  WalletButton(
                    type: WalletButtonType.filled,
                    textContent: AppLocalizations.of(context)!.createANewWallet,
                    onPressed: () {
                      Navigator.of(context).pushNamed(CreateWalletScreen.route);
                    },
                  ),
                  const SizedBox(height: 70)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
