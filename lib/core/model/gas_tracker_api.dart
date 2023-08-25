// To parse this JSON data, do
//
//     final gasTrackerResponse = gasTrackerResponseFromJson(jsonString);

import 'dart:convert';

GasTrackerResponse gasTrackerResponseFromJson(String str) => GasTrackerResponse.fromJson(json.decode(str));

String gasTrackerResponseToJson(GasTrackerResponse data) => json.encode(data.toJson());

class GasTrackerResponse {
    GasTrackerResponse({
        required this.status,
        required this.message,
        required this.result,
    });

    String status;
    String message;
    Result result;

    factory GasTrackerResponse.fromJson(Map<String, dynamic> json) => GasTrackerResponse(
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result.toJson(),
    };
}

class Result {
    Result({
        required this.lastBlock,
        required this.safeGasPrice,
        required this.proposeGasPrice,
        required this.fastGasPrice,
        required this.suggestBaseFee,
        required this.gasUsedRatio,
    });

    String lastBlock;
    String safeGasPrice;
    String proposeGasPrice;
    String fastGasPrice;
    String suggestBaseFee;
    String gasUsedRatio;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        lastBlock: json["LastBlock"],
        safeGasPrice: json["SafeGasPrice"],
        proposeGasPrice: json["ProposeGasPrice"],
        fastGasPrice: json["FastGasPrice"],
        suggestBaseFee: json["suggestBaseFee"],
        gasUsedRatio: json["gasUsedRatio"],
    );

    Map<String, dynamic> toJson() => {
        "LastBlock": lastBlock,
        "SafeGasPrice": safeGasPrice,
        "ProposeGasPrice": proposeGasPrice,
        "FastGasPrice": fastGasPrice,
        "suggestBaseFee": suggestBaseFee,
        "gasUsedRatio": gasUsedRatio,
    };
}
