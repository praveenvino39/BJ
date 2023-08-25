import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'collectible_model.g.dart';



Collectible collectibleFromJson(String str) =>
    Collectible.fromJson(json.decode(str));

String collectibleToJson(Collectible data) => json.encode(data.toJson());

@HiveType(typeId: 1)

class Collectible extends HiveObject with EquatableMixin {
  Collectible({
    required this.tokenAddress,
    required this.name,
    required this.tokenId,
    required this.description,
    this.imageUrl,
  });

  @HiveField(0)
  String tokenAddress;

  @HiveField(1)
  String name;

  @HiveField(2)
  String tokenId;

  @HiveField(3)
  String? imageUrl;

  @HiveField(4)
  String? description;

  factory Collectible.fromJson(Map<String, dynamic> json) => Collectible(
      tokenAddress: json["tokenAddress"],
      name: json["name"],
      tokenId: json["tokenId"],
      imageUrl: json["imageUrl"],
      description: json["description"]);
  Map<String, dynamic> toJson() => {
        "tokenAddress": tokenAddress,
        "name": name,
        "tokenId": tokenId,
        "imageUrl": imageUrl,
        "description": description
      };

  @override
  List<String> get props => [tokenAddress, tokenId.toString()];
}
