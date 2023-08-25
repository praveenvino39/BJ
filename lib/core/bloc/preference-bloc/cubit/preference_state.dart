part of 'preference_cubit.dart';

@immutable
abstract class PreferenceState {}

class PreferenceInitial extends PreferenceState {
  final Box userPreference;
  PreferenceInitial({required this.userPreference});
}