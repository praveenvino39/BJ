// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:wallet_cryptomask/core/abi.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:web3dart/web3dart.dart';

class CollectibleProvider extends ChangeNotifier {
  List<Collectible> collectibles = [];
  final Box userPreference;

  CollectibleProvider({required this.userPreference});

  String getCollectibleStorageKey(
      {required address, required Network network}) {
    return "COLLECTIBLE-$address-${network.networkName}";
  }

  Future<String> getCollectibleDetails(
      String collectibleAddress, Network network) async {
    var contractAbi = ContractAbi.fromJson(jsonEncode(ERC721), "");
    var contract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(collectibleAddress));
    var nameFunction = contract.function('name');
    var nameResult = await Web3Client(network.url, Client())
        .call(contract: contract, function: nameFunction, params: []);
    return (nameResult as dynamic)[0].toString();
  }

  Future<void> addCollectibles(
      {required Collectible collectible,
      required String address,
      required Network network}) async {
    final web3client = Web3Client(network.url, Client());
    String collectibleStoragekey =
        getCollectibleStorageKey(address: address, network: network);
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
        var response = await Dio().get(
            "https://ipfs.io/ipfs/${(uriResult as dynamic)[0]}".toString());
        collectible.imageUrl = response.data["image"];
        collectible.description = response.data["description"];
      } catch (e) {}
      List<dynamic> collectibles =
          await userPreference.get(collectibleStoragekey) ?? [];
      if (collectibles.contains(collectible)) {
        return;
      } else {
        collectibles.add(collectible);
        await userPreference.put(collectibleStoragekey, collectibles);
      }
    } else {
      throw Exception("NFT not owned by user");
    }
  }

  void deleteCollectibles(
      {required Collectible collectible,
      required String address,
      required Network network}) {
    String collectibleStorageKey =
        getCollectibleStorageKey(address: address, network: network);
    List<dynamic> collectiblesDy =
        userPreference.get(collectibleStorageKey) ?? [];
    collectiblesDy.remove(collectible);
    userPreference.put(collectibleStorageKey, collectiblesDy);
    loadCollectibles(address: address, network: network);
  }

  loadCollectibles({
    required String address,
    required Network network,
  }) async {
    String collectibleStorageKey =
        getCollectibleStorageKey(address: address, network: network);
    List<dynamic> collectibles =
        userPreference.get(collectibleStorageKey) ?? [];
    this.collectibles = collectibles.cast<Collectible>();
    notifyListeners();
  }

  Future<String?> sendNFTTransaction(
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
      final web3client = Web3Client(network.url, Client());
      String collectibleStorageKey = getCollectibleStorageKey(
          address: wallet.privateKey.address.hex, network: network);
      ContractAbi contractABI = ContractAbi.fromJson(jsonEncode(ERC721), "");
      DeployedContract deployedContract = DeployedContract(
          contractABI, EthereumAddress.fromHex(collectible.tokenAddress));
      var sendResult = await web3client.sendTransaction(
          wallet.privateKey,
          Transaction(
            maxGas: gasLimit,
            gasPrice: network.chainId == 144
                ? EtherAmount.inWei(BigInt.parse("2"))
                : null,
            maxPriorityFeePerGas: network.supportsEip1559
                ? EtherAmount.fromUnitAndValue(
                    EtherUnit.wei, (selectedPriority * pow(10, 9)).toInt())
                : null,
            maxFeePerGas: network.supportsEip1559
                ? EtherAmount.fromUnitAndValue(
                    EtherUnit.wei, (selectedMaxFee * pow(10, 9)).toInt())
                : null,
            to: EthereumAddress.fromHex(collectible.tokenAddress),
            data: deployedContract.function("transferFrom").encodeCall([
              EthereumAddress.fromHex(from),
              EthereumAddress.fromHex(to),
              BigInt.parse(collectible.tokenId),
            ]),
          ),
          chainId: network.chainId);

      List<dynamic> collectiblesDy = userPreference.get(collectibleStorageKey);
      if (to != from) {
        List<Collectible> collectibles = collectiblesDy.cast<Collectible>();
        collectibles.remove(collectible);
        userPreference.put(collectibleStorageKey, collectibles);
        return sendResult;
      }
      List<dynamic> recentAddresses =
          userPreference.get("RECENT-TRANSACTION-ADDRESS", defaultValue: []);
      if (recentAddresses.contains(to)) {
        recentAddresses.remove(to);
      }
      recentAddresses.add(to);
      userPreference.put("RECENT-TRANSACTION-ADDRESS", recentAddresses);
      return sendResult;
    } catch (e) {
      return null;
    }
  }
}
