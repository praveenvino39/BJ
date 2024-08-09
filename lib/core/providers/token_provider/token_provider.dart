// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/utils/eth-utils/erc20.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_token_transfer.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_transaction_response.dart';
import 'package:web3dart/web3dart.dart';

TokenProvider getTokenProvider(BuildContext context) =>
    context.read<TokenProvider>();

class TokenProvider extends ChangeNotifier {
  List<Token> tokens = [];
  final Box userPreference;

  TokenProvider({required this.userPreference});

  Future<List<Token>> loadToken({
    required double nativeBalance,
    required String address,
    required Network network,
  }) async {
    try {
      final moralisTokenResponse = await RemoteServer.getTokens(
          address: address, chainId: network.chainId.toString());
      List<Token> tokens = [];
      for (var token in moralisTokenResponse.data) {
        tokens.add(
          Token(
            tokenAddress: !token.nativeToken ? token.tokenAddress : "",
            symbol: token.symbol,
            imageUrl: token.logo,
            decimal: token.decimals,
            balance: double.parse(token.balanceFormatted),
            balanceInFiat: token.usdValue ?? 0,
          ),
        );
      }
      this.tokens = tokens;
    } catch (e) {
      tokens = [];
    }

    notifyListeners();
    return tokens;
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

  Future<List<TokenTransfer>> getTokenTransfer(
      {required String tokenAddress,
      required String address,
      required Network network}) async {
    try {
      final moralisTokenTransactionResponse =
          await RemoteServer.getTransactionForToken(
        tokenAddress: tokenAddress,
        address: address,
        chainId: network.chainId.toString(),
      );
      return moralisTokenTransactionResponse.data;
    } catch (e) {
      return [];
    }
  }

  Future<List<MoralisTransaction>> getTransactions(
      {required String address, required Network network}) async {
    try {
      final moralisTransactionResponse = await RemoteServer.getTransactions(
          address: address, chainId: network.chainId.toString());
      return moralisTransactionResponse.data;
    } catch (e) {
      return [];
    }
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
      {required double nativeBalance,
      required Token token,
      required String address,
      required Network network}) async {
    String tokenStorageKey =
        getTokenStorageKey(address: address, network: network);
    List<dynamic> tokensDy = userPreference.get(tokenStorageKey) ?? [];
    tokensDy.remove(token);
    await userPreference.put(tokenStorageKey, tokensDy);
    loadToken(nativeBalance: nativeBalance, address: address, network: network);
  }

  Future<String?> sendTokenTransaction(
      String to,
      double value,
      int gasLimit,
      double selectedPriority,
      double selectedMaxFee,
      Token selectedToken,
      DeployedContract deployedContract,
      Wallet wallet,
      Network network,
      bool fee) async {
    try {
      final web3client = Web3Client(network.url, Client());
      var sendResult = await web3client.sendTransaction(
          wallet.privateKey,
          Transaction(
            maxGas: gasLimit,
            gasPrice: network.chainId == 144
                ? EtherAmount.inWei(BigInt.parse("2"))
                : null,
            to: EthereumAddress.fromHex(selectedToken.tokenAddress),
            data: deployedContract.function("transfer").encodeCall([
              EthereumAddress.fromHex(to),
              BigInt.from((value * pow(10, selectedToken.decimal))),
            ]),
          ),
          chainId: network.chainId);
      if (fee) {
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
      throw Exception(e.toString());
    }
  }
}
