// To parse this JSON data, do
//
//     final listTicketModel = listTicketModelFromJson(jsonString);

import 'dart:convert';

ListTicketModel listTicketModelFromJson(String str) => ListTicketModel.fromJson(json.decode(str));

String listTicketModelToJson(ListTicketModel data) => json.encode(data.toJson());

class ListTicketModel {
  ListTicketModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ListTicketModel.fromJson(Map<String, dynamic> json) => ListTicketModel(
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

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
  };
}
