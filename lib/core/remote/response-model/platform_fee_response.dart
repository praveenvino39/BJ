// To parse this JSON data, do
//
//     final platformFeeResponse = platformFeeResponseFromJson(jsonString);

import 'dart:convert';

PlatformFeeResponse platformFeeResponseFromJson(String str) =>
    PlatformFeeResponse.fromJson(json.decode(str));

String platformFeeResponseToJson(PlatformFeeResponse data) =>
    json.encode(data.toJson());

class PlatformFeeResponse {
  String status;
  PlatformFeeData data;

  PlatformFeeResponse({
    required this.status,
    required this.data,
  });

  factory PlatformFeeResponse.fromJson(Map<String, dynamic> json) =>
      PlatformFeeResponse(
        status: json["status"],
        data: PlatformFeeData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class PlatformFeeData {
  double fee;
  String adminAddress;

  PlatformFeeData({
    required this.fee,
    required this.adminAddress,
  });

  factory PlatformFeeData.fromJson(Map<String, dynamic> json) =>
      PlatformFeeData(
        fee: double.parse(json["fee"].toString()),
        adminAddress: json["adminAddress"],
      );

  Map<String, dynamic> toJson() => {
        "fee": fee,
        "adminAddress": adminAddress,
      };
}
