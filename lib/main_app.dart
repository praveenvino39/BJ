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
import 'package:wallet_cryptomask/ui/screens/create_wallet_screen.dart';
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
        onGenerateRoute: (setting) {
          if (setting.name == WalletSetupScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const WalletSetupScreen());
          }
          if (setting.name == OnboardScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const OnboardScreen());
          }
          if (setting.name == DeactivatedScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const DeactivatedScreen());
          }
          if (setting.name == LoginScreen.route) {
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          }
          if (setting.name == CreatePasswordScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const CreatePasswordScreen());
          }

          if (setting.name == SecuritySettingsScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const SecuritySettingsScreen());
          }
          if (setting.name == GeneralSettingsScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const GeneralSettingsScreen());
          }
          if (setting.name == ImportAccount.route) {
            return MaterialPageRoute(
                builder: (context) => const ImportAccount());
          }
          if (setting.name == WebViewScreen.router) {
            String title = (setting.arguments as dynamic)["title"];
            String url = (setting.arguments as dynamic)["url"];
            return MaterialPageRoute(
                builder: (context) => WebViewScreen(title: title, url: url));
          }
          if (setting.name == TransactionHistoryScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const TransactionHistoryScreen());
          }
          if (setting.name == CreateWalletScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const CreateWalletScreen());
          }
          if (setting.name == HomeScreen.route) {
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          }
          if (setting.name == SettingsScreen.route) {
            return MaterialPageRoute(
                builder: (context) => const SettingsScreen());
          }
          if (setting.name == TransactionConfirmationScreen.route) {
            String to = (setting.arguments as dynamic)["to"];
            String from = (setting.arguments as dynamic)["from"];
            double value = (setting.arguments as dynamic)["value"];
            String? token = (setting.arguments as dynamic)["token"];
            String? contractAddress =
                (setting.arguments as dynamic)["contractAddress"];

            Collectible? collectible =
                (setting.arguments as dynamic)["collectible"];

            double balance =
                (setting.arguments as dynamic)["balance"] as double;
            return MaterialPageRoute(
              builder: (context) => TransactionConfirmationScreen(
                to: to,
                from: from,
                value: value,
                balance: balance,
                token: token,
                contractAddress: contractAddress,
                collectible: collectible,
              ),
            );
          }
          if (setting.name == AmountScreen.route) {
            double balance =
                (setting.arguments as dynamic)["balance"] as double;
            String to = (setting.arguments as dynamic)["to"] as String;
            String from = (setting.arguments as dynamic)["from"] as String;
            Token token = (setting.arguments as dynamic)["token"] as Token;
            if (kDebugMode) {
              log(token.symbol.toString());
            }
            return MaterialPageRoute(
                builder: (context) => AmountScreen(
                      balance: balance,
                      to: to,
                      token: token,
                      from: from,
                    ));
          }
          if (setting.name == TransferScreen.route) {
            String balance = (setting.arguments as dynamic)["balance"];
            Token? token = (setting.arguments as dynamic)["token"];
            Collectible? collectible =
                (setting.arguments as dynamic)["collectible"];

            return MaterialPageRoute(
                builder: (context) => TransferScreen(
                      balance: token != null ? balance : "0",
                      token: token,
                      collectible: collectible,
                    ));
          }

          if (setting.name == TokenDashboardScreen.route) {
            String token = (setting.arguments as dynamic)["token"];
            String tokenId = (setting.arguments as dynamic)["tokenId"] ?? "-1";

            return MaterialPageRoute(
                builder: (context) => TokenDashboardScreen(
                      tokenAddress: token,
                      tokenId: tokenId,
                    ));
          }
          if (setting.name == BlockWebView.router) {
            BlockWebViewArg arguments =
                BlockWebViewArg.fromObject(setting.arguments!);
            return MaterialPageRoute(
              builder: (context) => BlockWebView(
                title: arguments.title,
                url: arguments.url,
                isTransaction: arguments.isTransaction,
              ),
            );
          }

          return null;
        },
      ),
    );
  }
}
