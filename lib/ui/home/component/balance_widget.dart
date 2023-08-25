import 'package:flutter/material.dart';

import '../../../constant.dart';
import '../../../core/bloc/wallet-bloc/cubit/wallet_cubit.dart';


class BalanceWidget extends StatefulWidget {
  const BalanceWidget({Key? key}) : super(key: key);

  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}


class _BalanceWidgetState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: kPrimaryColor.withAlpha(80),
          borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Text((context as dynamic).read<WalletCubit>().state.toString()),
    );
  }
}