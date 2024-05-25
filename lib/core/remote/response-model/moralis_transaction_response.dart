// To parse this JSON data, do
//
//     final moralisTransactionResponse = moralisTransactionResponseFromJson(jsonString);

import 'dart:convert';

MoralisTransactionResponse moralisTransactionResponseFromJson(String str) =>
    MoralisTransactionResponse.fromJson(json.decode(str));

String moralisTransactionResponseToJson(MoralisTransactionResponse data) =>
    json.encode(data.toJson());

class MoralisTransactionResponse {
  String status;
  List<MoralisTransaction> data;

  MoralisTransactionResponse({
    required this.status,
    required this.data,
  });

  factory MoralisTransactionResponse.fromJson(Map<String, dynamic> json) =>
      MoralisTransactionResponse(
        status: json["status"],
        data: List<MoralisTransaction>.from(
            json["data"].map((x) => MoralisTransaction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class MoralisTransaction {
  String from;
  String to;
  String nonce;
  String data;
  String value;
  String hash;
  String chain;
  String gas;
  String gasPrice;
  int index;
  String blockNumber;
  String blockHash;
  String blockTimestamp;
  String cumulativeGasUsed;
  String gasUsed;
  int receiptStatus;

  MoralisTransaction({
    required this.from,
    required this.to,
    required this.nonce,
    required this.data,
    required this.value,
    required this.hash,
    required this.chain,
    required this.gas,
    required this.gasPrice,
    required this.index,
    required this.blockNumber,
    required this.blockHash,
    required this.blockTimestamp,
    required this.cumulativeGasUsed,
    required this.gasUsed,
    required this.receiptStatus,
  });

  factory MoralisTransaction.fromJson(Map<String, dynamic> json) =>
      MoralisTransaction(
        from: json["from"],
        to: json["to"],
        nonce: json["nonce"],
        data: json["data"],
        value: json["value"],
        hash: json["hash"],
        chain: json["chain"],
        gas: json["gas"],
        gasPrice: json["gasPrice"],
        index: json["index"],
        blockNumber: json["blockNumber"],
        blockHash: json["blockHash"],
        blockTimestamp: json["blockTimestamp"],
        cumulativeGasUsed: json["cumulativeGasUsed"],
        gasUsed: json["gasUsed"],
        receiptStatus: json["receiptStatus"],
      );

  Map<String, dynamic> toJson() => {
        "from": from,
        "to": to,
        "nonce": nonce,
        "data": data,
        "value": value,
        "hash": hash,
        "chain": chain,
        "gas": gas,
        "gasPrice": gasPrice,
        "index": index,
        "blockNumber": blockNumber,
        "blockHash": blockHash,
        "blockTimestamp": blockTimestamp,
        "cumulativeGasUsed": cumulativeGasUsed,
        "gasUsed": gasUsed,
        "receiptStatus": receiptStatus,
      };
}
