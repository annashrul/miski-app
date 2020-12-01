// To parse this JSON data, do
//
//     final detailTicketModel = detailTicketModelFromJson(jsonString);

import 'dart:convert';

DetailTicketModel detailTicketModelFromJson(String str) => DetailTicketModel.fromJson(json.decode(str));

String detailTicketModelToJson(DetailTicketModel data) => json.encode(data.toJson());

class DetailTicketModel {
  DetailTicketModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory DetailTicketModel.fromJson(Map<String, dynamic> json) => DetailTicketModel(
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
    this.title,
    this.idMember,
    this.member,
    this.deskripsi,
    this.lampiran,
    this.layanan,
    this.prioritas,
    this.status,
    this.oneSignalId,
    this.idTenant,
    this.tenant,
    this.createdAt,
    this.updatedAt,
    this.detail,
  });

  String id;
  String title;
  String idMember;
  String member;
  String deskripsi;
  String lampiran;
  String layanan;
  int prioritas;
  int status;
  String oneSignalId;
  String idTenant;
  String tenant;
  DateTime createdAt;
  DateTime updatedAt;
  List<Detail> detail;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    title: json["title"],
    idMember: json["id_member"],
    member: json["member"],
    deskripsi: json["deskripsi"],
    lampiran: json["lampiran"],
    layanan: json["layanan"],
    prioritas: json["prioritas"],
    status: json["status"],
    oneSignalId: json["one_signal_id"],
    idTenant: json["id_tenant"],
    tenant: json["tenant"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    detail: List<Detail>.from(json["detail"].map((x) => Detail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "id_member": idMember,
    "member": member,
    "deskripsi": deskripsi,
    "lampiran": lampiran,
    "layanan": layanan,
    "prioritas": prioritas,
    "status": status,
    "one_signal_id": oneSignalId,
    "id_tenant": idTenant,
    "tenant": tenant,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "detail": List<dynamic>.from(detail.map((x) => x.toJson())),
  };
}

class Detail {
  Detail({
    this.id,
    this.idMaster,
    this.idMember,
    this.member,
    this.idUser,
    this.users,
    this.msg,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String idMaster;
  dynamic idMember;
  dynamic member;
  String idUser;
  String users;
  String msg;
  DateTime createdAt;
  DateTime updatedAt;

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    idMaster: json["id_master"],
    idMember: json["id_member"],
    member: json["member"],
    idUser: json["id_user"],
    users: json["users"],
    msg: json["msg"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_master": idMaster,
    "id_member": idMember,
    "member": member,
    "id_user": idUser,
    "users": users,
    "msg": msg,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
