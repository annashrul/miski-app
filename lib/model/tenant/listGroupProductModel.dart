// To parse this JSON data, do
//
//     final listGroupProductModel = listGroupProductModelFromJson(jsonString);

import 'dart:convert';

ListGroupProductModel listGroupProductModelFromJson(String str) => ListGroupProductModel.fromJson(json.decode(str));

String listGroupProductModelToJson(ListGroupProductModel data) => json.encode(data.toJson());

class ListGroupProductModel {
  ListGroupProductModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ListGroupProductModel.fromJson(Map<String, dynamic> json) => ListGroupProductModel(
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
    this.idKategori,
    this.kategori,
    this.status,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String title;
  String idKategori;
  String kategori;
  int status;
  String image;
  DateTime createdAt;
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    title: json["title"],
    idKategori: json["id_kategori"],
    kategori: json["kategori"],
    status: json["status"],
    image: json["image"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "id_kategori": idKategori,
    "kategori": kategori,
    "status": status,
    "image": image,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
