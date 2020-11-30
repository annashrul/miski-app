// To parse this JSON data, do
//
//     final provinsiModel = provinsiModelFromJson(jsonString);

import 'dart:convert';

ProvinsiModel provinsiModelFromJson(String str) => ProvinsiModel.fromJson(json.decode(str));

String provinsiModelToJson(ProvinsiModel data) => json.encode(data.toJson());

class ProvinsiModel {
  ProvinsiModel({
    this.result,
    this.msg,
    this.status,
  });

  List<Result> result;
  String msg;
  String status;

  factory ProvinsiModel.fromJson(Map<String, dynamic> json) => ProvinsiModel(
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    msg: json["msg"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
    "msg": msg,
    "status": status,
  };
}

class Result {
  Result({
    this.id,
    this.name,
  });

  String id;
  String name;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
