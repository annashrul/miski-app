// To parse this JSON data, do
//
//     final kotaModel = kotaModelFromJson(jsonString);

import 'dart:convert';

KotaModel kotaModelFromJson(String str) => KotaModel.fromJson(json.decode(str));

String kotaModelToJson(KotaModel data) => json.encode(data.toJson());

class KotaModel {
  KotaModel({
    this.result,
    this.msg,
    this.status,
  });

  List<Result> result;
  String msg;
  String status;

  factory KotaModel.fromJson(Map<String, dynamic> json) => KotaModel(
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
    this.provinsi,
    this.name,
    this.postalCode,
  });

  String id;
  String provinsi;
  String name;
  String postalCode;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    provinsi: json["provinsi"],
    name: json["name"],
    postalCode: json["postal_code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "provinsi": provinsi,
    "name": name,
    "postal_code": postalCode,
  };
}
