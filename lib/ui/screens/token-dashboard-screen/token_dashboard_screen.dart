import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_token_transfer.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_transaction_response.dart';
import 'package:wallet_cryptomask/ui/screens/block-web-view-screen/block_web_view.dart';
import 'package:wallet_cryptomask/ui/screens/home-screen/widgets/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/shared/avatar_widget.dart';
import 'package:wallet_cryptomask/ui/screens/home-screen/widgets/receive_sheet.dart';
import 'package:wallet_cryptomask/ui/screens/transaction-history-screen/widget/token_transaction_tile.dart';
import 'package:wallet_cryptomask/ui/screens/transaction-history-screen/widget/transaction_tile.dart';
import 'package:wallet_cryptomask/ui/screens/transfer-screen/transfer_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class TokenDashboardScreen extends StatefulWidget {
  static const route = "token_dashboard_screen";

  final String tokenAddress;
  final String? tokenId;
  final bool? isNative;
  const TokenDashboardScreen(
      {Key? key, required this.tokenAddress, this.tokenId, this.isNative})
      : super(key: key);

  @override
  State<TokenDashboardScreen> createState() => _TokenDashboardScreenState();
}

class _TokenDashboardScreenState extends State<TokenDashboardScreen> {
  Token? token;
  Collectible? collectible;
  @override
  void initState() {
    token = Provider.of<TokenProvider>(context, listen: false)
        .tokens
        .firstWhere((element) => element.tokenAddress == widget.tokenAddress);

    super.initState();
  }

  onReceiveClick() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReceiveSheet(
        address: Provider.of<WalletProvider>(context)
            .activeWallet
            .wallet
            .privateKey
            .address
            .hex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.white,
        title: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(appName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w200, color: Colors.black)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  addWidth(SpacingSize.xs),
                ],
              ),
            ],
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: kPrimaryColor,
            )),
      ),
      body: NestedScrollView(
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                if (widget.tokenAddress.isNotEmpty)
                  Expanded(
                    child: FutureBuilder<List<TokenTransfer>?>(
                      future: getTokenProvider(context).getTokenTransfer(
                          address: getWalletProvider(context)
                              .activeWallet
                              .wallet
                              .privateKey
                              .address
                              .hex,
                          network: getWalletProvider(context).activeNetwork,
                          tokenAddress: token!.tokenAddress),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            itemCount: snapshot.data?.length,
                                            itemBuilder: (context, index) {
                                              return TokenTransactionTile(
                                                  date: snapshot.data![index]
                                                      .blockTimestamp,
                                                  data: snapshot.data![index]);
                                            }),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SafeArea(
                                          child: InkWell(
                                            onTap: () {
                                              final walletProvider =
                                                  getWalletProvider(context);
                                              context.push(
                                                () => BlockWebView(
                                                    title: walletProvider
                                                        .activeNetwork
                                                        .networkName,
                                                    url: viewAddressOnEtherScan(
                                                        walletProvider
                                                            .activeNetwork,
                                                        walletProvider
                                                            .activeWallet
                                                            .wallet
                                                            .privateKey
                                                            .address
                                                            .hex)),
                                              );
                                            },
                                            child: const WalletText(
                                                localizeKey: 'viewFullHistory',
                                                color: kPrimaryColor),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: WalletText(
                                      localizeKey: 'noTransaction',
                                      size: 18,
                                      color: Colors.grey),
                                );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                if (widget.tokenAddress.isEmpty)
                  Expanded(
                    child: FutureBuilder<List<MoralisTransaction>?>(
                      future: getTokenProvider(context).getTransactions(
                          address: getWalletProvider(context)
                              .activeWallet
                              .wallet
                              .privateKey
                              .address
                              .hex,
                          network: getWalletProvider(context).activeNetwork),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            itemCount: snapshot.data?.length,
                                            itemBuilder: (context, index) {
                                              // Define the format of the input date string
                                              DateFormat dateFormat = DateFormat(
                                                  "EEE MMM dd yyyy HH:mm:ss 'GMT'Z");

                                              // Parse the date string to DateTime
                                              DateTime date = dateFormat.parse(
                                                  snapshot.data![index]
                                                      .blockTimestamp
                                                      .replaceAll(
                                                          RegExp(r' \([^)]*\)'),
                                                          ''),
                                                  true);
                                              return TransactionTile(
                                                  date: date,
                                                  data: snapshot.data![index]);
                                            }),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SafeArea(
                                          child: InkWell(
                                            onTap: () {
                                              final walletProvider =
                                                  getWalletProvider(context);
                                              context.push(
                                                () => BlockWebView(
                                                    title: walletProvider
                                                        .activeNetwork
                                                        .networkName,
                                                    url: viewAddressOnEtherScan(
                                                        walletProvider
                                                            .activeNetwork,
                                                        walletProvider
                                                            .activeWallet
                                                            .wallet
                                                            .privateKey
                                                            .address
                                                            .hex)),
                                              );
                                            },
                                            child: const WalletText(
                                                localizeKey: 'viewFullHistory',
                                                color: kPrimaryColor),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: WalletText(
                                      localizeKey: 'noTransaction',
                                      size: 18,
                                      color: Colors.grey),
                                );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          );
                        }
                      },
                    ),
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
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    const AccountChangeSheet());
                          },
                          child: AvatarWidget(
                            imageUrl: token?.imageUrl,
                            radius: 50,
                            address: widget.tokenAddress,
                            iconType: "identicon",
                          ),
                        ),
                        addHeight(SpacingSize.xs),
                        Text(
                          "${token?.balance.toStringAsFixed(6)} ${token?.symbol}",
                          style: const TextStyle(fontSize: 25),
                        ),
                        addHeight(SpacingSize.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kPrimaryColor,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                    ),
                                    onPressed: onReceiveClick,
                                  ),
                                ),
                                const WalletText(
                                    localizeKey: 'receive', size: 12)
                              ],
                            ),
                            addWidth(SpacingSize.l),
                            Column(
                              children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kPrimaryColor,
                                  ),
                                  child: IconButton(
                                    onPressed: () => {
                                      context.push(() => TransferScreen(
                                            balance: "0",
                                            token: token,
                                          ))
                                    },
                                    icon: const Icon(
                                      Icons.call_made,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const WalletText(localizeKey: 'send', size: 12)
                              ],
                            ),
                          ],
                        ),
                        addHeight(SpacingSize.s),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: Colors.grey.withAlpha(60),
                        )
                      ],
                    ),
                  ),
                ),
              ]),
    );
  }
}
