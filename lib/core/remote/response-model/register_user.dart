import 'dart:convert';

ResigterUserResponse createUserReponseFromJson(String str) =>
    ResigterUserResponse.fromJson(json.decode(str));

String createUserReponseToJson(ResigterUserResponse data) =>
    json.encode(data.toJson());

class ResigterUserResponse {
  String status;
  User data;

  ResigterUserResponse({
    required this.status,
    required this.data,
  });

  factory ResigterUserResponse.fromJson(Map<String, dynamic> json) =>
      ResigterUserResponse(
        status: json["status"],
        data: User.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class User {
  int id;
  String address;
  bool isDeactivated;
  bool isTransactionBlocked;
  bool seedPhraseBackedUp;
  String? token;
  List<dynamic> subAddress;

  User({
    required this.id,
    required this.address,
    required this.isDeactivated,
    required this.isTransactionBlocked,
    required this.seedPhraseBackedUp,
    required this.subAddress,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        address: json["address"],
        isDeactivated: json["isDeactivated"],
        isTransactionBlocked: json["isTransactionBlocked"],
        seedPhraseBackedUp: json["seedPhraseBackedUp"],
        token: json["token"],
        subAddress: json["subAddress"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "address": address,
        "isDeactivated": isDeactivated,
        "isTransactionBlocked": isTransactionBlocked,
        "seedPhraseBackedUp": seedPhraseBackedUp,
        "token": token,
        "subAddress": subAddress,
      };
}
