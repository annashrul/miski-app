// To parse this JSON data, do
//
//     final detailAddressModel = detailAddressModelFromJson(jsonString);

import 'dart:convert';

DetailAddressModel detailAddressModelFromJson(String str) => DetailAddressModel.fromJson(json.decode(str));

String detailAddressModelToJson(DetailAddressModel data) => json.encode(data.toJson());

class DetailAddressModel {
  DetailAddressModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory DetailAddressModel.fromJson(Map<String, dynamic> json) => DetailAddressModel(
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
    this.id,
    this.idMember,
    this.title,
    this.penerima,
    this.mainAddress,
    this.kdProv,
    this.kdKota,
    this.kdKec,
    this.noHp,
    this.ismain,
    this.createdAt,
    this.kecamatan,
    this.kota,
    this.provinsi,
  });

  String id;
  String idMember;
  String title;
  String penerima;
  String mainAddress;
  String kdProv;
  String kdKota;
  String kdKec;
  String noHp;
  int ismain;
  DateTime createdAt;
  String kecamatan;
  String kota;
  String provinsi;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    idMember: json["id_member"],
    title: json["title"],
    penerima: json["penerima"],
    mainAddress: json["main_address"],
    kdProv: json["kd_prov"],
    kdKota: json["kd_kota"],
    kdKec: json["kd_kec"],
    noHp: json["no_hp"],
    ismain: json["ismain"],
    createdAt: DateTime.parse(json["created_at"]),
    kecamatan: json["kecamatan"],
    kota: json["kota"],
    provinsi: json["provinsi"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_member": idMember,
    "title": title,
    "penerima": penerima,
    "main_address": mainAddress,
    "kd_prov": kdProv,
    "kd_kota": kdKota,
    "kd_kec": kdKec,
    "no_hp": noHp,
    "ismain": ismain,
    "created_at": createdAt.toIso8601String(),
    "kecamatan": kecamatan,
    "kota": kota,
    "provinsi": provinsi,
  };
}
