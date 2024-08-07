// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet_cryptomask/main_app.dart';
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/contact_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/ui/login-screen/login_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding/onboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    Core.networks.removeWhere((element) => element.chainId == 11155111);
  }

  await loadAppSettings();

  await initHiveAdapter();

  Box box = await Hive.openBox("user_preference");

  runApp(
    SizedBox(
      width: 200,
      child: MainApp(
        locale: await getAppLocale(box),
        initialWidget: await getInitialWidget(),
        userPreferenceBox: box,
      ),
    ),
  );
}

initHiveAdapter() async {
  if (kIsWeb) {
    Hive
      ..init("")
      ..registerAdapter(TokenAdapter())
      ..registerAdapter(CollectibleAdapter())
      ..registerAdapter(ContactAdapter());
  } else {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive
      ..init(appDocumentDirectory.path)
      ..registerAdapter(TokenAdapter())
      ..registerAdapter(CollectibleAdapter())
      ..registerAdapter(ContactAdapter());
  }
}

loadAppSettings() async {
  try {
    final settingsResponse = await RemoteServer.settings();
    Get.put(settingsResponse.data);
  } catch (e) {
    log(e.toString());
  }
}

getAppLocale(Box box) async {
  return (await box.get("LOCALE")) ?? "en";
}

Future<Widget> getInitialWidget() async {
  FlutterSecureStorage fss = const FlutterSecureStorage();
  String? wallet = await fss.read(key: "wallet");
  if (wallet != null) {
    return const LoginScreen();
  } else {
    return const OnboardScreen();
  }
}
