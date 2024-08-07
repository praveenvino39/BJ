import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';

import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:web3dart/crypto.dart';

class SecuritySettingsScreen extends StatefulWidget {
  static const route = "security_settings_screen";
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool showPrivateKey = false;
  bool showSecretRecoveryPhrase = false;
  final passwordEditingController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 70, 10),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.security,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FutureBuilder<String?>(
            future: getWalletProvider(context).getSecretRecoveryPhrase(),
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      copyToClipBoard(
                        context,
                        bytesToHex(getWalletProvider(context)
                            .activeWallet
                            .wallet
                            .privateKey
                            .privateKey),
                        getText(context, key: 'privateKeyCopiedToClipboard'),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WalletText('',
                            localizeKey: 'showPrivateKey',
                            size: 16,
                            fontWeight: FontWeight.bold),
                        const SizedBox(
                          height: 7,
                        ),
                        WalletText('',
                            localizeKey: bytesToHex(getWalletProvider(context)
                                .activeWallet
                                .wallet
                                .privateKey
                                .privateKey)),
                        const SizedBox(
                          height: 7,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  snapshot.data != null
                      ? InkWell(
                          onTap: () {
                            copyToClipBoard(
                              context,
                              snapshot.data!,
                              getText(context, key: 'SRPCoipied'),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const WalletText(
                                '',
                                localizeKey: 'showSeedphrase',
                                size: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              WalletText('', localizeKey: snapshot.data),
                              const SizedBox(
                                height: 7,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 7,
                  )
                ],
              );
            }),
      ),
    );
  }
}
