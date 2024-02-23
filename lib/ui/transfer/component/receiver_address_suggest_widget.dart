import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReceiverAddressSuggestionWidget extends StatelessWidget {
  final bool isAddressValid;
  final Function(String address) onAccountSelect;
  final List<dynamic> recentTransactionList;
  const ReceiverAddressSuggestionWidget(
      {Key? key,
      required this.isAddressValid,
      required this.onAccountSelect,
      this.recentTransactionList = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey.withAlpha(70),
              height: 1.5,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Text(
                AppLocalizations.of(context)!.transferBetweenMy,
                style: const TextStyle(color: kPrimaryColor),
              ),
            ),
            Container(
              color: Colors.grey.withAlpha(70),
              height: 1.5,
              width: double.infinity,
            ),
            ListView.builder(
              itemCount: Provider.of<WalletProvider>(context).wallets.length,
              shrinkWrap: true, // Set this
              itemBuilder: ((context, index) => Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.withAlpha(70)))),
                    child: ListTile(
                      onTap: () {
                        onAccountSelect(
                            Provider.of<WalletProvider>(context, listen: false)
                                .wallets[index]
                                .wallet
                                .privateKey
                                .address
                                .hex);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 16),
                      title: Text(showEllipse(
                          Provider.of<WalletProvider>(context)
                              .wallets[index]
                              .wallet
                              .privateKey
                              .address
                              .hex)),
                      leading: AvatarWidget(
                          radius: 30,
                          address: Provider.of<WalletProvider>(context)
                              .wallets[index]
                              .wallet
                              .privateKey
                              .address
                              .hex),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Text(
                AppLocalizations.of(context)!.recent,
                style: const TextStyle(color: kPrimaryColor),
              ),
            ),
            Container(
              color: Colors.grey.withAlpha(70),
              height: 1.5,
              width: double.infinity,
            ),
            Expanded(
              child: recentTransactionList.isNotEmpty
                  ? ListView.builder(
                      itemCount: recentTransactionList.length,
                      shrinkWrap: true, // Set this
                      itemBuilder: ((context, index) => Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1,
                                        color: Colors.grey.withAlpha(70)))),
                            child: ListTile(
                              onTap: () =>
                                  onAccountSelect(recentTransactionList[index]),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 16),
                              title: Text(
                                  showEllipse(recentTransactionList[index])),
                              leading: AvatarWidget(
                                radius: 30,
                                address: recentTransactionList[index],
                              ),
                            ),
                          )),
                    )
                  : Center(
                      child: Column(
                        children: const [
                          Expanded(
                              child:
                                  Center(child: Text("No recent transaction"))),
                          // ElevatedButton(onPressed: (){
                          //   Hive.openBox("user_preference").then((box) {
                          //     box.delete("RECENT-TRANSACTION-ADDRESS");
                          //   });
                          // }, child: const Text("Clear"))
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
