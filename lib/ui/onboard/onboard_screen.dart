import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/config.dart';
import 'package:wallet/ui/onboard/wallet_setup_screen.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_update/in_app_update.dart';

class OnboardScreen extends StatefulWidget {
  static String route = "onboard_screen";
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  List<PageViewModel> pageList = [
    PageViewModel(
      title: "Trusted by Million",
      body:
          "Here you can write the description of the page, to explain someting...",
      image: Center(
        child: SvgPicture.asset(
          "assets/vector/phone.svg",
          height: 200,
        ),
      ),
    ),
    PageViewModel(
      title: "Safe, Reliable and Superfast",
      body:
          "Here you can write the description of the page, to explain someting...",
      image: Center(
        child: SvgPicture.asset(
          "assets/vector/eth.svg",
          height: 200,
        ),
      ),
    ),
    PageViewModel(
      title: "Your key to explore Web3",
      body:
          "Here you can write the description of the page, to explain someting...",
      image: Center(
        child: SvgPicture.asset(
          "assets/vector/world.svg",
          height: 200,
        ),
      ),
    ),
  ];
  int index = 0;

  @override
  void initState() {
    try {
      if (Platform.isAndroid) {
        InAppUpdate.checkForUpdate().then((update) {
          if (update.updateAvailability == UpdateAvailability.updateAvailable) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: const Text("Update available"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Available version: ${update.availableVersionCode}'),
                      const SizedBox(
                        height: 20,
                      ),
                      WalletButton(
                          textContent: "Update",
                          onPressed: () {
                            InAppUpdate.performImmediateUpdate()
                                .catchError((e) => log(e.toString()));
                          })
                    ],
                  ),
                ),
              ),
            );
          }
        }).catchError((e) {
          log(e.toString());
        });
      }
      if (Platform.isIOS) {
        final newVersion = NewVersion();
        newVersion.getVersionStatus().then((status) {
          if (status != null && status.canUpdate) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: const Text("Update available"),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          "New version of $appName is available on App Store."),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text(
                            'Current version: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(status.localVersion),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Available version: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(status.storeVersion),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "What's new :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(status.releaseNotes ??
                          "Improved performance and stability."),
                      const SizedBox(
                        height: 20,
                      ),
                      WalletButton(
                          textContent: "Update",
                          onPressed: () async {
                            log(status.appStoreLink);
                            if (!await launchUrl(
                              Uri.parse(status.appStoreLink),
                              mode: LaunchMode.externalApplication,
                            )) {
                              throw 'Could not launch ${status.appStoreLink}';
                            }
                          })
                    ],
                  ),
                ),
              ),
            );
          }
        }).catchError((e) {
          log(e.toString());
        });
      }
    } catch (e) {
      log(e.toString());
    }

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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: const [
                    Text(
                      appName,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 25,
                          letterSpacing: 5),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IntroductionScreen(
                  initialPage: index,
                  pages: pageList,
                  showNextButton: false,
                  showDoneButton: false,
                  onDone: () {
                    // When done button is press
                  },
                ),
              ),
              WalletButton(
                textContent: AppLocalizations.of(context)!.getStarted,
                // textContent: "",
                onPressed: () {
                  Navigator.of(context).pushNamed(WalletSetupScreen.route);
                },
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
