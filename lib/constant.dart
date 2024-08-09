import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';

const Color kPrimaryColor = Color(0xff7b15ef);

const String walletConnectSingleTon = "WalletConnectSingleTon";

onBoardScreenContent(BuildContext context) {
  return [
    PageViewModel(
      title: getText(context, key: 'welcomeTo'),
      body: getText(context, key: 'template1'),
      image: Center(
        child: Image.asset(
          "assets/images/logo.png",
          height: 250,
        ),
      ),
    ),
    PageViewModel(
      title: getText(context, key: 'explorerFeature'),
      body: getText(context, key: 'template2'),
      image: Lottie.asset("assets/animations/browser.json",
          width: 200, height: 200, fit: BoxFit.contain),
    ),
    PageViewModel(
      title: getText(context, key: 'securityYouCan'),
      body: getText(context, key: 'template3'),
      image: Lottie.asset("assets/animations/security.json",
          width: 300, height: 300, fit: BoxFit.cover),
    ),
  ];
}
