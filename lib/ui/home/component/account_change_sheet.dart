import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/import-account/import_account_screen.dart';

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
                itemCount: Provider.of<WalletProvider>(context).wallets.length,
                itemBuilder: (context, index) => ListTile(
                  onTap: () {
                    Provider.of<WalletProvider>(context, listen: false)
                        .changeAccount(index);
                    Navigator.of(context).pop();
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  title: Text(Provider.of<WalletProvider>(context)
                      .getAccountNameFor(Provider.of<WalletProvider>(context)
                          .wallets[index]
                          .wallet
                          .privateKey
                          .address
                          .hex
                          .toLowerCase())),
                  leading: AvatarWidget(
                    radius: 30,
                    address: Provider.of<WalletProvider>(context)
                        .wallets[index]
                        .wallet
                        .privateKey
                        .address
                        .hex,
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
              onTap: () {
                // setState(() {
                //   isAccountCreating = true;
                // });
                Provider.of<WalletProvider>(context, listen: false)
                    .createNewAccount();
                // await context
                //     .read<WalletCubit>()
                //     .createNewAccount(state.password!);
                setState(() {
                  isAccountCreating = false;
                });
              },
              child: isAccountCreating
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    )
                  : const Text(
                      "Create New Account",
                      style: TextStyle(color: kPrimaryColor),
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
              child: const Text(
                "Import Account",
                style: TextStyle(color: kPrimaryColor),
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
  }
}
