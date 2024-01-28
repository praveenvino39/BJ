import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/home/home_screen.dart';
import 'package:wallet_cryptomask/ui/screens/create_wallet_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;
  late WalletProvider walletProvider;

  @override
  void initState() {
    walletProvider = context.read<WalletProvider>();
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
    super.initState();
  }

  openWalletHandler() async {
    if (_formKey.currentState!.validate()) {
      walletProvider.showLoading();
      walletProvider
          .openWallet(password: passwordController.text)
          .then((value) {
        Navigator.of(context).pushNamed(HomeScreen.route);
      }).catchError((e) {
        walletProvider.hideLoading();
        showErrorSnackBar(
            context, 'Error', getText(context, key: 'passwordIncorrect'));
      });

      // context.read<WalletCubit>().initialize(
      //   passwordController.text,
      //   onError: ((p0) {
      //     walletProvider.hideLoading();
      //     showErrorSnackBar(
      //         context, 'Error', getText(context, key: 'passwordIncorrect'));
      //   }),
      //   //   // );
      //   // },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              addHeight(SpacingSize.xs),
              const Expanded(child: SizedBox()),
              const Center(
                child: WalletText(
                  '',
                  localizeKey: 'appName',
                  textVarient: TextVarient.hero,
                ),
              ),
              addHeight(SpacingSize.m),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WalletText(
                    '',
                    localizeKey: 'welcomeBack',
                    textVarient: TextVarient.hero,
                  ),
                ],
              ),
              addHeight(SpacingSize.m),
              WalletTextField(
                  textEditingController: passwordController,
                  validator: (String? string) {
                    if (string!.isEmpty) {
                      return getText(context, key: 'passwordShouldntBeEmpy');
                    }
                    return null;
                  },
                  textFieldType: TextFieldType.password,
                  labelLocalizeKey: 'password'),
              addHeight(SpacingSize.s),
              Consumer<WalletProvider>(
                builder: (context, value, child) {
                  if (value.loading) {
                    return const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor));
                  }
                  return WalletButton(
                      type: WalletButtonType.outline,
                      localizeKey: 'Open Wallet',
                      onPressed: openWalletHandler);
                },
              ),
              const Expanded(child: SizedBox()),
              const WalletText(
                '',
                center: true,
                localizeKey: 'cantLogin',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      var alert = AlertDialog(
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(kPrimaryColor)),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  context.read<WalletCubit>().eraseWallet();
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red)),
                                child: const Text("Erase and continue")),
                          ],
                          title: const Text("Confirmation"),
                          content: SizedBox(
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                      text:
                                          'This action will erase all previous wallets and all funds will be lost. Make sure you can restore with your saved 12 word secret phrase and private keys for each wallet before you erase!.'),
                                  TextSpan(
                                      text: ' This action is irreversible',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))
                                ],
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ));
                      showDialog(context: context, builder: (context) => alert);
                    },
                    child: const WalletText(
                      '',
                      localizeKey: 'resetWallet',
                      bold: true,
                      underline: true,
                      center: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
