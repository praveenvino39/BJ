import 'dart:convert';

MoralisToken moralisTokenFromJson(String str) =>
    MoralisToken.fromJson(json.decode(str));

String moralisTokenToJson(MoralisToken data) => json.encode(data.toJson());

class MoralisToken {
  String tokenAddress;
  String symbol;
  String name;
  String? logo;
  int decimals;
  String balance;
  String balanceFormatted;
  double? usdPrice;
  double? usdValue;
  bool nativeToken;

  MoralisToken({
    required this.tokenAddress,
    required this.symbol,
    required this.name,
    required this.logo,
    required this.decimals,
    required this.balance,
    required this.balanceFormatted,
    required this.usdPrice,
    required this.usdValue,
    required this.nativeToken,
  });

  factory MoralisToken.fromJson(Map<String, dynamic> json) => MoralisToken(
        tokenAddress: json["token_address"],
        symbol: json["symbol"],
        name: json["name"],
        logo: json["logo"],
        decimals: json["decimals"],
        balance: json["balance"],
        balanceFormatted: json["balance_formatted"],
        usdPrice: json["usd_price"]?.toDouble(),
        usdValue: json["usd_value"]?.toDouble(),
        nativeToken: json["native_token"],
      );

  Map<String, dynamic> toJson() => {
        "token_address": tokenAddress,
        "symbol": symbol,
        "name": name,
        "logo": logo,
        "decimals": decimals,
        "balance": balance,
        "balance_formatted": balanceFormatted,
        "usd_price": usdPrice,
        "usd_value": usdValue,
        "native_token": nativeToken,
      };
}
