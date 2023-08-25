import 'dart:convert';

GasPriceResponse gasPriceResponseFromJson(String str) =>
    GasPriceResponse.fromJson(json.decode(str));

String gasPriceResponseToJson(GasPriceResponse data) =>
    json.encode(data.toJson());

class GasPriceResponse {
  GasPriceResponse({
    required this.status,
    required this.message,
    required this.result,
  });

  String status;
  String message;
  Result result;

  factory GasPriceResponse.fromJson(Map<String, dynamic> json) =>
      GasPriceResponse(
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

  int lastBlock;
  int safeGasPrice;
  int proposeGasPrice;
  int fastGasPrice;
  double suggestBaseFee;
  String gasUsedRatio;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        lastBlock: int.parse(json["LastBlock"]),
        safeGasPrice: int.parse(json["SafeGasPrice"]),
        proposeGasPrice: int.parse(json["ProposeGasPrice"]),
        fastGasPrice: int.parse(json["FastGasPrice"]),
        suggestBaseFee: double.parse(json["suggestBaseFee"]),
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
