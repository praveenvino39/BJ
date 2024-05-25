// To parse this JSON data, do
//
//     final settingsResponse = settingsResponseFromJson(jsonString);

import 'dart:convert';

SettingsResponse settingsResponseFromJson(String str) =>
    SettingsResponse.fromJson(json.decode(str));

String settingsResponseToJson(SettingsResponse data) =>
    json.encode(data.toJson());

class SettingsResponse {
  String status;
  Settings data;

  SettingsResponse({
    required this.status,
    required this.data,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) =>
      SettingsResponse(
        status: json["status"],
        data: Settings.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Settings {
  String helpUrl;
  String tcUrl;
  String ppUrl;
  String about;

  Settings({
    required this.helpUrl,
    required this.tcUrl,
    required this.ppUrl,
    required this.about,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        helpUrl: json["helpUrl"],
        tcUrl: json["tcUrl"],
        ppUrl: json["ppUrl"],
        about: json["about"],
      );

  Map<String, dynamic> toJson() => {
        "helpUrl": helpUrl,
        "tcUrl": tcUrl,
        "ppUrl": ppUrl,
        "about": about,
      };
}
