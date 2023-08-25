part of 'locale_cubit.dart';

@immutable
abstract class LocaleState {}

class LocaleInitial extends LocaleState {
  final String locale;
  LocaleInitial({required this.locale});
}

// class LocaleChanged extends LocaleInitial {
//   LocaleChanged({required super.locale});
// }
