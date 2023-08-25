// To parse this JSON data, do
//
//     final transactionLogResult = transactionLogResultFromJson(jsonString);

import 'dart:convert';

TransactionLogResult transactionLogResultFromJson(String str) =>
    TransactionLogResult.fromJson(json.decode(str));

String transactionLogResultToJson(TransactionLogResult data) =>
    json.encode(data.toJson());

class TransactionLogResult {
  TransactionLogResult({
    required this.status,
    required this.message,
    required this.result,
  });

  String status;
  String message;
  List<TransactionResult> result;

  factory TransactionLogResult.fromJson(Map<String, dynamic> json) =>
      TransactionLogResult(
        status: json["status"],
        message: json["message"],
        result:
            List<TransactionResult>.from(json["result"].map((x) => TransactionResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class TransactionResult {
  TransactionResult({
    required this.blockNumber,
    required this.timeStamp,
    required this.hash,
    required this.nonce,
    required this.blockHash,
    required this.transactionIndex,
    required this.from,
    required this.to,
    required this.value,
    required this.gas,
    required this.gasPrice,
    required this.isError,
    required this.txreceiptStatus,
    required this.input,
    required this.contractAddress,
    required this.cumulativeGasUsed,
    required this.gasUsed,
    required this.confirmations,
    this.methodId,
    this.functionName,
  });

  String blockNumber;
  String timeStamp;
  String hash;
  String nonce;
  String blockHash;
  String transactionIndex;
  String from;
  String to;
  String value;
  String gas;
  String gasPrice;
  String isError;
  String txreceiptStatus;
  String input;
  String contractAddress;
  String cumulativeGasUsed;
  String gasUsed;
  String confirmations;
  String? methodId;
  String? functionName;

  factory TransactionResult.fromJson(Map<String, dynamic> json) => TransactionResult(
        blockNumber: json["blockNumber"],
        timeStamp: json["timeStamp"],
        hash: json["hash"],
        nonce: json["nonce"],
        blockHash: json["blockHash"],
        transactionIndex: json["transactionIndex"],
        from: json["from"],
        to: json["to"],
        value: json["value"],
        gas: json["gas"],
        gasPrice: json["gasPrice"],
        isError: json["isError"],
        txreceiptStatus: json["txreceipt_status"],
        input: json["input"],
        contractAddress: json["contractAddress"],
        cumulativeGasUsed: json["cumulativeGasUsed"],
        gasUsed: json["gasUsed"],
        confirmations: json["confirmations"],
        methodId: json["methodId"],
        functionName: json["functionName"],
      );

  Map<String, dynamic> toJson() => {
        "blockNumber": blockNumber,
        "timeStamp": timeStamp,
        "hash": hash,
        "nonce": nonce,
        "blockHash": blockHash,
        "transactionIndex": transactionIndex,
        "from": from,
        "to": to,
        "value": value,
        "gas": gas,
        "gasPrice": gasPrice,
        "isError": isError,
        "txreceipt_status": txreceiptStatus,
        "input": input,
        "contractAddress": contractAddress,
        "cumulativeGasUsed": cumulativeGasUsed,
        "gasUsed": gasUsed,
        "confirmations": confirmations,
        "methodId": methodId,
        "functionName": functionName,
      };
}
