import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/config.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/ui/home/home_screen.dart';
import 'package:wallet/ui/onboard/create_wallet_screen.dart';
import 'package:wallet/ui/shared/wallet_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletCubit, WalletState>(
      listener: (context, state) {
        if (state is WalletUnlocked) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacementNamed(HomeScreen.route,
              arguments: {"password": passwordController.text});
          // Navigator.of(context).pushNamed(HomeScreen.route, arguments: {"password": passwordController.text});
        }
        if (state is WalletErased) {
          Navigator.of(context).pushNamed(CreateWalletScreen.route);
        }
      },
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Expanded(child: SizedBox()),
              const Center(
                child: Text(
                  appName,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 25,
                      letterSpacing: 5),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Text(
                    "Welcome Back!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  )),
              const SizedBox(
                height: 30,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Password"),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (String? string) {
                    if (string!.isEmpty) {
                      return "Password shouldn't be empty";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      hintText: "Enter password to unlock the wallet",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      border: OutlineInputBorder(borderSide: BorderSide())),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              !isLoading
                  ? WalletButton(
                      type: WalletButtonType.outline,
                      textContent: "Open Wallet",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          Future.delayed(
                            const Duration(milliseconds: 200),
                            () {
                              context.read<WalletCubit>().initialize(
                                passwordController.text,
                                onError: ((p0) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.error,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.30,
                                              child: const Text(
                                                  "Password incorrect, provider valid password"))
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          );
                        }
                      })
                  : const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor)),
              const Expanded(child: SizedBox()),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Can't login due to lost password? You can reset current wallet and restore with your saved secret 12 word phrase",
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () {
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
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Reset wallet",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
