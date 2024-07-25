// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
  int id;
  int forId;
  String message;
  bool isAdminMessage;
  DateTime timestamp;
  bool seen;
  User user;

  Message({
    required this.id,
    required this.forId,
    required this.message,
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
        "isAdminMessage": isAdminMessage,
        "timestamp": timestamp.toIso8601String(),
        "user": user.toJson(),
        "seen": seen
      };
}
