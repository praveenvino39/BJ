// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'dart:convert';

import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
  int id;
  int forId;
  String message;
  Media? attachment;
  bool isAdminMessage;
  DateTime timestamp;
  bool seen;
  User user;

  Message({
    required this.id,
    required this.forId,
    required this.message,
    required this.attachment,
    required this.isAdminMessage,
    required this.timestamp,
    required this.user,
    required this.seen,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"],
      forId: json["forId"],
      message: json["message"],
      attachment: json["attachment"] != null
          ? Media.fromJson(json["attachment"])
          : null,
      isAdminMessage: json["isAdminMessage"],
      timestamp: DateTime.parse(json["timestamp"]),
      user: User.fromJson(json["for"]),
      seen: json["seen"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "forId": forId,
        "message": message,
        "attachmentLink": attachment?.toJson(),
        "isAdminMessage": isAdminMessage,
        "timestamp": timestamp.toIso8601String(),
        "user": user.toJson(),
        "seen": seen
      };
}

class Media {
  int? id;
  String url;
  String fileName;
  String mediaType;

  Media(
      {required this.id,
      required this.url,
      required this.fileName,
      required this.mediaType});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
        id: json["id"],
        fileName: json['fileName'],
        mediaType: json['mediaType'],
        url: json['url']);
  }

  Map<String, dynamic> toJson() =>
      {"id": id, "url": url, "fileName": fileName, "mediaType": mediaType};
}
