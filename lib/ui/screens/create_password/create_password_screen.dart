import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/home/home_screen.dart';
import 'package:wallet_cryptomask/ui/onboard/component/circle_stepper.dart';
import 'package:wallet_cryptomask/ui/onboard/component/create-password/bloc/create_wallet_cubit.dart';
import 'package:wallet_cryptomask/ui/screens/generate_passphrase/generate_passphrase_screen.dart';
import 'package:wallet_cryptomask/ui/setttings/general_settings_screen/general_settings_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/ui/webview/web_view_screen.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class CreatePasswordScreen extends StatefulWidget {
  static const route = "create_password_screen";
  const CreatePasswordScreen({Key? key}) : super(key: key);

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordCmpState();
}

class _CreatePasswordCmpState extends State<CreatePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final passwordEditingControl = TextEditingController();
  final confirmPasswordEditingControl = TextEditingController();
  bool isTermsAccepted = false;
  bool isCondition = false;

  bool showPassword = false;

  String? passwordvalidator(string) {
    if (string?.isEmpty == true) {
      return getText(context, key: 'thisFieldNotEmpty');
    }
    if (string!.length < 8) {
      return getText(context, key: 'passwordMustContain');
    }
    return null;
  }

  learnMoreHandler() {
    Navigator.of(context).pushNamed(WebViewScreen.router,
        arguments: {"title": "Learn more", "url": "https://ngydp.io/"});
  }

  createPasswordHandler() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (_formKey.currentState?.validate() == true) {
      if (!isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: WalletText(
              "",
              color: Colors.white,
              localizeKey: 'accepTermsWarning',
              placeholderLocalizeKey: 'appName',
            )));
        return;
      }
      if (passwordEditingControl.text != confirmPasswordEditingControl.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: WalletText(
              '',
              color: Colors.white,
              localizeKey: 'passwordConfirmPasswordNotMatch',
            )));
        return;
      }
      Get.put(passwordEditingControl.text, tag: "password");
      Navigator.pushNamed(context, GeneratePassPhraseScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateWalletCubit, CreateWalletState>(
      listener: (context, state) {
        if (state is CreateWalletSuccess) {
          Navigator.pushNamed(context, HomeScreen.route,
              arguments: {'password': passwordEditingControl.text});
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const WalletText(
            "",
            localizeKey: "appName",
            textVarient: TextVarient.hero,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleStepper(currentIndex: 0),
                  addHeight(SpacingSize.m),
                  WalletText(
                    AppLocalizations.of(context)!.createPassword,
                    localizeKey: "createPassword",
                    textVarient: TextVarient.subHeading,
                  ),
                  addHeight(SpacingSize.s),
                  WalletText(
                    AppLocalizations.of(context)!.thisPasswordWill,
                    center: true,
                    localizeKey: "thisPasswordWill",
                    textVarient: TextVarient.body1,
                  ),
                  addHeight(SpacingSize.s),
                  WalletTextField(
                      textFieldType: TextFieldType.password,
                      textEditingController: passwordEditingControl,
                      validator: passwordvalidator,
                      labelLocalizeKey: "password"),
                  addHeight(SpacingSize.m),
                  WalletTextField(
                      textFieldType: TextFieldType.password,
                      textEditingController: confirmPasswordEditingControl,
                      validator: passwordvalidator,
                      labelLocalizeKey: "confirmPassword"),
                  addHeight(SpacingSize.xxl),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: kPrimaryColor,
                        value: isTermsAccepted,
                        onChanged: (value) {
                          setState(() {
                            isTermsAccepted = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: learnMoreHandler,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: getTextWithPlaceholder(context,
                                        key: 'iUnserstandTheRecover',
                                        string:
                                            getText(context, key: 'appName'))),
                                TextSpan(
                                    text: getText(context, key: 'learnMore'),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor,
                                        decoration: TextDecoration.underline))
                              ],
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  addHeight(SpacingSize.s),
                  WalletButton(
                      localizeKey: "createPassword",
                      onPressed: createPasswordHandler)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
