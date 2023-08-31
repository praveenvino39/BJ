import 'package:flutter/material.dart';

class Network {
  String networkName;
  String url;
  String currency;
  String addressViewUrl;
  String transactionViewUrl;
  Color dotColor;
  int chainId;
  String wrappedTokenAddress;
  String etherscanApiBaseUrl;
  bool isMainnet;
  String symbol;
  String apiKey;
  String logo;
  String priceId;
  bool supportsEip1559;
  String nameSpace;

  Network(
      {required this.networkName,
      required this.url,
      required this.isMainnet,
      required this.currency,
      required this.chainId,
      required this.wrappedTokenAddress,
      required this.addressViewUrl,
      required this.transactionViewUrl,
      required this.etherscanApiBaseUrl,
      required this.dotColor,
      required this.apiKey,
      required this.priceId,
      required this.logo,
      required this.symbol,
      this.supportsEip1559 = false,
      required this.nameSpace});
}
