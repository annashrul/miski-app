// To parse this JSON data, do
//
//     final listAddressModel = listAddressModelFromJson(jsonString);

import 'dart:convert';

ListAddressModel listAddressModelFromJson(String str) => ListAddressModel.fromJson(json.decode(str));

String listAddressModelToJson(ListAddressModel data) => json.encode(data.toJson());

class ListAddressModel {
  ListAddressModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ListAddressModel.fromJson(Map<String, dynamic> json) => ListAddressModel(
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
    this.total,
    this.lastPage,
    this.perPage,
    this.currentPage,
    this.from,
    this.to,
    this.data,
  });

  String total;
  int lastPage;
  int perPage;
  String currentPage;
  int from;
  int to;
  List<Datum> data;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    total: json["total"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    currentPage: json["current_page"],
    from: json["from"],
    to: json["to"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "last_page": lastPage,
    "per_page": perPage,
    "current_page": currentPage,
    "from": from,
    "to": to,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
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
    this.updatedAt,
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
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
    updatedAt: DateTime.parse(json["updated_at"]),
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
    "updated_at": updatedAt.toIso8601String(),
  };
}
