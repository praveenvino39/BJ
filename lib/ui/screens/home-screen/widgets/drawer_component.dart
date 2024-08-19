import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/remote/response-model/settings_response.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/block-web-view-screen/block_web_view.dart';
import 'package:wallet_cryptomask/ui/screens/contacts-screen/all_contact_screen.dart';
import 'package:wallet_cryptomask/ui/screens/home-screen/widgets/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/shared/avatar_widget.dart';
import 'package:wallet_cryptomask/ui/screens/login-screen/login_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding-screen/onboard_screen.dart';
import 'package:wallet_cryptomask/ui/screens/setttings-screen/settings_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button_with_icon.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/screens/transaction-history-screen/transaction_history_screen.dart';
import 'package:wallet_cryptomask/ui/screens/web-view-screen/web_view_screen.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

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
  final settings = Get.find<Settings>();
  onTransactionHistoryHandler() {
    context.push(() => const TransactionHistoryScreen());
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
    context.push(
      () => BlockWebView(
        title: Provider.of<WalletProvider>(context, listen: false)
            .activeNetwork
            .networkName,
        url: viewAddressOnEtherScan(
          Provider.of<WalletProvider>(context, listen: false).activeNetwork,
          Provider.of<WalletProvider>(context, listen: false)
              .activeWallet
              .wallet
              .privateKey
              .address
              .hex,
        ),
      ),
    );
  }

  onSettingsHandler() {
    context.push(() => const SettingsScreen());
  }

  onGetHelpHandler() {
    context.push(
      () => WebViewScreen(
          url: settings.helpUrl, title: getText(context, key: 'help')),
    );
  }

  onLogoutHandler() {
    Provider.of<WalletProvider>(context, listen: false).logout().then((value) {
      context.pushAndRemoveUntil(
        removeUntil: bool,
        builder: () => const LoginScreen(),
      );
    });
  }

  onDeleteWalletHandler() {
    var alert = StatefulBuilder(
      builder: (context, setState) => AlertDialog(
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(kPrimaryColor)),
              child: const WalletText(
                localizeKey: 'cancel',
                color: Colors.white,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Provider.of<WalletProvider>(context, listen: false)
                      .eraseWallet()
                      .then((value) {
                    context.pushAndRemoveUntil(
                        removeUntil: bool,
                        builder: () => const OnboardScreen());
                  });
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red)),
                child: const WalletText(
                  localizeKey: 'eraseAndContinue',
                  color: Colors.white,
                )),
          ],
          title: const WalletText(
            localizeKey: 'confirmation',
          ),
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: getText(context, key: 'eraseWarning'),
                    style: GoogleFonts.poppins()),
                TextSpan(
                    text: getText(context, key: 'irreversible'),
                    style: GoogleFonts.poppins().copyWith(
                        fontWeight: FontWeight.bold, color: Colors.red))
              ],
              style: const TextStyle(color: Colors.black),
            ),
          )),
    );

    showDialog(context: context, builder: (context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width / 1.25,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                          builder: (context) => const AccountChangeSheet());
                    },
                    child: Row(
                      children: [
                        WalletText(
                          localizeKey: Provider.of<WalletProvider>(context)
                              .getAccountName(),
                          textVarient: TextVarient.body1,
                          bold: true,
                        ),
                        const Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                  WalletText(
                    localizeKey: Provider.of<WalletProvider>(context)
                        .getNativeBalanceFormatted(),
                  ),
                  addHeight(SpacingSize.xs),
                  WalletText(
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
                    textContent: getText(context, key: 'send'),
                    onPressed: widget.onSendHandler,
                  )),
                  addHeight(SpacingSize.xs),
                  Expanded(
                    child: WalletButtonWithIcon(
                        textContent: getText(context, key: 'receive'),
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
                addHeight(SpacingSize.m),
                Row(
                  children: [
                    const Icon(Icons.wallet),
                    addWidth(SpacingSize.s),
                    const WalletText(
                      localizeKey: 'wallet',
                    ),
                  ],
                ),
                addHeight(SpacingSize.m),
                InkWell(
                  onTap: () {
                    context.push(() => const AllContactScreen());
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.contact_phone,
                      ),
                      addWidth(SpacingSize.s),
                      const WalletText(
                        localizeKey: "contact",
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                addHeight(SpacingSize.m),
                InkWell(
                  onTap: onTransactionHistoryHandler,
                  child: Row(
                    children: [
                      const Icon(Icons.menu),
                      addWidth(SpacingSize.s),
                      const WalletText(
                        localizeKey: 'transactionHistory',
                      ),
                    ],
                  ),
                ),
                addHeight(SpacingSize.m),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.withAlpha(70),
          ),
          addHeight(SpacingSize.s),
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
                      addWidth(SpacingSize.s),
                      const WalletText(
                        localizeKey: 'shareMyPubliAdd',
                      ),
                    ],
                  ),
                  addHeight(SpacingSize.m),
                  InkWell(
                    onTap: viewOnExplorerHandler,
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye),
                        addWidth(SpacingSize.s),
                        const WalletText(
                          localizeKey: 'viewOnEtherscan',
                        ),
                      ],
                    ),
                  ),
                  addHeight(SpacingSize.m),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.withAlpha(70),
          ),
          addHeight(SpacingSize.s),
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
                      addWidth(SpacingSize.s),
                      const WalletText(
                        localizeKey: 'settings',
                      ),
                    ],
                  ),
                ),
                addHeight(SpacingSize.m),
                InkWell(
                  onTap: onGetHelpHandler,
                  child: Row(
                    children: [
                      const Icon(Icons.help_outline_rounded),
                      addWidth(SpacingSize.s),
                      const WalletText(localizeKey: 'getHelp'),
                    ],
                  ),
                ),
                addHeight(SpacingSize.m),
                InkWell(
                  onTap: onLogoutHandler,
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      addWidth(SpacingSize.s),
                      const WalletText(
                        localizeKey: 'logout',
                      ),
                    ],
                  ),
                ),
                addHeight(SpacingSize.m),
                InkWell(
                  onTap: onDeleteWalletHandler,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      addWidth(SpacingSize.s),
                      const WalletText(
                          localizeKey: 'deleteWallet', color: Colors.red),
                    ],
                  ),
                ),
                addHeight(SpacingSize.l),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
