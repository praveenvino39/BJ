import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino_home.dart';
import 'package:wallet_cryptomask/core/providers/contact_provider/contact_provider.dart';
import 'package:wallet_cryptomask/core/providers/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/providers/create_wallet_provider/create_wallet_provider.dart';
import 'package:wallet_cryptomask/core/providers/locale_provider/locale_provider.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/socket/message_engine.dart';
import 'package:wallet_cryptomask/ui/amount/amount_screen.dart';
import 'package:wallet_cryptomask/ui/block-web-view/block_web_view.dart';
import 'package:wallet_cryptomask/ui/deactivated-screen/deactivated_screen.dart';
import 'package:wallet_cryptomask/ui/home/home_screen.dart';
import 'package:wallet_cryptomask/ui/import-account/import_account_screen.dart';
import 'package:wallet_cryptomask/ui/login-screen/login_screen.dart';
import 'package:wallet_cryptomask/ui/screens/create_password/create_password_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding/onboard_screen.dart';
import 'package:wallet_cryptomask/ui/screens/wallet_setup/wallet_setup_screen.dart';
import 'package:wallet_cryptomask/ui/setttings/general_settings_screen/general_settings_screen.dart';
import 'package:wallet_cryptomask/ui/setttings/security_settings_screen/security_settings_screen.dart';
import 'package:wallet_cryptomask/ui/setttings/settings_screen.dart';
import 'package:wallet_cryptomask/ui/token-dashboard-screen/token_dashboard_screen.dart';
import 'package:wallet_cryptomask/ui/transaction-confirmation/transaction_confirmation.dart';
import 'package:wallet_cryptomask/ui/transaction-history/transaction_history_screen.dart';
import 'package:wallet_cryptomask/ui/transfer/transfer_screen.dart';
import 'package:wallet_cryptomask/ui/webview/web_view_screen.dart';

import 'constant.dart';

class MainApp extends StatefulWidget {
  final Widget initialWidget;
  final String locale;
  final Box userPreferenceBox;

  const MainApp(
      {Key? key,
      required this.initialWidget,
      required this.locale,
      required this.userPreferenceBox})
      : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String locale = "";
  final fss = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    setState(() {
      locale = widget.locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MessageEngine(messages: []),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CreateWalletProvider(fss),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ContactProvider(box: widget.userPreferenceBox),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              TokenProvider(userPreference: widget.userPreferenceBox),
        ),
        ChangeNotifierProvider(
          create: (ctx) => WalletProvider(fss, widget.userPreferenceBox),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LocaleProvider(locale: widget.locale),
        ),
      ],
      child: GetMaterialApp(
        locale: Locale.fromSubtags(languageCode: locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: ThemeData().copyWith(
            primaryColor: kPrimaryColor,
            textTheme:
                GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
            unselectedWidgetColor: kPrimaryColor),
        home: RouterinoHome(builder: () => widget.initialWidget),
      ),
    );
  }
}
