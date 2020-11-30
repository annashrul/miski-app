// To parse this JSON data, do
//
//     final configAuthModel = configAuthModelFromJson(jsonString);

import 'dart:convert';

ConfigAuthModel configAuthModelFromJson(String str) => ConfigAuthModel.fromJson(json.decode(str));

String configAuthModelToJson(ConfigAuthModel data) => json.encode(data.toJson());

class ConfigAuthModel {
  ConfigAuthModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ConfigAuthModel.fromJson(Map<String, dynamic> json) => ConfigAuthModel(
    result: Result.fromJson(json["result"]),
    msg: json["msg"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "result": result.toJson(),
    "msg": msg,
    "status": status,
  };
}

class Result {
  Result({
    this.type,
  });

  String type;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
  };
}
