import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
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
                title: const Text("Update available"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Available version: ${update.availableVersionCode}'),
                    addHeight(SpacingSize.m),
                    WalletButton(
                        textContent: "Update",
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
    // if (Platform.isIOS) {
    //   final newVersion = NewVersion();
    //   newVersion.getVersionStatus().then((status) {
    //     if (status != null && status.canUpdate) {
    //       showDialog(
    //         barrierDismissible: false,
    //         context: context,
    //         builder: (context) => PopScope(
    //           canPop: false,
    //           child: AlertDialog(
    //             title: const Text("Update available"),
    //             content: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 const Text(
    //                     "New version of $appName is available on App Store."),
    //                 addHeight(SpacingSize.s),
    //                 Row(
    //                   children: [
    //                     const Text(
    //                       'Current version: ',
    //                       style: TextStyle(fontWeight: FontWeight.bold),
    //                     ),
    //                     Expanded(child: Text(status.localVersion)),
    //                   ],
    //                 ),
    //                 Row(
    //                   children: [
    //                     const Text(
    //                       'Available version: ',
    //                       style: TextStyle(fontWeight: FontWeight.bold),
    //                     ),
    //                     Expanded(child: Text(status.storeVersion)),
    //                   ],
    //                 ),
    //                 addHeight(SpacingSize.s),
    //                 const Text(
    //                   "What's new :",
    //                   style: TextStyle(fontWeight: FontWeight.bold),
    //                 ),
    //                 Text(status.releaseNotes ??
    //                     "Improved performance and stability."),
    //                 addHeight(SpacingSize.m),
    //                 WalletButton(
    //                     textContent: "Update",
    //                     onPressed: () async {
    //                       debugPrint(status.appStoreLink);
    //                       if (!await launchUrl(
    //                         Uri.parse(status.appStoreLink),
    //                         mode: LaunchMode.externalApplication,
    //                       )) {
    //                         throw 'Could not launch ${status.appStoreLink}';
    //                       }
    //                     })
    //               ],
    //             ),
    //           ),
    //         ),
    //       );
    //     }
    //   }).catchError((e) {
    //     debugPrint(e.toString());
    //   });
    // }
  } catch (e) {
    debugPrint(e.toString());
  }
}
