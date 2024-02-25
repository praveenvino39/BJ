// To parse this JSON data, do
//
//     final promotions = promotionsFromJson(jsonString);

import 'dart:convert';

Promotions promotionsFromJson(String str) =>
    Promotions.fromJson(json.decode(str));

String promotionsToJson(Promotions data) => json.encode(data.toJson());

class Promotions {
  List<Promotion> data;

  Promotions({
    required this.data,
  });

  factory Promotions.fromJson(Map<String, dynamic> json) => Promotions(
        data: List<Promotion>.from(
            json["data"].map((x) => Promotion.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Promotion {
  int id;
  String title;
  String body;
  String image;
  String ctaUrl;
  bool openInDappBrowser;
  String ctaText;
  int? priorityIndex;

  Promotion({
    required this.id,
    required this.title,
    required this.ctaText,
    required this.body,
    required this.image,
    required this.openInDappBrowser,
    required this.ctaUrl,
    required this.priorityIndex,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json["id"],
        title: json["title"],
        body: json["body"],
        image: json["image"],
        ctaText: json["ctaText"],
        openInDappBrowser: json["openInDappBrowser"],
        ctaUrl: json["ctaUrl"],
        priorityIndex: json["priorityIndex"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "image": image,
        "ctaUrl": ctaUrl,
        "ctaText": ctaText,
        "openInDappBrowser": openInDappBrowser,
        "priorityIndex": priorityIndex,
      };
}
