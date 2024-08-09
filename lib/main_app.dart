import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino_home.dart';
import 'package:wallet_cryptomask/core/providers/contact_provider/contact_provider.dart';
import 'package:wallet_cryptomask/core/providers/network_provider/network_provider.dart';
import 'package:wallet_cryptomask/core/providers/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/providers/create_wallet_provider/create_wallet_provider.dart';
import 'package:wallet_cryptomask/core/providers/locale_provider/locale_provider.dart';
import 'package:wallet_cryptomask/core/socket/message_engine.dart';

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
  final networkProvider = NetworkProvider();

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
        ChangeNotifierProvider(create: (ctx) => networkProvider),
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
          create: (ctx) => WalletProvider(
              fss, widget.userPreferenceBox, networkProvider.networks),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LocaleProvider(locale: widget.locale),
        ),
      ],
      child: GetMaterialApp(
        locale: Locale.fromSubtags(languageCode: locale),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: LocaleProvider.supportedLocales,
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
