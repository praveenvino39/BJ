import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constant.dart';
import 'package:wallet/core/bloc/collectible-bloc/cubit/collectible_cubit.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/cubit_helper.dart';
import 'package:wallet/ui/collectibles/collection_tile.dart';
import 'package:wallet/ui/collectibles/import_collectible_screen.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollectiblesTab extends StatefulWidget {
  final Web3Client web3client;
  final String networkName;
  const CollectiblesTab(
      {Key? key, required this.web3client, required this.networkName})
      : super(key: key);

  @override
  State<CollectiblesTab> createState() => _CollectiblesTabState();
}

class _CollectiblesTabState extends State<CollectiblesTab> {
  Timer? _collectibleOwnerTime;

  @override
  void initState() {
    setupAndLoadCollectible();
    super.initState();
  }

  setupAndLoadCollectible() {
    getCollectibleCubit(context).setupWeb3Client(widget.web3client);
    getCollectibleCubit(context).loadCollectible(
        address: getWalletLoadedState(context).wallet.privateKey.address.hex,
        network: getWalletLoadedState(context).currentNetwork);
    if (_collectibleOwnerTime == null) {
      getCollectibleCubit(context).loadCollectible(
          address: getWalletLoadedState(context).wallet.privateKey.address.hex,
          network: getWalletLoadedState(context).currentNetwork);
      _collectibleOwnerTime =
          Timer.periodic(const Duration(seconds: 7), (timer) {
        getCollectibleCubit(context).loadCollectible(
            address:
                getWalletLoadedState(context).wallet.privateKey.address.hex,
            network: getWalletLoadedState(context).currentNetwork);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          MultiBlocListener(
            listeners: [
              BlocListener<WalletCubit, WalletState>(
                  listener: (context, state) {
                if (state is WalletCollectibleAdded) {
                  context.read<CollectibleCubit>().loadCollectible(
                      address: getWalletLoadedState(context)
                          .wallet
                          .privateKey
                          .address
                          .hex,
                      network: getWalletLoadedState(context).currentNetwork);
                }
                if (state is WalletNetworkChanged ||
                    state is WalletAccountChanged) {
                  context.read<CollectibleCubit>().loadCollectible(
                      address: getWalletLoadedState(context)
                          .wallet
                          .privateKey
                          .address
                          .hex,
                      network: getWalletLoadedState(context).currentNetwork);
                }
              }),
              BlocListener<CollectibleCubit, CollectibleState>(
                listener: (context, state) {
                  if (state is CollectibleInitial) {
                    getCollectibleCubit(context)
                        .setupWeb3Client(widget.web3client);
                  }
                },
              )
            ],
            child: BlocBuilder<CollectibleCubit, CollectibleState>(
              builder: (context, state) {
                if (state is CollectibleLoaded) {
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.collectibles.length + 1,
                            itemBuilder: (context, index) => index ==
                                    state.collectibles.length
                                ? Column(children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(AppLocalizations.of(context)!
                                        .dontSeeYouCollectible),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            ImportCollectibleScreen.route);
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .importCollectible,
                                        style: const TextStyle(
                                            color: kPrimaryColor),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    )
                                  ])
                                : CollectionTile(
                                    imageUrl:
                                        state.collectibles[index].imageUrl,
                                    tokenID: state.collectibles[index].tokenId,
                                    tokenAddress:
                                        state.collectibles[index].tokenAddress,
                                    symbol: state.collectibles[index].name,
                                    description:
                                        state.collectibles[index].description),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Loading NFTs")
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _collectibleOwnerTime?.cancel();
    super.dispose();
  }
}
