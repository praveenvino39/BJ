import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';

const Color kPrimaryColor = Color(0xff7b15ef);

const String walletConnectSingleTon = "WalletConnectSingleTon";

// const baseStaticUrl = "http://localhost:3001/";
const baseApiUrl =
    "https://5835-2405-201-e02a-802e-8496-ee79-33c9-ba0e.ngrok-free.app/";
onBoardScreenContent(BuildContext context) {
  return [
    PageViewModel(
      title: getText(context, key: 'trustedByMillion'),
      body: getText(context, key: 'template1'),
      image: Center(
        child: SvgPicture.asset(
          "assets/vector/phone.svg",
          height: 200,
        ),
      ),
    ),
    PageViewModel(
      title: getText(context, key: 'safeReliableSuperfast'),
      body: getText(context, key: 'template2'),
      image: Center(
        child: SvgPicture.asset(
          "assets/vector/eth.svg",
          height: 200,
        ),
      ),
    ),
    PageViewModel(
      title: getText(context, key: 'youKeyToExploreWeb3'),
      body: getText(context, key: 'template3'),
      image: Center(
        child: SvgPicture.asset(
          "assets/vector/world.svg",
          height: 200,
        ),
      ),
    ),
  ];
}
