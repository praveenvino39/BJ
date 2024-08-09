// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routerino/routerino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/setttings-screen/security_settings_screen/security_settings_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:web3dart/web3dart.dart';

String showEllipse(String string) {
  int length = string.length;
  if (length > 6) {
    String prefix = string.substring(0, 5);
    String suffix = string.substring(length - 5, length);
    return "$prefix...$suffix";
  }
  return string;
}

copyAddressToClipBoard(String address, BuildContext context,
    {bool isPk = false}) {
  log(address);
  Clipboard.setData(
    ClipboardData(text: address),
  ).then((value) {
    showPositiveSnackBar(
        context,
        getText(context, key: 'copied'),
        isPk
            ? getText(context, key: 'pkCopied')
            : getText(context, key: 'addCopied'));
  });
}

showConfirmationDialog({
  required BuildContext context,
  required String question,
  required String primaryCtaText,
  required String secondaryCtaText,
  required Function() primaryOnPress,
  required Function() secondaryOnPress,
}) {
  final alert = StatefulBuilder(
    builder: (context, setState) => AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        width: context.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WalletText(
              localizeKey: question,
            ),
            addHeight(SpacingSize.m),
            Row(
              children: [
                Expanded(
                  child: WalletButton(
                    textSize: 14.0,
                    localizeKey: secondaryCtaText,
                    onPressed: secondaryOnPress,
                    type: WalletButtonType.outline,
                  ),
                ),
                Expanded(
                  child: WalletButton(
                    textSize: 14.0,
                    localizeKey: primaryCtaText,
                    onPressed: primaryOnPress,
                    type: WalletButtonType.filled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  showDialog(context: context, builder: (context) => alert);
}

Future<TransactionReceipt> getTransactionReceiptFromHash(
    BuildContext context, String hash) {
  Completer<TransactionReceipt> completor = Completer();
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    final transactionReceipt =
        await getWalletProvider(context).web3client.getTransactionReceipt(hash);
    if (transactionReceipt != null) {
      timer.cancel();
      completor.complete(transactionReceipt);
    }
  });
  return completor.future;
}

showPasswordInputModal(
  BuildContext context,
  Function() onVerified,
) {
  final passwordEditingController = TextEditingController();
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          child: Column(children: [
            WalletTextField(
                textEditingController: passwordEditingController,
                textFieldType: TextFieldType.password,
                labelLocalizeKey: 'password'),
            addHeight(SpacingSize.m),
            WalletButton(
              onPressed: () async {
                final password = (await const FlutterSecureStorage().read(
                      key: "password",
                    )) ??
                    "";
                Navigator.of(context).pop();
                final inputPassword = passwordEditingController.text;
                passwordEditingController.clear();
                if (inputPassword == password) {
                  await onVerified();
                  return context.push(() => const SecuritySettingsScreen());
                }
                showErrorSnackBar(context, getText(context, key: 'invalid'),
                    getText(context, key: 'passwordIsInvalid'));
              },
              localizeKey: 'verify',
            )
          ]),
        );
      });
    },
  );
}

goToSecuritySettings(BuildContext context, Function() onVerified) {
  showPasswordInputModal(context, onVerified);
}

copyToClipBoard(BuildContext context, String content, String message) {
  log(content);
  Clipboard.setData(
    ClipboardData(text: content),
  ).then((value) {
    showPositiveSnackBar(context, getText(context, key: 'copied'), message);
  });
}

showErrorSnackBar(BuildContext context, String errorTitle, String error) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Row(
      children: [
        const SizedBox(
            width: 25,
            height: 25,
            child: Icon(
              Icons.error,
              color: Colors.white,
            )),
        addWidth(SpacingSize.m),
        SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 4,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                height: 35,
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    duration: const Duration(seconds: 7),
  ));
}

renderAlert(BuildContext context, String? buttonKey, Function()? onPress,
    {required String localizeKey}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
        color: kPrimaryColor.withAlpha(50),
        border: Border.all(width: 1, color: kPrimaryColor),
        borderRadius: BorderRadius.circular(7)),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error,
              color: kPrimaryColor,
            ),
            addWidth(SpacingSize.xs),
            Expanded(
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                  style: GoogleFonts.poppins(color: Colors.black),
                  text: getText(context, key: localizeKey),
                ),
                TextSpan(
                  style: GoogleFonts.poppins(color: Colors.black),
                  text: getText(context, key: buttonKey != null ? ', ' : ''),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()..onTap = onPress,
                  style: GoogleFonts.poppins(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                  text: getText(context, key: buttonKey ?? ''),
                )
              ])),
            )
          ],
        ),
      ],
    ),
  );
}

showPositiveSnackBar(BuildContext context, String errorTitle, String error) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.green,
    content: Row(
      children: [
        const SizedBox(
            width: 25,
            height: 25,
            child: Icon(
              Icons.check,
              color: Colors.white,
            )),
        addWidth(SpacingSize.m),
        SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 4,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                height: 35,
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    duration: const Duration(seconds: 7),
  ));
}

shareSendUrl(String address) async {
  await Share.share("https://wallet.app.link/send/$address");
}

sharePublicAddress(String address) async {
  await Share.share(address);
}

shareBlockViewerUrl(String url) async {
  await Share.share(url);
}

String viewAddressOnEtherScan(Network network, String address) {
  String composedUrl = network.addressViewUrl + address;
  return composedUrl;
}

bool isValidAddress(String address) {
  return true;
}

class Util {
  static bool urlIsSecure(Uri url) {
    return (url.scheme == "https") || Util.isLocalizedContent(url);
  }

  static bool isLocalizedContent(Uri url) {
    return (url.scheme == "file" ||
        url.scheme == "chrome" ||
        url.scheme == "data" ||
        url.scheme == "javascript" ||
        url.scheme == "about");
  }

  static bool isAndroid() {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static bool isIOS() {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }
}
