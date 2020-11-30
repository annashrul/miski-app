// To parse this JSON data, do
//
//     final kecamatanModel = kecamatanModelFromJson(jsonString);

import 'dart:convert';

KecamatanModel kecamatanModelFromJson(String str) => KecamatanModel.fromJson(json.decode(str));

String kecamatanModelToJson(KecamatanModel data) => json.encode(data.toJson());

class KecamatanModel {
  KecamatanModel({
    this.result,
    this.msg,
    this.status,
  });

  List<Result> result;
  String msg;
  String status;

  factory KecamatanModel.fromJson(Map<String, dynamic> json) => KecamatanModel(
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
    this.kota,
    this.kecamatan,
  });

  String id;
  String kota;
  String kecamatan;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    kota: json["kota"],
    kecamatan: json["kecamatan"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "kota": kota,
    "kecamatan": kecamatan,
  };
}
