// To parse this JSON data, do
//
//     final hargaBertingkatModel = hargaBertingkatModelFromJson(jsonString);

import 'dart:convert';

HargaBertingkatModel hargaBertingkatModelFromJson(String str) => HargaBertingkatModel.fromJson(json.decode(str));

String hargaBertingkatModelToJson(HargaBertingkatModel data) => json.encode(data.toJson());

class HargaBertingkatModel {
  HargaBertingkatModel({
    this.result,
    this.msg,
    this.status,
  });

  List<Result> result;
  String msg;
  String status;

  factory HargaBertingkatModel.fromJson(Map<String, dynamic> json) => HargaBertingkatModel(
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
    this.idBarang,
    this.dari,
    this.sampai,
    this.harga,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String idBarang;
  int dari;
  int sampai;
  String harga;
  DateTime createdAt;
  DateTime updatedAt;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    idBarang: json["id_barang"],
    dari: json["dari"],
    sampai: json["sampai"],
    harga: json["harga"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_barang": idBarang,
    "dari": dari,
    "sampai": sampai,
    "harga": harga,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
