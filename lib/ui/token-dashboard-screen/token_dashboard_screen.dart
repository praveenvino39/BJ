import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/collectible-bloc/cubit/collectible_cubit.dart';
import 'package:wallet/core/bloc/token-bloc/cubit/token_cubit.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/core/model/collectible_model.dart';
import 'package:wallet/core/model/token_model.dart';
import 'package:wallet/core/remote/http.dart';
import 'package:wallet/core/remote/response-model/erc20_transaction_log.dart';
import 'package:wallet/core/remote/response-model/transaction_log_result.dart';
import 'package:wallet/ui/block-web-view/block_web_view.dart';
import 'package:wallet/ui/home/component/account_change_sheet.dart';
import 'package:wallet/ui/home/component/avatar_component.dart';
import 'package:wallet/ui/home/component/receive_sheet.dart';
import 'package:wallet/ui/transaction-history/widget/token_transaction_tile.dart';
import 'package:wallet/ui/transaction-history/widget/transaction_tile.dart';
import 'package:wallet/ui/transfer/transfer_screen.dart';
import 'package:wallet/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      collectible = getCollectibleLoadedState(context).collectibles.firstWhere(
          (element) =>
              element.tokenAddress == widget.tokenAddress &&
              element.tokenId == widget.tokenId);
    } else {
      token = (context.read<TokenCubit>().state as TokenLoaded)
          .tokens
          .firstWhere((element) => element.tokenAddress == widget.tokenAddress);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WalletCubit, WalletState>(
          listener: (context, state) {
            // if (state is WalletAccountChanged) {
            //   context.read<TokenCubit>().loadToken(
            //       address: state.wallet.privateKey.address.hex,
            //       network: state.currentNetwork);
            // }
            // if (state is WalletNetworkChanged) {
            //   context.read<TokenCubit>().loadToken(
            //       address: state.wallet.privateKey.address.hex,
            //       network: state.currentNetwork);
            // }
          },
        ),
        BlocListener<TokenCubit, TokenState>(
          listener: (context, state) {
             if (state is TokenDeleted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Token deleted succesfully"),
                backgroundColor: Colors.green,
              ));
            }
            // if (state is WalletNetworkChanged) {
            //   context.read<TokenCubit>().loadToken(
            //       address: state.wallet.privateKey.address.hex,
            //       network: state.currentNetwork);
            // }
          },
        ),
        BlocListener<CollectibleCubit, CollectibleState>(
          listener: (context, state) {
            if (state is CollectibleDeleted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)!.nftDeleted),
                backgroundColor: Colors.green,
              ));
            }
            
          },
        ),
      ],
      child: BlocBuilder<WalletCubit, WalletState>(builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    if (widget.isCollectibles) {
                      getCollectibleCubit(context).deleteCollectibles(
                          collectible: collectible!,
                          address: getWalletLoadedState(context)
                              .wallet
                              .privateKey
                              .address
                              .hex,
                          network:
                              getWalletLoadedState(context).currentNetwork);
                    } else {
                      getTokenCubit(context).deleteToken(
                          token: token!,
                          address: getWalletLoadedState(context)
                              .wallet
                              .privateKey
                              .address
                              .hex,
                          network:
                              getWalletLoadedState(context).currentNetwork);
                    }
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: kPrimaryColor,
                  ))
            ],
            shadowColor: Colors.white,
            elevation: 0,
            backgroundColor: Colors.white,
            title: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(appName,
                      style: TextStyle(
                          fontWeight: FontWeight.w200, color: Colors.black)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: (state as WalletLoaded)
                                .currentNetwork
                                .dotColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        state.currentNetwork.networkName,
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
                    widget.tokenAddress != ""
                        ? Expanded(
                            child: FutureBuilder<List<ERC20Transfer>?>(
                              future: getERC20TransferLog(
                                  state.wallet.privateKey.address.hex,
                                  state.currentNetwork,
                                  widget.tokenAddress),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!.isNotEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: ListView.builder(
                                                    itemCount:
                                                        snapshot.data?.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var date = DateTime
                                                          .fromMicrosecondsSinceEpoch(
                                                              int.parse(snapshot
                                                                      .data![
                                                                          index]
                                                                      .timeStamp) *
                                                                  1000000);
                                                      return TokenTransferTile(
                                                          date: date,
                                                          data: snapshot
                                                              .data![index]);
                                                    }),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            BlockWebView.router,
                                                            arguments: {
                                                          "title": state
                                                              .currentNetwork
                                                              .networkName,
                                                          "url": viewAddressOnEtherScan(
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
                                              )
                                            ],
                                          ),
                                        )
                                      :  Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.youHaveNoTransaction,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
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
                          )
                        : Expanded(
                            child: FutureBuilder<List<TransactionResult>?>(
                              future: getTransactionLog(
                                state.wallet.privateKey.address.hex,
                                state.currentNetwork,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!.isNotEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: ListView.builder(
                                                    itemCount:
                                                        snapshot.data?.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var date = DateTime
                                                          .fromMicrosecondsSinceEpoch(
                                                              int.parse(snapshot
                                                                      .data![
                                                                          index]
                                                                      .timeStamp) *
                                                                  1000000);
                                                      return TransactionTile(
                                                          date: date,
                                                          data: snapshot
                                                              .data![index]);
                                                    }),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            BlockWebView.router,
                                                            arguments: {
                                                          "title": state
                                                              .currentNetwork
                                                              .networkName,
                                                          "url": viewAddressOnEtherScan(
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
                                              )
                                            ],
                                          ),
                                        )
                                      : const Center(
                                          child: Text(
                                            "You have no transactions!",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
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
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        const AccountChangeSheet());
                              },
                              child: AvatarWidget(
                                imageUrl: widget.isCollectibles
                                    ? collectible!.imageUrl!.contains("http")
                                        ? collectible!.imageUrl!
                                        : "https://ipfs.io/ipfs/${collectible?.imageUrl}"
                                    : token?.imageUrl,
                                radius: 50,
                                address: widget.tokenAddress,
                                iconType: "identicon",
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.isCollectibles
                                  ? "${collectible?.name} #${widget.tokenId}"
                                  : "${token?.balance.toStringAsFixed(4)} ${token?.symbol}",
                              style: const TextStyle(fontSize: 25),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
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
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) => ReceiveSheet(
                                              address: state.wallet.privateKey
                                                  .address.hex,
                                            ),
                                          );
                                        },
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
                                      style:const TextStyle(fontSize: 12),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
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
      }),
    );
  }
}
