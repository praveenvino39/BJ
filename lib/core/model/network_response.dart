class Network {
  int id;
  String nameSpace;
  String networkName;
  String url;
  String symbol;
  int chainId;
  String logo;
  bool isMainnet;
  String addressViewUrl;
  String transactionViewUrl;
  String dotColor;
  bool enabled;

  Network({
    required this.id,
    required this.nameSpace,
    required this.networkName,
    required this.url,
    required this.symbol,
    required this.chainId,
    required this.logo,
    required this.isMainnet,
    required this.addressViewUrl,
    required this.transactionViewUrl,
    required this.dotColor,
    required this.enabled,
  });

  factory Network.fromJson(Map<String, dynamic> json) => Network(
        id: json["id"],
        nameSpace: json["nameSpace"],
        networkName: json["networkName"],
        url: json["url"],
        symbol: json["symbol"],
        chainId: json["chainId"],
        logo: json["logo"],
        isMainnet: json["isMainnet"],
        addressViewUrl: json["addressViewUrl"],
        transactionViewUrl: json["transactionViewUrl"],
        dotColor: json["dotColor"],
        enabled: json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nameSpace": nameSpace,
        "networkName": networkName,
        "url": url,
        "symbol": symbol,
        "chainId": chainId,
        "logo": logo,
        "isMainnet": isMainnet,
        "addressViewUrl": addressViewUrl,
        "transactionViewUrl": transactionViewUrl,
        "dotColor": dotColor,
        "enabled": enabled,
      };
}
