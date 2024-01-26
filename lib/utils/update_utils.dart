import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';

checkForUpdate(BuildContext context) {
  try {
    if (Platform.isAndroid) {
      InAppUpdate.checkForUpdate().then((update) {
        if (update.updateAvailability == UpdateAvailability.updateAvailable) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => PopScope(
              canPop: false,
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
                              // ignore: invalid_return_type_for_catch_error
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
            builder: (context) => PopScope(
              canPop: false,
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
}
