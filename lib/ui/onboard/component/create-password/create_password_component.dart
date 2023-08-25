import 'package:flutter/material.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/ui/shared/wallet_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet/ui/webview/web_view_screen.dart';

class CreatePasswordCmp extends StatefulWidget {
  final Function? onNext;
  final Function(String) getPassword;
  const CreatePasswordCmp(
      {Key? key, required this.onNext, required this.getPassword})
      : super(key: key);

  @override
  State<CreatePasswordCmp> createState() => _CreatePasswordCmpState();
}

class _CreatePasswordCmpState extends State<CreatePasswordCmp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final passwordEditingControl = TextEditingController();
  final confirmPasswordEditingControl = TextEditingController();
  bool isTermsAccepted = false;
  bool isCondition = false;

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              AppLocalizations.of(context)!.createPassword,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppLocalizations.of(context)!.thisPasswordWill,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.newPassword,
                      style: const TextStyle(fontSize: 14),
                    ),
                    InkWell(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.show)),
                  ],
                )),
            const SizedBox(
              height: 12,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: passwordEditingControl,
                  validator: (String? string) {
                    if (string?.isEmpty == true) {
                      return AppLocalizations.of(context)!.thisFieldNotEmpty;
                    }
                    if (string!.length < 8) {
                      return AppLocalizations.of(context)!.passwordMustContain;
                    }
                    return null;
                  },
                  cursorColor: kPrimaryColor,
                  obscureText: !showPassword,
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      border: OutlineInputBorder(borderSide: BorderSide())),
                )),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.confirmPassword),
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: confirmPasswordEditingControl,
                  validator: (String? string) {
                    if (string?.isEmpty == true) {
                      return AppLocalizations.of(context)!.thisFieldNotEmpty;
                    }
                    if (string!.length < 8) {
                      return AppLocalizations.of(context)!.passwordMustContain;
                    }
                    return null;
                  },
                  cursorColor: kPrimaryColor,
                  obscureText: !showPassword,
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      border: OutlineInputBorder(borderSide: BorderSide())),
                )),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.mustBeAtleast),
                ],
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
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
                      onTap: () {
                        Navigator.of(context).pushNamed(WebViewScreen.router,
                            arguments: {
                              "title": "Learn more",
                              "url": "https://ngydp.io/"
                            });
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .iUnserstandTheRecover(
                                        AppLocalizations.of(context)!.appName)),
                            const TextSpan(
                                text: 'Learn more',
                                style: TextStyle(
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
            ),
            const SizedBox(
              height: 20,
            ),
            WalletButton(
                textContent: AppLocalizations.of(context)!.createPassword,
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    if (!isTermsAccepted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.red,
                          content: Text(
                              "You must to accept the terms and condition to use Cryptomask")));
                      return;
                    }
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    widget.onNext!();
                    widget.getPassword(passwordEditingControl.text);
                  }
                })
          ],
        ),
      ),
    );
  }
}
