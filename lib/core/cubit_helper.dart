import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:wallet/core/bloc/collectible-bloc/cubit/collectible_cubit.dart';
import 'package:wallet/core/bloc/preference-bloc/cubit/preference_cubit.dart';
import 'package:wallet/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';

WalletLoaded getWalletLoadedState(BuildContext context) {
  return (context.read<WalletCubit>().state as WalletLoaded);
}

CollectibleLoaded getCollectibleLoadedState(BuildContext context) {
  return (context.read<CollectibleCubit>().state as CollectibleLoaded);
}

TokenCubit getTokenCubit(BuildContext context) => context.read<TokenCubit>();

CollectibleCubit getCollectibleCubit(BuildContext context) =>
    context.read<CollectibleCubit>();

Box getPreference(BuildContext context) =>
    (context.read<PreferenceCubit>().state as PreferenceInitial).userPreference;
