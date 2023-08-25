import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'token_model.g.dart';

Token tokenFromJson(String str) => Token.fromJson(json.decode(str));

String tokenToJson(Token data) => json.encode(data.toJson());

@HiveType(typeId: 0)
class Token extends HiveObject with EquatableMixin {
  Token({
    required this.tokenAddress,
    required this.symbol,
    required this.decimal,
    required this.balance,
    required this.balanceInFiat,
    this.imageUrl,
    this.coinGeckoID
  });

  @HiveField(0)
  String tokenAddress;

  @HiveField(1)
  String symbol;

  @HiveField(2)
  int decimal;

  @HiveField(3)
  double balance;

  @HiveField(4)
  double balanceInFiat;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  String? coinGeckoID;


  factory Token.fromJson(Map<String, dynamic> json) => Token(
        tokenAddress: json["tokenAddress"],
        symbol: json["symbol"],
        decimal: json["decimal"],
        balance:
            Decimal.fromInt(jsonDecode(json["balance"]).toInt()).toDouble(),
        balanceInFiat: json["balanceInFiat"],
        imageUrl: json["imageUrl"],
        coinGeckoID: json["coinGeckoID"]
      );
  Map<String, dynamic> toJson() => {
        "tokenAddress": tokenAddress,
        "symbol": symbol,
        "decimal": decimal,
        "balance": balance,
        "balanceInFiat": balanceInFiat,
        "imageUrl": imageUrl,
        "coinGeckoID": coinGeckoID
      };

  @override
  List<Object?> get props => [tokenAddress];
}
