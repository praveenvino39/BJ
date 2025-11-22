import 'package:flutter/material.dart';

class Network {
  String networkName;
  String url;
  String addressViewUrl;
  String transactionViewUrl;
  Color dotColor;
  int chainId;
  bool isMainnet;
  String symbol;
  String logo;
  String nameSpace;

  Network(
      {required this.networkName,
      required this.url,
      required this.isMainnet,
      required this.chainId,
      required this.addressViewUrl,
      required this.transactionViewUrl,
      required this.dotColor,
      required this.logo,
      required this.symbol,
      required this.nameSpace});

  factory Network.fromJson(Map<String, dynamic> json) => Network(
        networkName: json["networkName"],
        url: json["url"],
        isMainnet: json["isMainnet"],
        chainId: json["chainId"],
        addressViewUrl: json["addressViewUrl"],
        transactionViewUrl: json["transactionViewUrl"],
        dotColor: Color(int.parse(json["dotColor"])),
        logo: json["logo"],
        symbol: json["symbol"],
        nameSpace: json["nameSpace"],
      );

  Map<String, dynamic> toJson() => {
        "networkName": networkName,
        "url": url,
        "isMainnet": isMainnet,
        "chainId": chainId,
        "addressViewUrl": addressViewUrl,
        "transactionViewUrl": transactionViewUrl,
        "dotColor": dotColor.value.toString(),
        "logo": logo,
        "symbol": symbol,
        "nameSpace": nameSpace,
      };
}
