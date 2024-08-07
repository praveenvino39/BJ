// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/bloc/create_wallet_provider/create_wallet_provider.dart';
import 'package:wallet_cryptomask/core/remote/response-model/settings_response.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/home/home_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
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
  final passwordEditingControl =
      TextEditingController(text: kDebugMode ? "11111111" : null);
  final confirmPasswordEditingControl =
      TextEditingController(text: kDebugMode ? "11111111" : null);
  bool isTermsAccepted = false;
  bool isCondition = false;
  bool isLoading = false;
  final settings = Get.find<Settings>();

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
    Navigator.of(context).pushNamed(WebViewScreen.router, arguments: {
      "title": getText(context, key: 'learnMore'),
      "url": settings.ppUrl
    });
  }

  createPasswordHandler() async {
    setState(() {
      isLoading = true;
    });
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (_formKey.currentState?.validate() == true) {
      if (!isTermsAccepted) {
        showErrorSnackBar(
            context, 'Invalid', getText(context, key: 'accepTermsWarning'));
        setState(() {
          isLoading = false;
        });
        return;
      }
      if (passwordEditingControl.text != confirmPasswordEditingControl.text) {
        showErrorSnackBar(
            context,
            'Invalid',
            getText(
              context,
              key: 'passwordConfirmPasswordNotMatch',
            ));
        setState(() {
          isLoading = false;
        });
        return;
      }
      try {
        final createWalletProvider = getCreateWalletProvider(context);
        final walletProvider = getWalletProvider(context);
        await createWalletProvider.setPassword(passwordEditingControl.text);
        await createWalletProvider.createWallet();
        await walletProvider.openWallet(password: passwordEditingControl.text);
        setState(() {
          isLoading = false;
        });
        showPositiveSnackBar(
            context,
            'Success',
            getText(
              context,
              key: 'createWalletGreet',
            ));
        await Navigator.pushNamed(context, HomeScreen.route);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showErrorSnackBar(context, "Error", e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                addHeight(SpacingSize.m),
                const WalletText(
                  '',
                  key: Key('create-password-text'),
                  localizeKey: "createPassword",
                  textVarient: TextVarient.subHeading,
                ),
                addHeight(SpacingSize.s),
                const WalletText(
                  '',
                  center: true,
                  localizeKey: "thisPasswordWill",
                  textVarient: TextVarient.body1,
                ),
                addHeight(SpacingSize.s),
                WalletTextField(
                    textFieldType: TextFieldType.password,
                    textEditingController: passwordEditingControl,
                    validator: passwordvalidator,
                    key: const Key('password-text-field'),
                    labelLocalizeKey: "password"),
                addHeight(SpacingSize.m),
                WalletTextField(
                    textFieldType: TextFieldType.password,
                    textEditingController: confirmPasswordEditingControl,
                    validator: passwordvalidator,
                    key: const Key('confirm-password-text-field'),
                    labelLocalizeKey: "confirmPassword"),
                addHeight(SpacingSize.xxl),
                Row(
                  key: const Key('terms-agreement-section'),
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
                isLoading
                    ? const CircularProgressIndicator(
                        color: kPrimaryColor,
                      )
                    : WalletButton(
                        key: const Key('create-wallet-button'),
                        localizeKey: "createPassword",
                        onPressed: createPasswordHandler)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
