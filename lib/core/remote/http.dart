// ignore_for_file: control_flow_in_finally

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio_library;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/core/model/coin_gecko_token_model.dart';
import 'package:wallet_cryptomask/core/model/gas_tracker_api.dart';
import 'package:wallet_cryptomask/core/model/message.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';
import 'package:wallet_cryptomask/core/remote/response-model/erc20_transaction_log.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_token_response.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_token_transfer.dart';
import 'package:wallet_cryptomask/core/remote/response-model/moralis_transaction_response.dart';
import 'package:wallet_cryptomask/core/remote/response-model/platform_fee_response.dart';
import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';
import 'package:wallet_cryptomask/core/remote/response-model/settings_response.dart';
import 'package:wallet_cryptomask/core/remote/response-model/transaction_log_result.dart';

final dio = Dio();

class RemoteServer {
  static Future<ResigterUserResponse> registerUser(
      {required String message,
      required String hash,
      required String address}) async {
    final response = await dio.post('$baseUrl/api/user/register',
        options:
            Options(headers: {Headers.contentTypeHeader: 'application/json'}),
        data: {"message": message, "hash": hash, "address": address});
    return ResigterUserResponse.fromJson(response.data);
  }

  static Future<ResigterUserResponse> setBackedUp() async {
    final user = Get.find<User>();
    final response = await dio.put(
      '$baseUrl/api/user/backedup',
      options: Options(
        headers: {
          Headers.contentTypeHeader: 'application/json',
          "Authorization": "Bearer ${user.token}"
        },
      ),
    );
    return ResigterUserResponse.fromJson(response.data);
  }

  static Future<SettingsResponse> settings() async {
    final response = await dio.get('$baseUrl/api/user/settings');
    return SettingsResponse.fromJson(response.data);
  }

  static Future<PlatformFeeResponse> getPlatformFee() async {
    final response = await dio.get('$baseUrl/api/user/fee');
    return PlatformFeeResponse.fromJson(response.data);
  }

  static Future<ResigterUserResponse> addAccount(
      {required String message,
      required String hash,
      required String address}) async {
    final user = Get.find<User>();
    final response = await dio.post('$baseUrl/api/user/addAccount',
        options: Options(headers: {
          Headers.contentTypeHeader: 'application/json',
          "Authorization": "Bearer ${user.token}"
        }),
        data: {"message": message, "hash": hash, "address": address});
    return ResigterUserResponse.fromJson(response.data);
  }

  static Future<MoralisTokensResponse> getTokens(
      {required String chainId, required String address}) async {
    final user = Get.find<User>();
    final response = await dio.get(
      '$baseUrl/api/user/tokens/$address/$chainId',
      options: Options(headers: {"Authorization": "Bearer ${user.token}"}),
    );
    return MoralisTokensResponse.fromJson(response.data);
  }

  static Future<MoralisTokenTransfers> getTransactionForToken(
      {required String chainId,
      required String address,
      required String tokenAddress}) async {
    final user = Get.find<User>();
    final response = await dio.get(
      '$baseUrl/api/user/tokens/transfers/$address/$tokenAddress/$chainId',
      options: Options(headers: {"Authorization": "Bearer ${user.token}"}),
    );
    return MoralisTokenTransfers.fromJson(response.data);
  }

  static Future<MoralisTransactionResponse> getTransactions(
      {required String chainId, required String address}) async {
    final user = Get.find<User>();
    final response = await dio.get(
      '$baseUrl/api/user/wallet/transactions/$address/$chainId',
      options: Options(headers: {"Authorization": "Bearer ${user.token}"}),
    );
    return MoralisTransactionResponse.fromJson(response.data);
  }

  static Future<ResigterUserResponse> loginUser(
      {required String message,
      required String hash,
      required String address}) async {
    final response = await dio.post('$baseUrl/api/user/login',
        options:
            Options(headers: {Headers.contentTypeHeader: 'application/json'}),
        data: {"message": message, "hash": hash, "address": address});
    return ResigterUserResponse.fromJson(response.data);
  }
}

Future<dynamic> getPrice(String priceId) async {
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

Future<Media?> uploadFile(String token, File file, String fileName) async {
  try {
    final formData = dio_library.FormData.fromMap({
      'file': await dio_library.MultipartFile.fromFile(file.path,
          filename: fileName)
    });
    var response = await Dio().post("$baseUrl/api/user/upload",
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}));
    final media = Media.fromJson(response.data['data']);
    return media;
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
    final response = await Dio().post(
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
    final response = await Dio().get('https://tokens.uniswap.org');
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
    final response = await Dio()
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
