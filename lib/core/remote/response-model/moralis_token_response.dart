// To parse this JSON data, do
//
//     final moralisTokensResponse = moralisTokensResponseFromJson(jsonString);

import 'dart:convert';

import 'moralis_token.dart';

MoralisTokensResponse moralisTokensResponseFromJson(String str) =>
    MoralisTokensResponse.fromJson(json.decode(str));

String moralisTokensResponseToJson(MoralisTokensResponse data) =>
    json.encode(data.toJson());

class MoralisTokensResponse {
  String status;
  List<MoralisToken> data;

  MoralisTokensResponse({
    required this.status,
    required this.data,
  });

  factory MoralisTokensResponse.fromJson(Map<String, dynamic> json) =>
      MoralisTokensResponse(
        status: json["status"],
        data: List<MoralisToken>.from(
            json["data"].map((x) => MoralisToken.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Token {
  int decimals;
  String name;
  String symbol;
  String contractAddress;
  String chain;
  bool possibleSpam;

  Token({
    required this.decimals,
    required this.name,
    required this.symbol,
    required this.contractAddress,
    required this.chain,
    required this.possibleSpam,
  });

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        decimals: json["decimals"],
        name: json["name"],
        symbol: json["symbol"],
        contractAddress: json["contractAddress"],
        chain: json["chain"],
        possibleSpam: json["possibleSpam"],
      );

  Map<String, dynamic> toJson() => {
        "decimals": decimals,
        "name": name,
        "symbol": symbol,
        "contractAddress": contractAddress,
        "chain": chain,
        "possibleSpam": possibleSpam,
      };
}
