import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/model/network_model.dart';

String showEllipse(String string) {
  int length = string.length;
  if (length > 10) {
    String prefix = string.substring(0, 4);
    String suffix = string.substring(length - 4, length);
    return "$prefix...$suffix";
  }
  return "Loading...";
}

String getAccountName(WalletLoaded state) {
  return (state)
      .availabeWallet
      .firstWhere((element) =>
          element.wallet.privateKey.address.hex ==
          state.wallet.privateKey.address.hex)
      .accountName;
} 

Future<void> copyAddressToClipBoard(
    String address, BuildContext context,{bool isPk = false}) async {
  log(address);
  await Clipboard.setData(
    ClipboardData(text: address),
  );
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
      elevation: 10,
      backgroundColor: Colors.green,
      content: Text( isPk ? "Privatekey copied to clipboard" :"Public address copied to clipboard"),
    ),
  );
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
