// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

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
                title: const WalletText(
                  localizeKey: 'updateAvailable',
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        '${getText(context, key: 'availableVersions')}: ${update.availableVersionCode}'),
                    addHeight(SpacingSize.m),
                    WalletButton(
                        localizeKey: 'update',
                        onPressed: () {
                          InAppUpdate.performImmediateUpdate()
                              // ignore: invalid_return_type_for_catch_error
                              .catchError((e) => debugPrint(e.toString()));
                        })
                  ],
                ),
              ),
            ),
          );
        }
      }).catchError((e) {
        debugPrint(e.toString());
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
                title: const WalletText(
                  localizeKey: 'updateAvailable',
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(getTextWithPlaceholder(context,
                        key: 'newVersions', string: appName)),
                    addHeight(SpacingSize.s),
                    Row(
                      children: [
                        const WalletText(
                            localizeKey: 'currentVersion',
                            fontWeight: FontWeight.bold),
                        Expanded(child: Text(status.localVersion)),
                      ],
                    ),
                    Row(
                      children: [
                        const WalletText(
                            localizeKey: 'availableVersions',
                            fontWeight: FontWeight.bold),
                        Expanded(child: Text(status.storeVersion)),
                      ],
                    ),
                    addHeight(SpacingSize.s),
                    const Text(
                      "What's new :",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(status.releaseNotes ??
                        getText(context, key: 'improvePerformance')),
                    addHeight(SpacingSize.m),
                    WalletButton(
                        localizeKey: 'update',
                        onPressed: () async {
                          debugPrint(status.appStoreLink);
                          if (!await launchUrl(
                            Uri.parse(status.appStoreLink),
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw '${getText(context, key: 'couldNot')} ${status.appStoreLink}';
                          }
                        })
                  ],
                ),
              ),
            ),
          );
        }
      }).catchError((e) {
        debugPrint(e.toString());
      });
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}
