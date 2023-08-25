import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/ui/block-web-view/block_web_view.dart';
import 'package:wallet/ui/home/component/account_change_sheet.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';
import 'package:wallet/ui/home/component/receive_sheet.dart';
import 'package:wallet/ui/onboard/onboard_screen.dart';
import 'package:wallet/ui/setttings/settings_screen.dart';
import 'package:wallet/ui/shared/wallet_button_with_icon.dart';
import 'package:wallet/ui/transaction-history/transaction_history_screen.dart';
import 'package:wallet/ui/transfer/transfer_screen.dart';
import 'package:wallet/ui/webview/web_view_screen.dart';
import 'package:wallet/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DrawerComponent extends StatelessWidget {
  final String address;
  final double balanceInUSD;
  const DrawerComponent(
      {Key? key, required this.address, required this.balanceInUSD})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width / 1.25,
              color: Colors.white,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Material(
                  elevation: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.grey.withAlpha(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        const Text(
                          appName,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                              fontSize: 25,
                              letterSpacing: 5),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        AvatarWidget(
                          radius: 65,
                          address: address,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop;
                            showModalBottomSheet(
                                context: context,
                                builder: (context) => const AccountChangeSheet());
                          },
                          child: Row(
                            children: [
                              Text(
                                getAccountName(state as WalletLoaded),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                        Text(
                            "${state.balanceInNative} ${state.currentNetwork.currency}"),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(showEllipse(address)),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  elevation: 0.5,
                  child: Container(
                    color: Colors.grey.withAlpha(10),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                            child: WalletButtonWithIcon(
                          icon: const Icon(
                            Icons.call_made,
                            size: 15,
                          ),
                          textContent: AppLocalizations.of(context)!.send,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(TransferScreen.route, arguments: {
                              "balance": (state).balanceInNative.toString(),
                              "token": Token(
                                  tokenAddress: "",
                                  symbol: getWalletLoadedState(context)
                                      .currentNetwork
                                      .symbol,
                                  decimal: 18,
                                  balance: 0,
                                  balanceInFiat: 0)
                            });
                          },
                        )),
                        // SizedBox(
                        //   width: 10,
                        // ),
                        Expanded(
                          child: WalletButtonWithIcon(
                              textContent: AppLocalizations.of(context)!.receive,
                              onPressed: () {
                                Navigator.of(context).pop();
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        ReceiveSheet(address: address));
                              },
                              icon: const Icon(
                                Icons.call_received,
                                size: 15,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.wallet),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(AppLocalizations.of(context)!.wallet),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(TransactionHistoryScreen.route);
                          // Navigator.of(context)
                          //     .pushNamed(BlockWebView.router, arguments: {
                          //   "title": (state as WalletLoaded)
                          //       .currentNetwork
                          //       .networkName,
                          //   "url": viewAddressOnEtherScan(
                          //       state.currentNetwork, address),
                          //   "isTransaction": true
                          // });
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.menu),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                                AppLocalizations.of(context)!.transactionHistory),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.withAlpha(70),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => sharePublicAddress(address),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.share),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(AppLocalizations.of(context)!.shareMyPubliAdd),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(BlockWebView.router, arguments: {
                              "title": (state).currentNetwork.networkName,
                              "url": viewAddressOnEtherScan(state.currentNetwork,
                                  state.wallet.privateKey.address.hex)
                            });
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.remove_red_eye),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(AppLocalizations.of(context)!.viewOnEtherscan),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.withAlpha(70),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(SettingsScreen.route);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.settings_outlined),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(AppLocalizations.of(context)!.settings),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(WebViewScreen.router, arguments: {
                            "title": "Help",
                            "url": helpUrl
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.help_outline_rounded),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(AppLocalizations.of(context)!.getHelp),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          context.read<WalletCubit>().logout();
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.logout),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(AppLocalizations.of(context)!.logout),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          var alert = AlertDialog(
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          kPrimaryColor)),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      context.read<WalletCubit>().eraseWallet();
                                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const OnboardScreen(),), (route) => false);
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red)),
                                    child: const Text("Erase and continue")),
                              ],
                              title: const Text("Confirmation"),
                              content: SizedBox(
                                child: RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                          text:
                                              'This action will erase all previous wallets and all funds will be lost. Make sure you can restore with your saved 12 word secret phrase and private keys for each wallet before you erase!.'),
                                      TextSpan(
                                          text: ' This action is irreversible',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))
                                    ],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ));
        
                          showDialog(
                              context: context, builder: (context) => alert);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              AppLocalizations.of(context)!.deleteWallet,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30,)
                    ],
                  ),
                ),
              ])),
        );
      },
    );
  }
}
