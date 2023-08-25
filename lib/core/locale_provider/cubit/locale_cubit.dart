// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  String locale;
  LocaleCubit({required this.locale}) : super(LocaleInitial(locale: locale));

  void changeLocale(String locale) async {
    Box box = await Hive.openBox("user_preference");
    box.put("LOCALE", locale) ;
    emit(LocaleInitial(locale: locale));
  }


  Future<String> getLocale() async {
    Box box = await Hive.openBox("user_preference");
    return box.get("LOCALE") ?? "en" ;
   
  }
}

