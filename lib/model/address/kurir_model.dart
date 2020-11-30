// To parse this JSON data, do
//
//     final kurirModel = kurirModelFromJson(jsonString);

import 'dart:convert';

KurirModel kurirModelFromJson(String str) => KurirModel.fromJson(json.decode(str));

String kurirModelToJson(KurirModel data) => json.encode(data.toJson());

class KurirModel {
  KurirModel({
    this.result,
    this.msg,
    this.status,
  });

  List<Result> result;
  String msg;
  String status;

  factory KurirModel.fromJson(Map<String, dynamic> json) => KurirModel(
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
    this.title,
    this.kurir,
    this.deskripsi,
    this.gambar,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String title;
  String kurir;
  String deskripsi;
  String gambar;
  int status;
  DateTime createdAt;
  DateTime updatedAt;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    title: json["title"],
    kurir: json["kurir"],
    deskripsi: json["deskripsi"],
    gambar: json["gambar"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "kurir": kurir,
    "deskripsi": deskripsi,
    "gambar": gambar,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
