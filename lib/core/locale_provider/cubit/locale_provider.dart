// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'locale_state.dart';

class LocaleProvider extends ChangeNotifier {
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
