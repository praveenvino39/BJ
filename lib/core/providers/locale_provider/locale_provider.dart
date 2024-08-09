// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class LocaleProvider extends ChangeNotifier {
  static final supportedLocales = [
    const Locale('en', 'US'),
    const Locale('es', 'ES'),
    const Locale('fr', 'FR'),
  ];
  String locale = 'en';
  LocaleProvider({required this.locale});

  void changeLocale(String locale) async {
    Box box = await Hive.openBox("user_preference");
    box.put("LOCALE", locale);
    this.locale = locale;
    notifyListeners();
  }

  getLocale() async {
    Box box = await Hive.openBox("user_preference");
    box.get("LOCALE") ?? "en";
    locale = locale;
    notifyListeners();
  }
}

getLocalProvider(BuildContext context) => context.read<LocaleProvider>();
LocaleProvider getLiveLocalProvider(BuildContext context) =>
    Provider.of<LocaleProvider>(context);
