// ignore_for_file: invalid_return_type_for_catch_error

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/deactivated-screen/deactivated_screen.dart';
import 'package:wallet_cryptomask/ui/screens/home-screen/home_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding-screen/onboard_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/utils/update_utils.dart';

class LoginScreen extends StatefulWidget {
  static const route = "login_screen_route";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController passwordController =
      TextEditingController(text: kDebugMode ? "11111111" : null);
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
    checkForUpdate(context);
    super.initState();
  }

  openWalletHandler() async {
    WalletProvider walletProvider = context.read<WalletProvider>();
    if (_formKey.currentState!.validate()) {
      walletProvider.showLoading();
      walletProvider
          .openWallet(password: passwordController.text)
          .then((value) {
        walletProvider.hideLoading();
        final user = Get.find<User>();
        if (user.isDeactivated) {
          return context.pushAndRemoveUntil(
              removeUntil: bool, builder: () => const DeactivatedScreen());
        }
        context.pushAndRemoveUntil(
            removeUntil: bool, builder: () => const HomeScreen());
      }).catchError((e) {
        walletProvider.hideLoading();
        showErrorSnackBar(context, getText(context, key: 'error'),
            getText(context, key: 'passwordIncorrect'));
        return e;
      });
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
                  localizeKey: 'appName',
                  textVarient: TextVarient.hero,
                ),
              ),
              addHeight(SpacingSize.m),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WalletText(
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
                      localizeKey: 'openWallet',
                      onPressed: openWalletHandler);
                },
              ),
              const Expanded(child: SizedBox()),
              const WalletText(
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
                                        WidgetStateProperty.all(kPrimaryColor)),
                                child: const WalletText(
                                  localizeKey: "cancel",
                                  color: Colors.white,
                                )),
                            ElevatedButton(
                                onPressed: () {
                                  getWalletProvider(context)
                                      .eraseWallet()
                                      .then((value) {
                                    context.pushAndRemoveUntil(
                                        removeUntil: bool,
                                        builder: () => const OnboardScreen());
                                  });
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.red)),
                                child: const WalletText(
                                  localizeKey: 'eraseAndContinue',
                                  color: Colors.white,
                                )),
                          ],
                          title: const WalletText(
                            localizeKey: 'confirmation',
                          ),
                          content: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text:
                                        getText(context, key: 'eraseWarning')),
                                TextSpan(
                                    text: getText(context, key: 'irreversible'),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red))
                              ],
                              style: const TextStyle(color: Colors.black),
                            ),
                          ));
                      showDialog(context: context, builder: (context) => alert);
                    },
                    child: const WalletText(
                      localizeKey: 'resetWallet',
                      bold: true,
                      color: Colors.red,
                      underline: true,
                      center: true,
                    ),
                  ),
                ],
              ),
              addHeight(SpacingSize.l),
            ],
          ),
        ),
      ),
    );
  }
}
