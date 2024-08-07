// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/remote/response-model/settings_response.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/setttings-screen/general_settings_screen/general_settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/screens/chat_screen/chat_screen.dart';
import 'package:wallet_cryptomask/ui/screens/wallet-connect-screen/walletconnect_session_screen.dart';
import 'package:wallet_cryptomask/ui/screens/web-view-screen/web_view_screen.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class SettingsScreen extends StatefulWidget {
  static const route = "settings_screen";
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = Get.find<Settings>();
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
                AppLocalizations.of(context)!.settings,
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
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              addHeight(SpacingSize.s),
              ListTile(
                onTap: () {
                  context.push(() => const GeneralSettingsScreen());
                },
                title: Text(AppLocalizations.of(context)!.general),
                subtitle:
                    Text(AppLocalizations.of(context)!.generalDescription),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withAlpha(60),
              ),
              ListTile(
                onTap: () {
                  goToSecuritySettings(
                    context,
                    () {},
                  );
                },
                title: Text(AppLocalizations.of(context)!.security),
                subtitle:
                    Text(AppLocalizations.of(context)!.securityDescription),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withAlpha(60),
              ),
              ListTile(
                onTap: () {
                  context.push(() => const WalletConnectSessionScreen());
                },
                title: const WalletText(
                  '',
                  localizeKey: 'WalletConnect',
                ),
                subtitle: const WalletText(
                  '',
                  localizeKey: 'Manage WalletConnect session',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withAlpha(60),
              ),
              ListTile(
                onTap: () {
                  context.push(() => const ChatScreen());
                },
                title: const WalletText(
                  '',
                  localizeKey: 'Contact us',
                ),
                subtitle: const WalletText(
                  '',
                  localizeKey: 'Send a message to us',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.withAlpha(60),
              ),
              InkWell(
                  onTap: () {
                    context.push(() => WebViewScreen(
                        url: getText(context, key: 'about'),
                        title: settings.about));
                  },
                  child: const ListTile(
                      title: WalletText(
                    '',
                    localizeKey: 'about',
                  ))),
            ],
          ),
        ),
      ),
    );
  }
}
