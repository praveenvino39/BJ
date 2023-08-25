import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';
import 'package:wallet/ui/import-account/import_account_screen.dart';

class AccountChangeSheet extends StatefulWidget {
  final Function(String address)? onChange;
  const AccountChangeSheet({Key? key, this.onChange}) : super(key: key);

  @override
  State<AccountChangeSheet> createState() => _AccountChangeSheetState();
}

class _AccountChangeSheetState extends State<AccountChangeSheet> {
  bool isAccountCreating = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withAlpha(60),
                  ),
                  width: 50,
                  height: 4,
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.withAlpha(60),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: (state as WalletLoaded).availabeWallet.length,
                    itemBuilder: (context, index) => ListTile(
                      onTap: () async {
                        await context.read<WalletCubit>().changeAccount(index);
                        if (widget.onChange != null) {
                          widget.onChange!(state.availabeWallet[index].wallet
                              .privateKey.address.hex);
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 16),
                      title: Text(state.availabeWallet[index].accountName),
                      leading: AvatarWidget(
                        radius: 30,
                        address: state
                            .availabeWallet[index].wallet.privateKey.address.hex
                            .toString(),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.withAlpha(60),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      isAccountCreating = true;
                    });
                    await context
                        .read<WalletCubit>()
                        .createNewAccount(state.password!);
                    setState(() {
                      isAccountCreating = false;
                    });
                  },
                  child: isAccountCreating
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: kPrimaryColor),
                        )
                      : const Text(
                          "Create New Account",
                          style:  TextStyle(color: kPrimaryColor),
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.withAlpha(60),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pushNamed(ImportAccount.route);
                  },
                  child: const Text("Import Account",
                          style:  TextStyle(color: kPrimaryColor),
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.withAlpha(60),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
