import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:wallet_cryptomask/core/ERC20.dart';
import 'package:wallet_cryptomask/core/core.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:web3dart/web3dart.dart';

class TokenProvider extends ChangeNotifier {
  List<Token> tokens = [];
  final Box userPreference;

  TokenProvider({required this.userPreference});

  loadToken({
    required String address,
    required Network network,
  }) async {
    String tokenStorageKey =
        getTokenStorageKey(address: address, network: network);
    List<dynamic> tokens = userPreference.get(tokenStorageKey) ?? [];
    for (var token in tokens) {
      (token as Token).balance =
          (await getTokenBalance(token, address, network)).toDouble();
    }
    this.tokens = tokens.cast<Token>();
    notifyListeners();
  }

  String getTokenStorageKey({required address, required Network network}) {
    return "TOKEN-$address-${network.networkName}";
  }

  Future<Decimal> getTokenBalance(
      Token token, String address, Network network) async {
    Erc20 erc20Token = Erc20(
        address: EthereumAddress.fromHex(token.tokenAddress),
        client: Web3Client(network.url, Client()),
        chainId: network.chainId);
    var balance = await erc20Token.balanceOf(EthereumAddress.fromHex(address));
    var decimalValue = Decimal.parse(balance.toString());
    return (decimalValue / Decimal.fromInt(pow(10, token.decimal).toInt()))
        .toDecimal();
  }

  Future<void> addToken(
      {required String address,
      required Network network,
      required Token token}) async {
    String tokenStoragekey =
        getTokenStorageKey(address: address, network: network);
    List<dynamic> tokens = userPreference.get(tokenStoragekey) ?? [];
    if (tokens.contains(token)) {
      return;
    }
    var tokenBalance = await getTokenBalance(token, address, network);
    token.balance = tokenBalance.toDouble();
    tokens.add(token);
    for (var tokenObj in Core.tokenList) {
      if ((tokenObj as dynamic)["symbol"].toString().toLowerCase() ==
          token.symbol.toLowerCase()) {
        token.coinGeckoID = (tokenObj as dynamic)["id"];
        break;
      }
    }
    await userPreference.put(tokenStoragekey, tokens);
    loadToken(address: address, network: network);
  }

  Future<List<String>> getTokenInfo(
      {required String tokenAddress, required Network network}) async {
    Erc20 erc20Token = Erc20(
        address: EthereumAddress.fromHex(tokenAddress),
        client: Web3Client(network.url, Client()),
        chainId: network.chainId);
    String decimal = ((await erc20Token.decimals()).toString());
    String symbol = await erc20Token.symbol();

    return [decimal, symbol];
  }

  Future<void> deleteToken(
      {required Token token,
      required String address,
      required Network network}) async {
    String tokenStorageKey =
        getTokenStorageKey(address: address, network: network);
    List<dynamic> tokensDy = userPreference.get(tokenStorageKey) ?? [];
    tokensDy.remove(token);
    await userPreference.put(tokenStorageKey, tokensDy);
    loadToken(address: address, network: network);
  }
}
