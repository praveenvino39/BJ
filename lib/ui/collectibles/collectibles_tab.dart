import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/bloc/collectible_provider/collectible_provider.dart';
import 'package:wallet_cryptomask/core/bloc/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/ui/collectibles/collection_tile.dart';
import 'package:wallet_cryptomask/ui/collectibles/import_collectible_screen.dart';

class CollectiblesTab extends StatefulWidget {
  const CollectiblesTab({Key? key}) : super(key: key);

  @override
  State<CollectiblesTab> createState() => _CollectiblesTabState();
}

class _CollectiblesTabState extends State<CollectiblesTab> {
  Timer? _collectibleOwnerTime;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setupAndLoadCollectible();
    });
  }

  setupAndLoadCollectible() {
    Provider.of<CollectibleProvider>(context, listen: false).loadCollectibles(
        address: Provider.of<WalletProvider>(context, listen: false)
            .activeWallet
            .wallet
            .privateKey
            .address
            .hex,
        network:
            Provider.of<WalletProvider>(context, listen: false).activeNetwork);
    if (_collectibleOwnerTime == null) {
      Provider.of<CollectibleProvider>(context, listen: false).loadCollectibles(
          address: Provider.of<WalletProvider>(context, listen: false)
              .activeWallet
              .wallet
              .privateKey
              .address
              .hex,
          network: Provider.of<WalletProvider>(context, listen: false)
              .activeNetwork);
      _collectibleOwnerTime = null;
      _collectibleOwnerTime =
          Timer.periodic(const Duration(seconds: 7), (timer) {
        Provider.of<CollectibleProvider>(context, listen: false)
            .loadCollectibles(
                address: Provider.of<WalletProvider>(context, listen: false)
                    .activeWallet
                    .wallet
                    .privateKey
                    .address
                    .hex,
                network: Provider.of<WalletProvider>(context, listen: false)
                    .activeNetwork);
      });
    }

    //  if (_tokenBalanceTimer == null) {
    //   String address = Provider.of<WalletProvider>(context, listen: false)
    //       .activeWallet
    //       .wallet
    //       .privateKey
    //       .address
    //       .hex;
    //   Provider.of<TokenProvider>(context, listen: false).loadToken(
    //       address: address,
    //       network: Provider.of<WalletProvider>(context, listen: false)
    //           .activeNetwork);
    //   _tokenBalanceTimer = null;
    //   _tokenBalanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
    //     Provider.of<TokenProvider>(context, listen: false).loadToken(
    //         address: address,
    //         network: Provider.of<WalletProvider>(context, listen: false)
    //             .activeNetwork);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Provider.of<CollectibleProvider>(context)
                      .collectibles
                      .length +
                  1,
              itemBuilder: (context, index) => index ==
                      Provider.of<CollectibleProvider>(context)
                          .collectibles
                          .length
                  ? Column(children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(AppLocalizations.of(context)!.dontSeeYouCollectible),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ImportCollectibleScreen.route);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.importCollectible,
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ])
                  : CollectionTile(
                      imageUrl: Provider.of<CollectibleProvider>(context)
                          .collectibles[index]
                          .imageUrl,
                      tokenID: Provider.of<CollectibleProvider>(context)
                          .collectibles[index]
                          .tokenId,
                      tokenAddress: Provider.of<CollectibleProvider>(context)
                          .collectibles[index]
                          .tokenAddress,
                      symbol: Provider.of<CollectibleProvider>(context)
                          .collectibles[index]
                          .name,
                      description: Provider.of<CollectibleProvider>(context)
                          .collectibles[index]
                          .description),
            ),
          ),
        ],
      ),
      // child: Column(
      //   children: [
      //     MultiBlocListener(
      //       listeners: [
      //         BlocListener<WalletCubit, WalletState>(
      //             listener: (context, state) {
      //           if (state is WalletCollectibleAdded) {
      //             context.read<CollectibleCubit>().loadCollectible(
      //                 address: getWalletLoadedState(context)
      //                     .wallet
      //                     .privateKey
      //                     .address
      //                     .hex,
      //                 network: getWalletLoadedState(context).currentNetwork);
      //           }
      //           if (state is WalletNetworkChanged ||
      //               state is WalletAccountChanged) {
      //             context.read<CollectibleCubit>().loadCollectible(
      //                 address: getWalletLoadedState(context)
      //                     .wallet
      //                     .privateKey
      //                     .address
      //                     .hex,
      //                 network: getWalletLoadedState(context).currentNetwork);
      //           }
      //         }),
      //         BlocListener<CollectibleCubit, CollectibleState>(
      //           listener: (context, state) {
      //             if (state is CollectibleInitial) {
      //               getCollectibleCubit(context)
      //                   .setupWeb3Client(widget.web3client);
      //             }
      //           },
      //         )
      //       ],
      //       child: BlocBuilder<CollectibleCubit, CollectibleState>(
      //         builder: (context, state) {
      //           if (state is CollectibleLoaded) {

      //           } else {
      //             return Expanded(
      //               child: Center(
      //                 child: Column(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: const [
      //                     CircularProgressIndicator(
      //                       color: kPrimaryColor,
      //                     ),
      //                     SizedBox(
      //                       height: 10,
      //                     ),
      //                     Text("Loading NFTs")
      //                   ],
      //                 ),
      //               ),
      //             );
      //           }
      //         },
      //       ),
      //     )
      //   ],
      // ),
    );
  }

  @override
  void dispose() {
    _collectibleOwnerTime?.cancel();
    super.dispose();
  }
}
