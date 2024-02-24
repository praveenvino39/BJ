import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/web3wallet_service.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/atoms/custom_icon_button.dart';
import 'package:wallet_cryptomask/ui/collectibles/collectibles_tab.dart';
import 'package:wallet_cryptomask/ui/home/component/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/home/component/drawer_component.dart';
import 'package:wallet_cryptomask/ui/home/component/receive_sheet.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/swap_screen/swap_screen.dart';
import 'package:wallet_cryptomask/ui/token/token_tab.dart';
import 'package:wallet_cryptomask/ui/transfer/transfer_screen.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';
import 'package:web3dart/web3dart.dart';

import 'component/avatar_component.dart';

class HomeScreen extends StatefulWidget {
  static String route = "home_screen";

  // final String password;
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController nameEditingController = TextEditingController();
  String address = "null";
  String balanceInUSD = "0";
  double balaneInNative = 0.0;
  bool switchEditName = false;
  String accountName = "";
  String currency = "";
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  final GlobalKey<ScaffoldState> _fakeScafoldKey = GlobalKey();
  int index = 0;
  Timer? timer;
  Timer? fiatTimer;
  late WalletProvider walletProvider;

  @override
  void initState() {
    walletProvider = context.read<WalletProvider>();
    _tabController = TabController(length: 3, vsync: this);
    setupWalletConnect();
    updateBalanceTimer();
    super.initState();
  }

  setupWalletConnect() async {
    if (GetIt.I.isRegistered<WC2Service>(instance: walletConnectSingleTon)) {
      await GetIt.I
          .unregister<WC2Service>(instanceName: walletConnectSingleTon);
    }
    WC2Service web3service = WC2Service(
        address: walletProvider.activeWallet.wallet.privateKey.address.hex,
        chainId: walletProvider.activeNetwork.chainId.toString(),
        nameSpace: walletProvider.activeNetwork.nameSpace,
        preference: walletProvider.userPreference,
        privateKey: walletProvider.activeWallet.wallet.privateKey,
        networks: Core.networks);
    GetIt.I.registerSingleton<WC2Service>(web3service,
        instanceName: walletConnectSingleTon);
    web3service.create();
    await web3service.init();
  }

  onAddressTapHandler() {
    walletProvider.copyPublicAddress().then((value) {
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
            address: walletProvider.activeWallet.wallet.privateKey.address.hex,
          );
        });
  }

  onSendHandler() {
    Navigator.of(context).pushNamed(TransferScreen.route, arguments: {
      "balance": balaneInNative.toString(),
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

  onSwapHandler() {
    Navigator.of(context).pushNamed(SwapScreen.route);
  }

  onAccountChangeHandler() {
    showModalBottomSheet(
        context: context, builder: (context) => const AccountChangeSheet());
  }

  updateBalance() {
    try {
      Provider.of<WalletProvider>(context, listen: false)
          .web3client
          .getBalance(Provider.of<WalletProvider>(context, listen: false)
              .activeWallet
              .wallet
              .privateKey
              .address)
          .then((balance) {
        Provider.of<WalletProvider>(context, listen: false)
            .changeNativeBalance(balance.getValueInUnit(EtherUnit.ether));
      });
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
  }

  // updateFiatBalance(double? balance) async {
  //   dynamic priceModel =
  //       await getPrice(getWalletLoadedState(context).currentNetwork.priceId);
  //   if (priceModel != null) {
  //     setState(() {
  //       balanceInUSD = (priceModel["currentPrice"] *
  //               (balance ?? getWalletLoadedState(context).balanceInNative))
  //           .toString();
  //     });
  //   }
  // }

  // showTransactionAlert() {}

  updateBalanceTimer() {
    updateBalance();
    if (timer != null) {
      timer?.cancel();
    }
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      updateBalance();
    });
  }

  // updateFiatBalanceTimer() {
  //   updateFiatBalance(null);
  //   if (fiatTimer != null) {
  //     fiatTimer?.cancel();
  //   }
  //   fiatTimer = Timer.periodic(const Duration(seconds: 20), (timer) async {
  //     updateFiatBalance(null);
  //   });
  //   log("TIMER STARTED");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                                walletProvider
                                                    .changeNetwork(index);
                                                // await context
                                                //     .read<WalletCubit>()
                                                //     .changeNetwork(
                                                //         Core.networks[index]);
                                                // ignore: use_build_context_synchronously
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
                                                                .circular(10)),
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
                                    color:
                                        walletProvider.activeNetwork.dotColor,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              WalletText(
                                '',
                                localizeKey:
                                    Provider.of<WalletProvider>(context)
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
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ])
              : null,
          body: IndexedStack(
            index: index,
            children: [
              NestedScrollView(
                  body: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        TabBar(
                            controller: _tabController,
                            labelColor: kPrimaryColor,
                            indicatorColor: kPrimaryColor,
                            labelStyle: GoogleFonts.poppins(),
                            unselectedLabelColor: Colors.black,
                            tabs: [
                              Tab(
                                text: getText(context, key: 'Updates'),
                              ),
                              Tab(
                                text: getText(context, key: 'tokens'),
                              ),
                              Tab(
                                text: getText(context, key: 'collectibles'),
                              )
                            ]),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: Colors.grey.withAlpha(60),
                        ),
                        Expanded(
                          child: TabBarView(
                              controller: _tabController,
                              children: const [
                                TokenTab(),
                                TokenTab(),
                                CollectiblesTab(),
                              ]),
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
                                addHeight(SpacingSize.s),
                                InkWell(
                                  onTap: onAccountChangeHandler,
                                  child: AvatarWidget(
                                    radius: 50,
                                    address: walletProvider.activeWallet.wallet
                                        .privateKey.address.hex,
                                  ),
                                ),
                                addHeight(SpacingSize.xs),
                                WalletText(
                                  '',
                                  localizeKey: walletProvider.getAccountName(),
                                  textVarient: TextVarient.body1,
                                  bold: true,
                                ),
                                addHeight(SpacingSize.xs),
                                WalletText('',
                                    onTap: onAddressTapHandler,
                                    textVarient: TextVarient.body1,
                                    localizeKey: showEllipse(walletProvider
                                        .activeWallet
                                        .wallet
                                        .privateKey
                                        .address
                                        .hex)),
                                addHeight(SpacingSize.xs),
                                WalletText(
                                  '',
                                  localizeKey: walletProvider
                                      .getNativeBalanceFormatted(),
                                  textVarient: TextVarient.heading,
                                ),
                                addHeight(SpacingSize.xs),
                                WalletText(
                                  '',
                                  localizeKey: walletProvider
                                      .getPreferedBalanceFormatted(),
                                  textVarient: TextVarient.heading,
                                ),
                                addHeight(SpacingSize.xs),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconButton(
                                      onPressed: onReceiveHandler,
                                      localizeKey: 'receive',
                                      iconData: Icons.call_received,
                                    ),
                                    addWidth(SpacingSize.s),
                                    CustomIconButton(
                                      onPressed: onSendHandler,
                                      localizeKey: 'send',
                                      iconData: Icons.send,
                                    ),
                                    addWidth(SpacingSize.s),
                                    CustomIconButton(
                                        iconData: Icons.call_made,
                                        onPressed: onSwapHandler,
                                        localizeKey: 'swap')
                                  ],
                                ),
                                addHeight(SpacingSize.s),
                              ],
                            ),
                          ),
                        ),
                      ]),
              // BrowserScreen(index: index)
              const SizedBox()
            ],
          ),
        ));
  }

  @override
  void dispose() {
    timer?.cancel();
    fiatTimer?.cancel();
    super.dispose();
  }
}
