// To parse this JSON data, do
//
//     final allTokenResponse = allTokenResponseFromJson(jsonString);

import 'dart:convert';

AllTokenResponse allTokenResponseFromJson(String str) =>
    AllTokenResponse.fromJson(json.decode(str));

String allTokenResponseToJson(AllTokenResponse data) =>
    json.encode(data.toJson());

class AllTokenResponse {
  AllTokenResponse({
    required this.name,
    required this.timestamp,
    required this.logoUri,
    required this.keywords,
    required this.tokens,
  });

  String name;
  DateTime timestamp;
  String logoUri;
  List<String> keywords;
  List<CoinGeckoToken> tokens;

  factory AllTokenResponse.fromJson(Map<String, dynamic> json) =>
      AllTokenResponse(
        name: json["name"],
        timestamp: DateTime.parse(json["timestamp"]),
        logoUri: json["logoURI"],
        keywords: List<String>.from(json["keywords"].map((x) => x)),
        tokens: List<CoinGeckoToken>.from(
            json["tokens"].map((x) => CoinGeckoToken.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "timestamp": timestamp.toIso8601String(),
        "logoURI": logoUri,
        "keywords": List<dynamic>.from(keywords.map((x) => x)),
        "tokens": List<dynamic>.from(tokens.map((x) => x.toJson())),
      };
}

class CoinGeckoToken {
  CoinGeckoToken({
    required this.chainId,
    required this.address,
    required this.name,
    required this.symbol,
    required this.decimals,
    this.logoUri,
  });

  int chainId;
  String address;
  String name;
  String symbol;
  int decimals;
  String? logoUri;

  factory CoinGeckoToken.fromJson(Map<String, dynamic> json) => CoinGeckoToken(
        chainId: json["chainId"],
        address: json["address"],
        name: json["name"],
        symbol: json["symbol"],
        decimals: json["decimals"],
        logoUri: json["logoURI"],
      );

  Map<String, dynamic> toJson() => {
        "chainId": chainId,
        "address": address,
        "name": name,
        "symbol": symbol,
        "decimals": decimals,
        "logoURI": logoUri,
      };
}

class Extensions {
  Extensions({
    required this.bridgeInfo,
  });

  Map<String, BridgeInfo> bridgeInfo;

  factory Extensions.fromJson(Map<String, dynamic> json) => Extensions(
        bridgeInfo: Map.from(json["bridgeInfo"]).map(
            (k, v) => MapEntry<String, BridgeInfo>(k, BridgeInfo.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "bridgeInfo": Map.from(bridgeInfo)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class BridgeInfo {
  BridgeInfo({
    required this.tokenAddress,
  });

  String tokenAddress;

  factory BridgeInfo.fromJson(Map<String, dynamic> json) => BridgeInfo(
        tokenAddress: json["tokenAddress"],
      );

  Map<String, dynamic> toJson() => {
        "tokenAddress": tokenAddress,
      };
}
