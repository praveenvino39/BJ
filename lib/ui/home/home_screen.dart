import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/web3wallet_service.dart';
import 'package:wallet_cryptomask/ui/atoms/custom_icon_button.dart';
import 'package:wallet_cryptomask/ui/browser/browser_screen.dart';
import 'package:wallet_cryptomask/ui/collectibles/collectibles_tab.dart';
import 'package:wallet_cryptomask/ui/home/component/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/login-screen/login_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/swap_screen/swap_screen.dart';
import 'package:wallet_cryptomask/ui/token-dashboard-screen/token_dashboard_screen.dart';
import 'package:wallet_cryptomask/ui/token/token_tab.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet_cryptomask/ui/home/component/drawer_component.dart';
import 'package:wallet_cryptomask/ui/home/component/receive_sheet.dart';
import 'package:wallet_cryptomask/ui/transfer/transfer_screen.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';
import 'component/avatar_component.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    setupWalletConnect();
    // const FlutterSecureStorage().read(key: 'password').then((password) {
    //   if (context.read<WalletCubit>().state is! WalletLoaded) {
    //     context.read<WalletCubit>().initialize(
    //       password ?? "",
    //       onError: (p0) {
    //         ScaffoldMessenger.of(context)
    //             .showSnackBar(SnackBar(content: Text(p0)));
    //       },
    //     );
    //   }
    //   // if (context.read<WalletCubit>().state is WalletUnlocked ||
    //   //     context.read<WalletCubit>().state is WalletSendTransactionSuccess ||
    //   //     context.read<WalletCubit>().state is WalletLoaded) {
    //   //   context
    //   //       .read<WalletCubit>()
    //   //       .getCurrenctCurrency()
    //   //       .then((value) => currency = value);
    //   //   updateBalanceTimer();
    //   //   updateFiatBalanceTimer();
    //   //   setState(() {
    //   //     accountName = getAccountName(getWalletLoadedState(context));
    //   //   });
    //   //   setupWalletConnect();
    //   // }
    // });
    super.initState();
  }

  setupWalletConnect() async {
    WC2Service web3service = WC2Service(
        address: walletProvider.activeWallet.wallet.privateKey.address.hex,
        chainId: walletProvider.activeNetwork.chainId.toString(),
        nameSpace: walletProvider.activeNetwork.nameSpace,
        preference: walletProvider.userPreference,
        privateKey: walletProvider.activeWallet.wallet.privateKey,
        networks: Core.networks);
    GetIt.I.registerSingleton<WC2Service>(web3service);
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
          symbol: getWalletLoadedState(context).currentNetwork.symbol,
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

  // updateBalance(WalletLoaded state, bool updateFiat) async {
  //   try {
  //     EtherAmount balance =
  //         await state.web3client.getBalance(state.wallet.privateKey.address);
  //     state.balanceInNative = balance.getValueInUnit(EtherUnit.ether);
  //     if (updateFiat) {
  //       updateFiatBalance(state.balanceInNative);
  //     }
  //     setState(() {
  //       balaneInNative = state.balanceInNative;
  //     });
  //     log(state.balanceInNative.toString());
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

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

  // updateBalanceTimer() {
  //   context
  //       .read<TokenCubit>()
  //       .setupWeb3Client(getWalletLoadedState(context).web3client);
  //   context
  //       .read<CollectibleCubit>()
  //       .setupWeb3Client(getWalletLoadedState(context).web3client);
  //   context.read<TokenCubit>().loadToken(
  //       address: getWalletLoadedState(context).wallet.privateKey.address.hex,
  //       network: getWalletLoadedState(context).currentNetwork);
  //   context.read<CollectibleCubit>().loadCollectible(
  //       address: getWalletLoadedState(context).wallet.privateKey.address.hex,
  //       network: getWalletLoadedState(context).currentNetwork);
  //   updateBalance(getWalletLoadedState(context), true);
  //   if (timer != null) {
  //     timer?.cancel();
  //   }
  //   timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
  //     updateBalance(getWalletLoadedState(context), false);
  //     context
  //         .read<TokenCubit>()
  //         .setupWeb3Client(getWalletLoadedState(context).web3client);
  //     context
  //         .read<CollectibleCubit>()
  //         .setupWeb3Client(getWalletLoadedState(context).web3client);
  //     context.read<TokenCubit>().loadToken(
  //         address: getWalletLoadedState(context).wallet.privateKey.address.hex,
  //         network: getWalletLoadedState(context).currentNetwork);
  //     context.read<CollectibleCubit>().loadCollectible(
  //         address: getWalletLoadedState(context).wallet.privateKey.address.hex,
  //         network: getWalletLoadedState(context).currentNetwork);
  //   });
  //   log("TIMER STARTED");
  // }

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
                                    child: Text(
                                      "Networks",
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
                                                  Text(Core.networks[index]
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
                          const Text(appName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  color: Colors.black)),
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
                              Text(
                                Provider.of<WalletProvider>(context)
                                    .activeNetwork
                                    .networkName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w100,
                                    fontSize: 12,
                                    color: Colors.black),
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
                                text: AppLocalizations.of(context)!.tokens,
                              ),
                              Tab(
                                text:
                                    AppLocalizations.of(context)!.collectibles,
                              )
                            ]),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: Colors.grey.withAlpha(60),
                        ),
                        // Expanded(
                        //   child:
                        //       TabBarView(controller: _tabController, children: [
                        //     SizedBox(),
                        //     SizedBox(),
                        //     // TokenTab(
                        //     //     web3client:
                        //     //         getWalletLoadedState(context).web3client,
                        //     //     onTokenPressed: (token) {
                        //     //       Navigator.of(context).pushNamed(
                        //     //           TokenDashboardScreen.route,
                        //     //           arguments: {"token": token.tokenAddress});
                        //     //     },
                        //     //     networkKey:
                        //     //         walletProvider.activeNetwork.networkName),
                        //     // CollectiblesTab(
                        //     //     networkName: getWalletLoadedState(context)
                        //     //         .currentNetwork
                        //     //         .networkName,
                        //     //     web3client:
                        //     //         getWalletLoadedState(context).web3client),
                        //   ]),
                        // ),
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
                                addHeight(SpacingSize.s)
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
    // return Scaffold(
    //   key: _fakeScafoldKey,
    //   body: BlocConsumer<WalletCubit, WalletState>(
    //     listener: (context, state) async {
    //       log(state.toString());
    //       // if (state is WalletLoaded || state is WalletUnlocked) {
    //       //   context
    //       //       .read<WalletCubit>()
    //       //       .getCurrenctCurrency()
    //       //       .then((value) => currency = value);
    //       //   updateBalanceTimer();
    //       //   updateFiatBalanceTimer();
    //       //   setState(() {
    //       //     accountName =
    //       //         (context.read<PreferenceCubit>().state as PreferenceInitial)
    //       //             .userPreference
    //       //             .get(getWalletLoadedState(context)
    //       //                 .wallet
    //       //                 .privateKey
    //       //                 .address
    //       //                 .hex);
    //       //   });
    //       //   setupWalletConnect();
    //       // }
    //       if (state is WalletLogout) {
    //         Navigator.popUntil(context, (route) => false);
    //         Navigator.push(context,
    //             MaterialPageRoute(builder: ((context) => const LoginScreen())));
    //       }
    //       if (state is WalletAccountChanged) {
    //         log("WALLET ACCOUNT CHANGED");
    //       }
    //     },
    //     builder: (context, state) {
    //       if (state is WalletLoaded) {
    //         return Scaffold(
    //           key: _scafoldKey,
    //           drawer: DrawerComponent(
    //             address: state.wallet.privateKey.address.hex,
    //             balanceInUSD: state.balanceInUSD,
    //           ),
    //           bottomNavigationBar: BottomNavigationBar(
    //             currentIndex: index,
    //             onTap: (value) async {
    //               setState(() {
    //                 index = value;
    //               });
    //             },
    //             selectedItemColor: kPrimaryColor,
    //             unselectedItemColor: Colors.grey,
    //             selectedFontSize: 12,
    //             unselectedFontSize: 12,
    //             items: const [
    //               BottomNavigationBarItem(
    //                 icon: Icon(Icons.wallet),
    //                 label: "Wallet",
    //               ),
    //               BottomNavigationBarItem(
    //                   icon: Icon(Icons.public), label: "Dapp Browser"),
    //             ],
    //           ),
    //           backgroundColor: Colors.white,
    //           appBar: index == 0
    //               ? AppBar(
    //                   shadowColor: Colors.white,
    //                   elevation: 0,
    //                   backgroundColor: Colors.white,
    //                   title: SizedBox(
    //                     width: double.infinity,
    //                     child: InkWell(
    //                       onTap: () {
    //                         showDialog(
    //                           context: context,
    //                           builder: (context) => SizedBox(
    //                             height: 10,
    //                             child: AlertDialog(
    //                               title: Row(
    //                                 children: [
    //                                   const Expanded(
    //                                     child: Text(
    //                                       "Networks",
    //                                     ),
    //                                   ),
    //                                   InkWell(
    //                                       onTap: () {
    //                                         Navigator.of(context).pop();
    //                                       },
    //                                       child: const Icon(Icons.close))
    //                                 ],
    //                               ),
    //                               titlePadding: const EdgeInsets.symmetric(
    //                                   horizontal: 10, vertical: 7),
    //                               contentPadding: const EdgeInsets.all(0),
    //                               content: Container(
    //                                 width: MediaQuery.of(context).size.width,
    //                                 color: Colors.black45.withAlpha(20),
    //                                 child: SizedBox(
    //                                     child: ListView.builder(
    //                                         scrollDirection: Axis.vertical,
    //                                         shrinkWrap: true,
    //                                         itemCount: Core.networks.length,
    //                                         itemBuilder: (context, index) =>
    //                                             ListTile(
    //                                               tileColor: Colors.transparent,
    //                                               onTap: () async {
    //                                                 await context
    //                                                     .read<WalletCubit>()
    //                                                     .changeNetwork(Core
    //                                                         .networks[index]);
    //                                                 // ignore: use_build_context_synchronously
    //                                                 Navigator.of(context).pop();
    //                                               },
    //                                               title: Row(
    //                                                 children: [
    //                                                   Container(
    //                                                     width: 7,
    //                                                     height: 7,
    //                                                     decoration: BoxDecoration(
    //                                                         color: Core
    //                                                             .networks[index]
    //                                                             .dotColor,
    //                                                         borderRadius:
    //                                                             BorderRadius
    //                                                                 .circular(
    //                                                                     10)),
    //                                                   ),
    //                                                   const SizedBox(
    //                                                     width: 10,
    //                                                   ),
    //                                                   Text(Core.networks[index]
    //                                                       .networkName),
    //                                                 ],
    //                                               ),
    //                                             ))),
    //                               ),
    //                             ),
    //                           ),
    //                         );
    //                       },
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           const Text(appName,
    //                               style: TextStyle(
    //                                   fontWeight: FontWeight.w200,
    //                                   color: Colors.black)),
    //                           Row(
    //                             mainAxisAlignment: MainAxisAlignment.center,
    //                             children: [
    //                               Container(
    //                                 width: 7,
    //                                 height: 7,
    //                                 decoration: BoxDecoration(
    //                                     color: state.currentNetwork.dotColor,
    //                                     borderRadius:
    //                                         BorderRadius.circular(10)),
    //                               ),
    //                               const SizedBox(
    //                                 width: 5,
    //                               ),
    //                               Text(
    //                                 state.currentNetwork.networkName,
    //                                 style: const TextStyle(
    //                                     fontWeight: FontWeight.w100,
    //                                     fontSize: 12,
    //                                     color: Colors.black),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   leading: IconButton(
    //                       onPressed: () {
    //                         _scafoldKey.currentState?.openDrawer();
    //                       },
    //                       icon: const Icon(
    //                         Icons.menu,
    //                         color: Colors.black,
    //                       )),
    //                   actions: [
    //                       IconButton(
    //                         onPressed: () {},
    //                         icon: const Icon(
    //                           Icons.add,
    //                           color: Colors.white,
    //                         ),
    //                       ),
    //                     ])
    //               : null,
    //           body: IndexedStack(
    //             index: index,
    //             children: [
    //               NestedScrollView(
    //                   body: SizedBox(
    //                     height: MediaQuery.of(context).size.height,
    //                     width: MediaQuery.of(context).size.width,
    //                     child: Column(
    //                       children: [
    //                         TabBar(
    //                             controller: _tabController,
    //                             labelColor: kPrimaryColor,
    //                             indicatorColor: kPrimaryColor,
    //                             labelStyle: GoogleFonts.poppins(),
    //                             unselectedLabelColor: Colors.black,
    //                             tabs: [
    //                               Tab(
    //                                 text: AppLocalizations.of(context)!.tokens,
    //                               ),
    //                               Tab(
    //                                 text: AppLocalizations.of(context)!
    //                                     .collectibles,
    //                               )
    //                             ]),
    //                         Container(
    //                           width: MediaQuery.of(context).size.width,
    //                           height: 1,
    //                           color: Colors.grey.withAlpha(60),
    //                         ),
    //                         Expanded(
    //                           child: TabBarView(
    //                               controller: _tabController,
    //                               children: [
    //                                 TokenTab(
    //                                     web3client:
    //                                         getWalletLoadedState(context)
    //                                             .web3client,
    //                                     onTokenPressed: (token) {
    //                                       Navigator.of(context).pushNamed(
    //                                           TokenDashboardScreen.route,
    //                                           arguments: {
    //                                             "token": token.tokenAddress
    //                                           });
    //                                     },
    //                                     networkKey:
    //                                         state.currentNetwork.networkName),
    //                                 CollectiblesTab(
    //                                     networkName:
    //                                         getWalletLoadedState(context)
    //                                             .currentNetwork
    //                                             .networkName,
    //                                     web3client:
    //                                         getWalletLoadedState(context)
    //                                             .web3client),
    //                               ]),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   headerSliverBuilder: (context, _) => [
    //                         SliverToBoxAdapter(
    //                           child: SizedBox(
    //                             width: MediaQuery.of(context).size.width,
    //                             child: Column(
    //                               children: [
    //                                 const SizedBox(
    //                                   height: 20,
    //                                 ),
    //                                 InkWell(
    //                                   onTap: () {
    //                                     showModalBottomSheet(
    //                                         context: context,
    //                                         builder: (context) =>
    //                                             const AccountChangeSheet());
    //                                   },
    //                                   child: AvatarWidget(
    //                                     radius: 50,
    //                                     address:
    //                                         state.wallet.privateKey.address.hex,
    //                                   ),
    //                                 ),
    //                                 const SizedBox(
    //                                   height: 10,
    //                                 ),
    //                                 switchEditName
    //                                     ? TextFormField(
    //                                         controller: nameEditingController,
    //                                         onEditingComplete: () {
    //                                           if (nameEditingController
    //                                               .text.isEmpty) {
    //                                             showErrorSnackBar(
    //                                                 context,
    //                                                 "Error",
    //                                                 "Account name shouldn't be empty");
    //                                           } else {
    //                                             context
    //                                                 .read<WalletCubit>()
    //                                                 .changeAccountName(
    //                                                     nameEditingController
    //                                                         .text);
    //                                             setState(() {
    //                                               accountName =
    //                                                   nameEditingController
    //                                                       .text;
    //                                               switchEditName = false;
    //                                             });
    //                                           }
    //                                         },
    //                                         cursorColor: kPrimaryColor,
    //                                         decoration:
    //                                             const InputDecoration.collapsed(
    //                                                 hintText: 'Account name'),
    //                                         style: const TextStyle(
    //                                             fontSize: 18,
    //                                             fontWeight: FontWeight.w600),
    //                                         textAlign: TextAlign.center,
    //                                       )
    //                                     : InkWell(
    //                                         onLongPress: () {
    //                                           nameEditingController.text =
    //                                               accountName;
    //                                           setState(() {
    //                                             switchEditName = true;
    //                                           });
    //                                         },
    //                                         child: Text(
    //                                           accountName,
    //                                           style: const TextStyle(
    //                                               fontSize: 18,
    //                                               fontWeight: FontWeight.w600),
    //                                         ),
    //                                       ),
    //                                 const SizedBox(
    //                                   height: 5,
    //                                 ),
    //                                 Container(
    //                                     decoration: BoxDecoration(
    //                                         color: kPrimaryColor.withAlpha(80),
    //                                         borderRadius:
    //                                             BorderRadius.circular(20)),
    //                                     padding: const EdgeInsets.symmetric(
    //                                         horizontal: 10, vertical: 0),
    //                                     child: InkWell(
    //                                       onTap: () => copyAddressToClipBoard(
    //                                           state.wallet.privateKey.address
    //                                               .hex,
    //                                           context),
    //                                       child: Text(showEllipse(state
    //                                           .wallet.privateKey.address
    //                                           .toString())),
    //                                     )),
    //                                 const SizedBox(
    //                                   height: 3,
    //                                 ),
    //                                 Text(
    //                                     "${state.balanceInNative.toStringAsFixed(18).split(".")[0]}.${state.balanceInNative.toStringAsFixed(18).split(".")[1].substring(0, 4)} ${state.currentNetwork.symbol}"),
    //                                 const SizedBox(
    //                                   height: 8,
    //                                 ),
    //                                 Text(
    //                                     "$balanceInUSD ${state.currency.toUpperCase()}"),
    //                                 const SizedBox(
    //                                   height: 8,
    //                                 ),
    //                                 const SizedBox(
    //                                   height: 7,
    //                                 ),
    //                                 Row(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.center,
    //                                   children: [
    //                                     Column(
    //                                       children: [
    //                                         Container(
    //                                           clipBehavior: Clip.hardEdge,
    //                                           decoration: const BoxDecoration(
    //                                             shape: BoxShape.circle,
    //                                             color: kPrimaryColor,
    //                                           ),
    //                                           child: IconButton(
    //                                             onPressed: () {
    //                                               showModalBottomSheet(
    //                                                   backgroundColor:
    //                                                       Colors.transparent,
    //                                                   context: context,
    //                                                   builder: (context) {
    //                                                     return ReceiveSheet(
    //                                                       address: state
    //                                                           .wallet
    //                                                           .privateKey
    //                                                           .address
    //                                                           .hex,
    //                                                     );
    //                                                   });
    //                                             },
    //                                             icon: const Icon(
    //                                               Icons.download,
    //                                               size: 24,
    //                                               color: Colors.white,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                         Text(
    //                                           AppLocalizations.of(context)!
    //                                               .receive,
    //                                           style:
    //                                               const TextStyle(fontSize: 12),
    //                                         )
    //                                       ],
    //                                     ),
    //                                     const SizedBox(
    //                                       width: 15,
    //                                     ),
    //                                     Column(
    //                                       children: [
    //                                         Container(
    //                                           clipBehavior: Clip.hardEdge,
    //                                           decoration: const BoxDecoration(
    //                                             shape: BoxShape.circle,
    //                                             color: kPrimaryColor,
    //                                           ),
    //                                           child: IconButton(
    //                                             onPressed: () => Navigator.of(
    //                                                     context)
    //                                                 .pushNamed(
    //                                                     TransferScreen.route,
    //                                                     arguments: {
    //                                                   "balance": balaneInNative
    //                                                       .toString(),
    //                                                   "token": Token(
    //                                                       tokenAddress: "",
    //                                                       symbol:
    //                                                           getWalletLoadedState(
    //                                                                   context)
    //                                                               .currentNetwork
    //                                                               .symbol,
    //                                                       decimal: 18,
    //                                                       balance: 0,
    //                                                       balanceInFiat: 0)
    //                                                 }),
    //                                             icon: const Icon(
    //                                               Icons.call_made,
    //                                               size: 24,
    //                                               color: Colors.white,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                         Text(
    //                                           AppLocalizations.of(context)!
    //                                               .send,
    //                                           style:
    //                                               const TextStyle(fontSize: 12),
    //                                         )
    //                                       ],
    //                                     ),
    //                                     const SizedBox(
    //                                       width: 15,
    //                                     ),
    //                                     Column(
    //                                       children: [
    //                                         Container(
    //                                           clipBehavior: Clip.hardEdge,
    //                                           decoration: const BoxDecoration(
    //                                             shape: BoxShape.circle,
    //                                             color: kPrimaryColor,
    //                                           ),
    //                                           child: IconButton(
    //                                             onPressed: () {
    //                                               Navigator.of(context)
    //                                                   .pushNamed(
    //                                                       SwapScreen.route);
    //                                             },
    //                                             icon: const Icon(
    //                                               Icons.swap_horiz,
    //                                               size: 24,
    //                                               color: Colors.white,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                         Text(
    //                                           AppLocalizations.of(context)!
    //                                               .swap,
    //                                           style:
    //                                               const TextStyle(fontSize: 12),
    //                                         )
    //                                       ],
    //                                     )
    //                                   ],
    //                                 ),
    //                                 const SizedBox(
    //                                   height: 10,
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                         ),
    //                       ]),
    //               BrowserScreen(index: index)
    //             ],
    //           ),
    //         );
    //       } else {
    //         return const Scaffold(
    //           body: Center(
    //             child: CircularProgressIndicator(),
    //           ),
    //         );
    //       }
    //     },
    //   ),
    // );
  }

  @override
  void dispose() {
    timer?.cancel();
    fiatTimer?.cancel();
    super.dispose();
  }
}
