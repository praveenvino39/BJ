// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/setttings/security_settings_screen/security_settings_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';
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

String getAccountName(WalletLoaded state) {
  return (state)
      .availabeWallet
      .firstWhere((element) =>
          element.wallet.privateKey.address.hex ==
          state.wallet.privateKey.address.hex)
      .accountName;
}

copyAddressToClipBoard(String address, BuildContext context,
    {bool isPk = false}) {
  log(address);
  Clipboard.setData(
    ClipboardData(text: address),
  ).then((value) {
    showPositiveSnackBar(
        context,
        'Copied',
        isPk
            ? "Privatekey copied to clipboard"
            : "Public address copied to clipboard");
  });
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
            const SizedBox(
              height: 20,
            ),
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
                  return Navigator.of(context)
                      .pushNamed(SecuritySettingsScreen.route);
                }
                showErrorSnackBar(
                    context, "Invalid", "Passwod is invalid, Please try again");
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
    showPositiveSnackBar(context, 'Copied', message);
  });
}

showSuccessSnackbar(BuildContext context, String title, String subtitle) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        const SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            )),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          height: 38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
    duration: const Duration(seconds: 3),
  ));
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
        const SizedBox(
          width: 20,
        ),
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
        const SizedBox(
          width: 20,
        ),
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

Future<String> getMetadataURL(
    {required Web3Client web3client,
    required DeployedContract contract,
    required String tokenId}) async {
  var uriTokenFunction = contract.function('tokenURI');
  var uriResult = await web3client
      .call(contract: contract, function: uriTokenFunction, params: [
    BigInt.parse(tokenId),
  ]);
  String jsonURI = uriResult[0];
  final uriData = getSource(jsonURI);
  return uriData.url;
}

class UriData {
  final String url;
  final MetadataSource metadataSource;

  UriData({required this.url, required this.metadataSource});
}

enum MetadataSource {
  ipfs,
  http,
}

UriData getSource(String uri) {
  RegExp ipfsRegex = RegExp(r'(?<=ipfs:\/\/).*$', multiLine: true);
  Match? ipfsMatch = ipfsRegex.firstMatch(uri);
  if (ipfsMatch != null) {
    String content = ipfsMatch.group(0)!;
    return UriData(
        url: "https://ipfs.io/ipfs/$content",
        metadataSource: MetadataSource.ipfs);
  }

  RegExp httpRegex = RegExp(r'(?:https?://).*$', multiLine: true);
  Match? httpMatch = httpRegex.firstMatch(uri);
  if (httpMatch != null) {
    String content = httpMatch.group(0)!;
    return UriData(url: content, metadataSource: MetadataSource.http);
  }

  return UriData(
      url: "https://ipfs.io/ipfs/$uri", metadataSource: MetadataSource.ipfs);
}
