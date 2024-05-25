// To parse this JSON data, do
//
//     final moralisTokenTransfers = moralisTokenTransfersFromJson(jsonString);

import 'dart:convert';

MoralisTokenTransfers moralisTokenTransfersFromJson(String str) =>
    MoralisTokenTransfers.fromJson(json.decode(str));

String moralisTokenTransfersToJson(MoralisTokenTransfers data) =>
    json.encode(data.toJson());

class MoralisTokenTransfers {
  String status;
  List<TokenTransfer> data;

  MoralisTokenTransfers({
    required this.status,
    required this.data,
  });

  factory MoralisTokenTransfers.fromJson(Map<String, dynamic> json) =>
      MoralisTokenTransfers(
        status: json["status"],
        data: List<TokenTransfer>.from(
            json["data"].map((x) => TokenTransfer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class TokenTransfer {
  String tokenName;
  String tokenSymbol;
  dynamic tokenLogo;
  String tokenDecimals;
  String fromAddress;
  dynamic fromAddressLabel;
  String toAddress;
  dynamic toAddressLabel;
  String address;
  String blockHash;
  String blockNumber;
  DateTime blockTimestamp;
  String transactionHash;
  int transactionIndex;
  int logIndex;
  String value;
  bool possibleSpam;
  String valueDecimal;
  bool verifiedContract;
  String chain;

  TokenTransfer({
    required this.tokenName,
    required this.tokenSymbol,
    required this.tokenLogo,
    required this.tokenDecimals,
    required this.fromAddress,
    required this.fromAddressLabel,
    required this.toAddress,
    required this.toAddressLabel,
    required this.address,
    required this.blockHash,
    required this.blockNumber,
    required this.blockTimestamp,
    required this.transactionHash,
    required this.transactionIndex,
    required this.logIndex,
    required this.value,
    required this.possibleSpam,
    required this.valueDecimal,
    required this.verifiedContract,
    required this.chain,
  });

  factory TokenTransfer.fromJson(Map<String, dynamic> json) => TokenTransfer(
        tokenName: json["tokenName"],
        tokenSymbol: json["tokenSymbol"],
        tokenLogo: json["tokenLogo"],
        tokenDecimals: json["tokenDecimals"],
        fromAddress: json["fromAddress"],
        fromAddressLabel: json["fromAddressLabel"],
        toAddress: json["toAddress"],
        toAddressLabel: json["toAddressLabel"],
        address: json["address"],
        blockHash: json["blockHash"],
        blockNumber: json["blockNumber"],
        blockTimestamp: DateTime.parse(json["blockTimestamp"]),
        transactionHash: json["transactionHash"],
        transactionIndex: json["transactionIndex"],
        logIndex: json["logIndex"],
        value: json["value"],
        possibleSpam: json["possibleSpam"],
        valueDecimal: json["valueDecimal"],
        verifiedContract: json["verifiedContract"],
        chain: json["chain"],
      );

  Map<String, dynamic> toJson() => {
        "tokenName": tokenName,
        "tokenSymbol": tokenSymbol,
        "tokenLogo": tokenLogo,
        "tokenDecimals": tokenDecimals,
        "fromAddress": fromAddress,
        "fromAddressLabel": fromAddressLabel,
        "toAddress": toAddress,
        "toAddressLabel": toAddressLabel,
        "address": address,
        "blockHash": blockHash,
        "blockNumber": blockNumber,
        "blockTimestamp": blockTimestamp.toIso8601String(),
        "transactionHash": transactionHash,
        "transactionIndex": transactionIndex,
        "logIndex": logIndex,
        "value": value,
        "possibleSpam": possibleSpam,
        "valueDecimal": valueDecimal,
        "verifiedContract": verifiedContract,
        "chain": chain,
      };
}
