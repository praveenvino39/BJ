// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/contact_provider/contact_provider.dart';
import 'package:wallet_cryptomask/core/bloc/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';
import 'package:wallet_cryptomask/core/socket/message_engine.dart';
import 'package:wallet_cryptomask/ui/atoms/custom_icon_button.dart';
import 'package:wallet_cryptomask/ui/browser/browser_screen.dart';
import 'package:wallet_cryptomask/ui/home/component/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/home/component/drawer_component.dart';
import 'package:wallet_cryptomask/ui/home/component/receive_sheet.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/support/chat_screen.dart';
import 'package:wallet_cryptomask/ui/token/token_tab.dart';
import 'package:wallet_cryptomask/ui/transfer/transfer_screen.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

import 'component/avatar_component.dart';

class HomeScreen extends StatefulWidget {
  static String route = "home_screen";

  // final String password;
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  InAppWebViewController? webViewController;
  final TextEditingController nameEditingController = TextEditingController();
  final user = Get.find<User>();
  String address = "null";
  bool switchEditName = false;
  String accountName = "";
  String currency = "";
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  final GlobalKey<ScaffoldState> _fakeScafoldKey = GlobalKey();
  int index = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    final messageEngine = MessageEngine.getMessageEngine(context);
    if (user.token != null) {
      messageEngine.socketService.forId = user.id;
      messageEngine.setToken(user.token!);
    }
    getContactProvider(context).loadContacts();
    getWalletProvider(context).setupWalletConnect();
    getWalletProvider(context).init();
    messageEngine.connect();
    super.initState();
  }

  onAddressTapHandler() {
    getWalletProvider(context).copyPublicAddress().then((value) {
      showPositiveSnackBar(
          context, 'Success', 'Public address copied to clipboard');
    });
  }

  onReceiveHandler() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return ReceiveSheet(
            address: getWalletProvider(context)
                .activeWallet
                .wallet
                .privateKey
                .address
                .hex,
          );
        });
  }

  onSendHandler() {
    Navigator.of(context).pushNamed(TransferScreen.route, arguments: {
      "balance": getWalletProvider(context).nativeBalance.toString(),
      "token": Token(
          tokenAddress: "",
          symbol: Provider.of<WalletProvider>(context, listen: false)
              .activeNetwork
              .symbol,
          decimal: 18,
          balance: 0,
          balanceInFiat: 0)
    });
  }

  onAccountChangeHandler() {
    showModalBottomSheet(
        context: context, builder: (context) => const AccountChangeSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            key: _fakeScafoldKey,
            body: Scaffold(
              key: _scafoldKey,
              drawer: DrawerComponent(
                onReceiveHandler: onReceiveHandler,
                onSendHandler: onSendHandler,
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: index,
                onTap: (value) async {
                  setState(() {
                    index = value;
                  });
                },
                selectedItemColor: kPrimaryColor,
                unselectedItemColor: Colors.grey,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.wallet),
                    label: "Wallet",
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.public), label: "Dapp Browser"),
                ],
              ),
              backgroundColor: Colors.white,
              appBar: index == 0
                  ? AppBar(
                      shadowColor: Colors.white,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      title: SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => SizedBox(
                                height: 10,
                                child: AlertDialog(
                                  title: Row(
                                    children: [
                                      const Expanded(
                                        child: WalletText(
                                          '',
                                          localizeKey: "networks",
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Icon(Icons.close))
                                    ],
                                  ),
                                  titlePadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  contentPadding: const EdgeInsets.all(0),
                                  content: Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.black45.withAlpha(20),
                                    child: SizedBox(
                                        child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: Core.networks.length,
                                            itemBuilder: (context, index) =>
                                                ListTile(
                                                  tileColor: Colors.transparent,
                                                  onTap: () async {
                                                    final walletProvider =
                                                        getWalletProvider(
                                                            context);
                                                    walletProvider
                                                        .startNetworkSwitch();
                                                    await walletProvider
                                                        .changeNetwork(index);
                                                    getTokenProvider(context)
                                                        .loadToken(
                                                            nativeBalance:
                                                                getWalletProvider(
                                                                        context)
                                                                    .nativeBalance,
                                                            address: address,
                                                            network:
                                                                Core.networks[
                                                                    index]);
                                                    Navigator.of(context).pop();
                                                  },
                                                  title: Row(
                                                    children: [
                                                      Container(
                                                        width: 7,
                                                        height: 7,
                                                        decoration: BoxDecoration(
                                                            color: Core
                                                                .networks[index]
                                                                .dotColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      WalletText('',
                                                          localizeKey: Core
                                                              .networks[index]
                                                              .networkName),
                                                    ],
                                                  ),
                                                ))),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const WalletText(
                                '',
                                localizeKey: 'appName',
                                fontWeight: FontWeight.w200,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                        color: getLiveWalletProvider(context)
                                            .activeNetwork
                                            .dotColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  WalletText(
                                    '',
                                    localizeKey: getLiveWalletProvider(context)
                                        .activeNetwork
                                        .networkName,
                                    textVarient: TextVarient.body3,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      leading: IconButton(
                          onPressed: () {
                            _scafoldKey.currentState?.openDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.black,
                          )),
                      actions: [
                          IconButton(
                            onPressed: () =>
                                context.push(() => const ChatScreen()),
                            icon: const Icon(Icons.chat),
                            color: Colors.transparent,
                          ),
                        ])
                  : null,
              body: IndexedStack(
                index: index,
                children: [
                  Provider.of<WalletProvider>(context).switchingChain
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : NestedScrollView(
                          body: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 1,
                                  color: Colors.grey.withAlpha(60),
                                ),
                                const Expanded(
                                  child: TokenTab(),
                                ),
                              ],
                            ),
                          ),
                          headerSliverBuilder: (context, _) => [
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        !user.seedPhraseBackedUp
                                            ? renderAlert(
                                                context,
                                                'backUp',
                                                () {
                                                  goToSecuritySettings(
                                                    context,
                                                    () async {
                                                      final walletProvider =
                                                          getWalletProvider(
                                                              context);
                                                      walletProvider
                                                          .showLoading();
                                                      await RemoteServer
                                                          .setBackedUp();
                                                      walletProvider
                                                          .hideLoading();
                                                      user.seedPhraseBackedUp =
                                                          true;
                                                    },
                                                  );
                                                },
                                                localizeKey:
                                                    'youHaventBackedup',
                                              )
                                            : addHeight(SpacingSize.s),
                                        InkWell(
                                          onTap: onAccountChangeHandler,
                                          child: AvatarWidget(
                                            radius: 50,
                                            address:
                                                getLiveWalletProvider(context)
                                                    .activeWallet
                                                    .wallet
                                                    .privateKey
                                                    .address
                                                    .hex,
                                          ),
                                        ),
                                        addHeight(SpacingSize.xs),
                                        WalletText(
                                          '',
                                          localizeKey:
                                              getLiveWalletProvider(context)
                                                  .getAccountName(),
                                          textVarient: TextVarient.body1,
                                          bold: true,
                                        ),
                                        addHeight(SpacingSize.xs),
                                        WalletText('',
                                            onTap: onAddressTapHandler,
                                            textVarient: TextVarient.body1,
                                            localizeKey: showEllipse(
                                                getLiveWalletProvider(context)
                                                    .activeWallet
                                                    .wallet
                                                    .privateKey
                                                    .address
                                                    .hex)),
                                        addHeight(SpacingSize.xs),
                                        WalletText(
                                          '',
                                          localizeKey:
                                              getLiveWalletProvider(context)
                                                  .getNativeBalanceFormatted(),
                                          textVarient: TextVarient.heading,
                                        ),
                                        addHeight(SpacingSize.xs),
                                        WalletText(
                                          '',
                                          localizeKey: getLiveWalletProvider(
                                                  context)
                                              .getPreferedBalanceFormatted(),
                                          textVarient: TextVarient.heading,
                                        ),
                                        addHeight(SpacingSize.xs),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            addWidth(SpacingSize.s),
                                            addWidth(SpacingSize.s),
                                            CustomIconButton(
                                              onPressed: onReceiveHandler,
                                              localizeKey: 'receive',
                                              iconData: Icons.call_received,
                                            ),
                                            CustomIconButton(
                                              onPressed: onSendHandler,
                                              localizeKey: 'send',
                                              iconData: Icons.send,
                                            ),
                                            addWidth(SpacingSize.s),
                                            addWidth(SpacingSize.s),
                                          ],
                                        ),
                                        addHeight(SpacingSize.s),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                  BrowserScreen(index: index)
                  // BrowserScreen(
                  //   index: index,
                  // )
                ],
              ),
            )),
        getLiveWalletProvider(context).loading
            ? Container(
                height: Get.height,
                width: Get.width,
                color: Colors.black87.withAlpha(200),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
