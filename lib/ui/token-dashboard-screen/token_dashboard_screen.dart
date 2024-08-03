import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/collectible_provider/collectible_provider.dart';
import 'package:wallet_cryptomask/core/bloc/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_token_transfer.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_transaction_response.dart';
import 'package:wallet_cryptomask/ui/block-web-view/block_web_view.dart';
import 'package:wallet_cryptomask/ui/home/component/account_change_sheet.dart';
import 'package:wallet_cryptomask/ui/home/component/avatar_component.dart';
import 'package:wallet_cryptomask/ui/home/component/receive_sheet.dart';
import 'package:wallet_cryptomask/ui/transaction-history/widget/token_transaction_tile.dart';
import 'package:wallet_cryptomask/ui/transaction-history/widget/transaction_tile.dart';
import 'package:wallet_cryptomask/ui/transfer/transfer_screen.dart';
import 'package:wallet_cryptomask/utils.dart';
import 'package:wallet_cryptomask/utils/spaces.dart';

class TokenDashboardScreen extends StatefulWidget {
  static const route = "token_dashboard_screen";

  final String tokenAddress;
  final bool isCollectibles;
  final String? tokenId;
  final bool? isNative;
  const TokenDashboardScreen(
      {Key? key,
      required this.tokenAddress,
      this.isCollectibles = false,
      this.tokenId,
      this.isNative})
      : super(key: key);

  @override
  State<TokenDashboardScreen> createState() => _TokenDashboardScreenState();
}

class _TokenDashboardScreenState extends State<TokenDashboardScreen> {
  Token? token;
  Collectible? collectible;
  @override
  void initState() {
    if (widget.isCollectibles) {
      collectible = Provider.of<CollectibleProvider>(context, listen: false)
          .collectibles
          .firstWhere((element) =>
              element.tokenAddress == widget.tokenAddress &&
              element.tokenId == widget.tokenId);
    } else {
      token = Provider.of<TokenProvider>(context, listen: false)
          .tokens
          .firstWhere((element) => element.tokenAddress == widget.tokenAddress);
    }

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
        title: const SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(appName,
                  style: TextStyle(
                      fontWeight: FontWeight.w200, color: Colors.black)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 5,
                  ),
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
                                              final state =
                                                  getWalletLoadedState(context);
                                              Navigator.of(context).pushNamed(
                                                  BlockWebView.router,
                                                  arguments: {
                                                    "title": state
                                                        .currentNetwork
                                                        .networkName,
                                                    "url":
                                                        viewAddressOnEtherScan(
                                                            state
                                                                .currentNetwork,
                                                            state
                                                                .wallet
                                                                .privateKey
                                                                .address
                                                                .hex)
                                                  });
                                            },
                                            child: const Text(
                                              "View full history on Explorer",
                                              style: TextStyle(
                                                  color: kPrimaryColor),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    "You have no transactions!",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
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
                                              final state =
                                                  getWalletLoadedState(context);
                                              Navigator.of(context).pushNamed(
                                                  BlockWebView.router,
                                                  arguments: {
                                                    "title": state
                                                        .currentNetwork
                                                        .networkName,
                                                    "url":
                                                        viewAddressOnEtherScan(
                                                            state
                                                                .currentNetwork,
                                                            state
                                                                .wallet
                                                                .privateKey
                                                                .address
                                                                .hex)
                                                  });
                                            },
                                            child: const Text(
                                              "View full history on Explorer",
                                              style: TextStyle(
                                                  color: kPrimaryColor),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    "You have no transactions!",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
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
                            imageUrl: widget.isCollectibles
                                ? collectible!.imageUrl?.contains("http") !=
                                        null
                                    ? collectible!.imageUrl!
                                    : "https://ipfs.io/ipfs/${collectible?.imageUrl}"
                                : token?.imageUrl,
                            radius: 50,
                            address: widget.tokenAddress,
                            iconType: "identicon",
                          ),
                        ),
                        addHeight(SpacingSize.xs),
                        Text(
                          widget.isCollectibles
                              ? "${collectible?.name} #${widget.tokenId}"
                              : "${token?.balance.toStringAsFixed(5)} ${token?.symbol}",
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
                                Text(
                                  AppLocalizations.of(context)!.receive,
                                  style: const TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 25,
                            ),
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
                                      if (widget.isCollectibles)
                                        {
                                          Navigator.of(context).pushNamed(
                                              TransferScreen.route,
                                              arguments: {
                                                "balance": "0",
                                                "token": token,
                                                "collectible": collectible
                                              })
                                        }
                                      else
                                        {
                                          Navigator.of(context).pushNamed(
                                              TransferScreen.route,
                                              arguments: {
                                                "balance": "0",
                                                "token": token
                                              })
                                        }
                                    },
                                    icon: const Icon(
                                      Icons.call_made,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.send,
                                  style: const TextStyle(fontSize: 12),
                                )
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
