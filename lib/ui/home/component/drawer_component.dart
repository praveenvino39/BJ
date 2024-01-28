import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/ui/block-web-view/block_web_view.dart';
import 'package:wallet_cryptomask/ui/home/component/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/home/component/receive_sheet.dart';
import 'package:wallet_cryptomask/ui/login-screen/login_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding/onboard_screen.dart';
import 'package:wallet_cryptomask/ui/setttings/settings_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button_with_icon.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/transaction-history/transaction_history_screen.dart';
import 'package:wallet_cryptomask/ui/webview/web_view_screen.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class DrawerComponent extends StatefulWidget {
  final Function() onReceiveHandler;
  final Function() onSendHandler;
  const DrawerComponent(
      {Key? key, required this.onReceiveHandler, required this.onSendHandler})
      : super(key: key);

  @override
  State<DrawerComponent> createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  onTransactionHistoryHandler() {
    Navigator.of(context).pushNamed(TransactionHistoryScreen.route);
  }

  onSharePublicAddressHandler() {
    sharePublicAddress(Provider.of<WalletProvider>(context, listen: false)
        .activeWallet
        .wallet
        .privateKey
        .address
        .hex);
  }

  viewOnExplorerHandler() {
    Navigator.of(context).pushNamed(BlockWebView.router, arguments: {
      "title": Provider.of<WalletProvider>(context, listen: false)
          .activeNetwork
          .networkName,
      "url": viewAddressOnEtherScan(
        Provider.of<WalletProvider>(context, listen: false).activeNetwork,
        Provider.of<WalletProvider>(context, listen: false)
            .activeWallet
            .wallet
            .privateKey
            .address
            .hex,
      )
    });
  }

  onSettingsHandler() {
    Navigator.of(context).pushNamed(SettingsScreen.route);
  }

  onGetHelpHandler() {
    Navigator.of(context).pushNamed(WebViewScreen.router,
        arguments: {"title": "Help", "url": helpUrl});
  }

  onLogoutHandler() {
    Provider.of<WalletProvider>(context, listen: false).logout().then((value) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
    });
  }

  onDeleteWalletHandler() {
    var alert = AlertDialog(
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(kPrimaryColor)),
            child: const WalletText(
              '',
              localizeKey: 'cancel',
              color: Colors.white,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Provider.of<WalletProvider>(context, listen: false)
                    .eraseWallet()
                    .then((value) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      OnboardScreen.route, (route) => false);
                });
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red)),
              child: const WalletText(
                '',
                localizeKey: "Erase and continue",
                color: Colors.white,
              )),
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
                        fontWeight: FontWeight.bold, color: Colors.red))
              ],
              style: TextStyle(color: Colors.black),
            ),
          ),
        ));

    showDialog(context: context, builder: (context) => alert);
  }

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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      elevation: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.grey.withAlpha(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            addHeight(SpacingSize.xl),
                            const WalletText(
                              '',
                              localizeKey: 'appName',
                              textVarient: TextVarient.hero,
                            ),
                            addHeight(SpacingSize.s),
                            AvatarWidget(
                              radius: 65,
                              address: Provider.of<WalletProvider>(context)
                                  .activeWallet
                                  .wallet
                                  .privateKey
                                  .address
                                  .hex,
                            ),
                            addHeight(SpacingSize.xs),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop;
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        const AccountChangeSheet());
                              },
                              child: Row(
                                children: [
                                  WalletText(
                                    '',
                                    localizeKey:
                                        Provider.of<WalletProvider>(context)
                                            .getAccountName(),
                                    textVarient: TextVarient.body1,
                                    bold: true,
                                  ),
                                  const Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            ),
                            WalletText(
                              '',
                              localizeKey: Provider.of<WalletProvider>(context)
                                  .getNativeBalanceFormatted(),
                            ),
                            addHeight(SpacingSize.xs),
                            WalletText('',
                                localizeKey: showEllipse(
                                    Provider.of<WalletProvider>(context)
                                        .activeWallet
                                        .wallet
                                        .privateKey
                                        .address
                                        .hex)),
                            addHeight(SpacingSize.xs),
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
                              onPressed: widget.onSendHandler,
                            )),
                            addHeight(SpacingSize.xs),
                            Expanded(
                              child: WalletButtonWithIcon(
                                  textContent:
                                      AppLocalizations.of(context)!.receive,
                                  onPressed: widget.onReceiveHandler,
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
                            onTap: onTransactionHistoryHandler,
                            child: Row(
                              children: [
                                const Icon(Icons.menu),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(AppLocalizations.of(context)!
                                    .transactionHistory),
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
                        onTap: onSharePublicAddressHandler,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.share),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(AppLocalizations.of(context)!
                                    .shareMyPubliAdd),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: viewOnExplorerHandler,
                              child: Row(
                                children: [
                                  const Icon(Icons.remove_red_eye),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(AppLocalizations.of(context)!
                                      .viewOnEtherscan),
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
                            onTap: onSettingsHandler,
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
                            onTap: onGetHelpHandler,
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
                            onTap: onLogoutHandler,
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
                            onTap: onDeleteWalletHandler,
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
                          const SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ),
                  ])),
        );
      },
    );
  }
}
