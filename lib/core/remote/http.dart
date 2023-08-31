// ignore_for_file: control_flow_in_finally

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'package:wallet/core/model/coin_gecko_token_model.dart';
import 'package:wallet/core/model/gas_tracker_api.dart';
import 'package:wallet/core/model/network_model.dart';
import 'package:wallet/core/remote/response-model/erc20_transaction_log.dart';
import 'package:wallet/core/remote/response-model/price_response.dart';
import 'package:wallet/core/remote/response-model/transaction_log_result.dart';

Future<dynamic> getPrice(String priceId) async {
  if (priceId == "phi-network") {
    try {
      Box box = await Hive.openBox("user_preference");
      String currency = box.get("CURRENCY") ?? "usd";
      var response = await Dio().get('https://phi.financial/api/token/phi');
      return {"currentPrice": response.data['price_usd']};
    } catch (e) {
      log(e.toString());
    }
  }

  try {
    Box box = await Hive.openBox("user_preference");
    String currency = box.get("CURRENCY") ?? "usd";
    var response = await Dio().get(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=$currency&ids=$priceId');
    return {"currentPrice": response.data[0]["current_price"]};
  } catch (e) {
    log(e.toString());
  }
  return null;
}

Future<List<String>?> getSupportedVsCurrency() async {
  try {
    var response = await Dio()
        .get('https://api.coingecko.com/api/v3/simple/supported_vs_currencies');
    List<String> currencyList = [];
    for (var currency in response.data) {
      currencyList.add(currency);
    }
    return currencyList;
  } catch (e) {
    log(e.toString());
  }
  return null;
}

// Future<List<PriceResponse>?> getTokenPrice(List<String> tokensSymbol) async {
//   try {
//     List<String> tokenId = [];
//     for (var tokenSymbol in tokensSymbol) {
//       try {
//         var foundToken = Core.tokenList.firstWhere((element) =>
//             element["symbol"]!.toLowerCase() == tokenSymbol.toLowerCase());
//         tokenId.add(foundToken["id"].toString());
//       } catch (e) {
//         log(e.toString());
//       }
//       log(tokenId.join(","));
//     }
//     var response = await Dio().get(
//         'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${tokenId.join(",")}');
//     List<PriceResponse> tokenPriceList = [];
//     for (var element in response.data) {
//       tokenPriceList.add(PriceResponse.fromJson(element));
//     }
//     return tokenPriceList;
//   } catch (e) {
//     log(e.toString());
//   }
//   return null;
// }

Future<List<TransactionResult>?> getTransactionLog(
    String address, Network network,
    {String? tokenAdress}) async {
  try {
    log("${network.etherscanApiBaseUrl}api?module=account&action=txlist&address=$address&startblock=0&endblock=99999999&sort=asc&apikey=${network.apiKey}");
    var response = await Dio().get(
        '${network.etherscanApiBaseUrl}api?module=account&action=txlist&address=$address&startblock=0&endblock=99999999&sort=asc&apikey=${network.apiKey}');
    log(jsonEncode(response.data));
    if (tokenAdress == null) {
      log(tokenAdress.toString());
      return TransactionLogResult.fromJson(response.data)
          .result
          .reversed
          .toList();
    } else {
      return TransactionLogResult.fromJson(response.data)
          .result
          .where((element) {
            return element.to == tokenAdress;
          })
          .toList()
          .reversed
          .toList();
    }
  } catch (e) {
    log(e.toString());
  }
  return null;
}

Future<dynamic> callBlockChain(dynamic request, String networkRpcUrl) async {
  try {
    Response response = await Dio().post(
      networkRpcUrl,
      data: {
        "id": math.Random().nextInt(9999999).toString(),
        "jsonrpc": "2.0",
        "method": request["method"],
        "params": request["params"]
      },
    );
    return response.data;
  } catch (e) {
    log(jsonEncode(e));
  }
}

Future<List<ERC20Transfer>?> getERC20TransferLog(
    String address, Network network, String tokenContractAddress) async {
  try {
    log("${network.etherscanApiBaseUrl}api?module=account&action=tokentx&contractaddress=$tokenContractAddress&address=$address&startblock=0&endblock=99999999&sort=asc&apikey=${network.apiKey}");
    var response = await Dio().get(
        "${network.etherscanApiBaseUrl}api?module=account&action=tokentx&contractaddress=$tokenContractAddress&address=$address&startblock=0&endblock=99999999&sort=asc&apikey=${network.apiKey}");
    return Erc20TransferLog.fromJson(response.data).result.reversed.toList();
  } catch (e) {
    log(e.toString());
  }
  return null;
}

Future<String> getAbiFromContract(
    String contractAddress, Network network) async {
  try {
    var response = await Dio().get(
        '${network.etherscanApiBaseUrl}api?module=contract&action=getabi&address=$contractAddress&apikey=${network.apiKey}');
    return response.data["result"].toString();
  } catch (e) {
    log(e.toString());
  } finally {
    return jsonEncode([
      {
        "constant": true,
        "inputs": [],
        "name": "name",
        "outputs": [
          {"name": "", "type": "string"}
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {"name": "_spender", "type": "address"},
          {"name": "_value", "type": "uint256"}
        ],
        "name": "approve",
        "outputs": [
          {"name": "", "type": "bool"}
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "totalSupply",
        "outputs": [
          {"name": "", "type": "uint256"}
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {"name": "_from", "type": "address"},
          {"name": "_to", "type": "address"},
          {"name": "_value", "type": "uint256"}
        ],
        "name": "transferFrom",
        "outputs": [
          {"name": "", "type": "bool"}
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "decimals",
        "outputs": [
          {"name": "", "type": "uint8"}
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {"name": "_owner", "type": "address"}
        ],
        "name": "balanceOf",
        "outputs": [
          {"name": "balance", "type": "uint256"}
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "symbol",
        "outputs": [
          {"name": "", "type": "string"}
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {"name": "_to", "type": "address"},
          {"name": "_value", "type": "uint256"}
        ],
        "name": "transfer",
        "outputs": [
          {"name": "", "type": "bool"}
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {"name": "_owner", "type": "address"},
          {"name": "_spender", "type": "address"}
        ],
        "name": "allowance",
        "outputs": [
          {"name": "", "type": "uint256"}
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {"payable": true, "stateMutability": "payable", "type": "fallback"},
      {
        "anonymous": false,
        "inputs": [
          {"indexed": true, "name": "owner", "type": "address"},
          {"indexed": true, "name": "spender", "type": "address"},
          {"indexed": false, "name": "value", "type": "uint256"}
        ],
        "name": "Approval",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {"indexed": true, "name": "from", "type": "address"},
          {"indexed": true, "name": "to", "type": "address"},
          {"indexed": false, "name": "value", "type": "uint256"}
        ],
        "name": "Transfer",
        "type": "event"
      }
    ]);
  }
}

Future<List<CoinGeckoToken>?> getAllToken() async {
  try {
    Response response = await Dio().get('https://tokens.uniswap.org');
    log(jsonEncode(response.data));
    AllTokenResponse parsedResponse =
        allTokenResponseFromJson(jsonEncode(response.data));
    return parsedResponse.tokens;
  } catch (e) {
    log(e.toString());
    return null;
  }
}

Future<GasTrackerResponse?> getGasTrackerPrice() async {
  try {
    Response response = await Dio()
        .get('https://api.etherscan.io/api?module=gastracker&action=gasoracle');
    log(jsonEncode(response.data));
    GasTrackerResponse parsedResponse =
        GasTrackerResponse.fromJson(response.data);
    return parsedResponse;
  } catch (e) {
    log(e.toString());
    return null;
  }
}
