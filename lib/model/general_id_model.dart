// To parse this JSON data, do
//
//     final generalIdModel = generalIdModelFromJson(jsonString);

import 'dart:convert';

GeneralIdModel generalIdModelFromJson(String str) => GeneralIdModel.fromJson(json.decode(str));

String generalIdModelToJson(GeneralIdModel data) => json.encode(data.toJson());

class GeneralIdModel {
  GeneralIdModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory GeneralIdModel.fromJson(Map<String, dynamic> json) => GeneralIdModel(
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
    this.insertId,
  });

  String insertId;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    insertId: json["insertId"],
  );

  Map<String, dynamic> toJson() => {
    "insertId": insertId,
  };
}
