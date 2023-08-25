import 'dart:convert';

List<PriceResponse> priceResponseFromJson(String str) =>
    List<PriceResponse>.from(
        json.decode(str).map((x) => PriceResponse.fromJson(x)));

String priceResponseToJson(List<PriceResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PriceResponse {
  PriceResponse({
    required this.currentPrice,
    required this.symbol,
    required this.image
  });

  double currentPrice;
  String symbol;
  String image;

  factory PriceResponse.fromJson(Map<String, dynamic> json) => PriceResponse(
        currentPrice: json["current_price"].toDouble(),
        symbol: json["symbol"].toString(),
        image: json["image"].toString()
      );

  Map<String, dynamic> toJson() => {
        "current_price": currentPrice,
        "symbol": symbol,
        "image": image
      };
}
