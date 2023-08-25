// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:wallet/core/abi.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/model/collectible_model.dart';
import 'package:wallet/core/model/network_model.dart';
import 'package:web3dart/web3dart.dart';

part 'collectible_state.dart';

class CollectibleCubit extends Cubit<CollectibleState> {
  final Box userPreferenceBox;
  late Web3Client web3client;
  CollectibleCubit({required this.userPreferenceBox})
      : super(CollectibleInitial());

  setupWeb3Client(Web3Client web3client) {
    this.web3client = web3client;
  }

  loadCollectible({required String address, required Network network}) async {
    emit(CollectibleLoading());
    String collectibleStorageKey =
        getCollectibleStorageKey(address: address, network: network);
    List<dynamic> collectibles =
        userPreferenceBox.get(collectibleStorageKey) ?? [];
    log(jsonEncode(collectibles));
    emit(CollectibleLoaded(collectibles: collectibles.cast<Collectible>()));
  }

  addCollectibles(
      {required Collectible collectible,
      required String address,
      required Network network}) async {
    String collectibleStoragekey =
        getCollectibleStorageKey(address: address, network: network);
    log(collectibleStoragekey);
    var contractAbi = ContractAbi.fromJson(jsonEncode(ERC721), "");
    var contract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(collectible.tokenAddress));
    var function = contract.function('ownerOf');
    var uriTokenFunction = contract.function('tokenURI');
    var ownerResult =
        await web3client.call(contract: contract, function: function, params: [
      BigInt.parse(collectible.tokenId),
    ]);
    if ((ownerResult as dynamic)[0].toString().toLowerCase() ==
        address.toLowerCase()) {
      try {
        var uriResult = await web3client
            .call(contract: contract, function: uriTokenFunction, params: [
          BigInt.parse(collectible.tokenId),
        ]);
        log(uriResult.toString());
        var response = await Dio().get(
            "https://ipfs.io/ipfs/${(uriResult as dynamic)[0]}".toString());
        collectible.imageUrl = response.data["image"];
        collectible.description = response.data["description"];
      } catch (e) {
        log(e.toString());
      }
      List<dynamic> collectibles =
          await userPreferenceBox.get(collectibleStoragekey) ?? [];

      if (collectibles.contains(collectible)) {
        emit(CollectibleAdded(collectibles: collectibles.cast<Collectible>()));
        return;
      } else {
        collectibles.add(collectible);
        await userPreferenceBox.put(collectibleStoragekey, collectibles);
      }
      emit(CollectibleAdded(collectibles: collectibles.cast<Collectible>()));
    } else {
      emit(const CollectibleError(error: "NFT not owned by user"));
    }
  }

  void deleteCollectibles(
      {required Collectible collectible,
      required String address,
      required Network network}) {
    String collectibleStorageKey =
        getCollectibleStorageKey(address: address, network: network);
    List<dynamic> collectiblesDy =
        userPreferenceBox.get(collectibleStorageKey) ?? [];
    collectiblesDy.remove(collectible);
    userPreferenceBox.put(collectibleStorageKey, collectiblesDy);
    emit(CollectibleDeleted(collectibles: collectiblesDy.cast<Collectible>()));
  }

  String getCollectibleStorageKey(
      {required address, required Network network}) {
    return "COLLECTIBLE-$address-${network.networkName}";
  }

  Future<String> getCollectibleDetails(String collectibleAddress) async {
    var contractAbi = ContractAbi.fromJson(jsonEncode(ERC721), "");
    var contract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(collectibleAddress));
    var nameFunction = contract.function('name');
    var nameResult = await web3client
        .call(contract: contract, function: nameFunction, params: []);
    return (nameResult as dynamic)[0].toString();
  }

  sendNFTTransaction(
      String to,
      String from,
      double value,
      int gasLimit,
      double selectedPriority,
      double selectedMaxFee,
      Collectible collectible,
      Wallet wallet,
      Network network) async {
    try {
      String collectibleStorageKey = getCollectibleStorageKey(
          address: wallet.privateKey.address.hex, network: network);
      ContractAbi contractABI = ContractAbi.fromJson(jsonEncode(ERC721), "");
      DeployedContract deployedContract = DeployedContract(
          contractABI, EthereumAddress.fromHex(collectible.tokenAddress));
      BigInt chainID = await web3client.getChainId();
      var sendResult = await web3client.sendTransaction(
          wallet.privateKey,
          Transaction(
            maxGas: gasLimit,
            maxPriorityFeePerGas: EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (selectedPriority * math.pow(10, 9)).toInt()),
            maxFeePerGas: EtherAmount.fromUnitAndValue(
                EtherUnit.wei, (selectedMaxFee * math.pow(10, 9)).toInt()),
            to: EthereumAddress.fromHex(collectible.tokenAddress),
            data: deployedContract.function("transferFrom").encodeCall([
              EthereumAddress.fromHex(from),
              EthereumAddress.fromHex(to),
              BigInt.parse(collectible.tokenId),
            ]),
          ),
          chainId: chainID.toInt());

      log("TRANSACTION RESULT ====> $sendResult");
      List<dynamic> collectiblesDy =
          userPreferenceBox.get(collectibleStorageKey);
      if (to != from) {
        List<Collectible> collectibles = collectiblesDy.cast<Collectible>();
        collectibles.remove(collectible);
        userPreferenceBox.put(collectibleStorageKey, collectibles);
        emit(CollectibleTransfer(collectibles: collectibles));
        return;
      }
      WalletCubit.showTransactionStatus(sendResult, web3client);
      Hive.openBox("user_preference").then((box) {
        List<dynamic> recentAddresses =
            box.get("RECENT-TRANSACTION-ADDRESS", defaultValue: []);
        if (recentAddresses.contains(to)) {
          recentAddresses.remove(to);
        }
        recentAddresses.add(to);
        box.put("RECENT-TRANSACTION-ADDRESS", recentAddresses);
      });
      emit(CollectibleTransfer(
          collectibles: collectiblesDy.cast<Collectible>()));
    } catch (e) {
      log((e as dynamic).toString());
      emit(CollectibleError(error: e.toString()));
    }
  }
}
