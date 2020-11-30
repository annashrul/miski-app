// To parse this JSON data, do
//
//     final reviewModel = reviewModelFromJson(jsonString);

import 'dart:convert';

ReviewModel reviewModelFromJson(String str) => ReviewModel.fromJson(json.decode(str));

String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

class ReviewModel {
  ReviewModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
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

  int total;
  int lastPage;
  int perPage;
  int currentPage;
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
    this.kdBrg,
    this.nama,
    this.caption,
    this.rate,
    this.foto,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String idMember;
  String kdBrg;
  String nama;
  String caption;
  double rate;
  String foto;
  DateTime createdAt;
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    idMember: json["id_member"],
    kdBrg: json["kd_brg"],
    nama: json["nama"],
    caption: json["caption"],
    rate: json["rate"].toDouble(),
    foto: json["foto"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_member": idMember,
    "kd_brg": kdBrg,
    "nama": nama,
    "caption": caption,
    "rate": rate,
    "foto": foto,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
