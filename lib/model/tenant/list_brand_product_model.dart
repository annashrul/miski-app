// To parse this JSON data, do
//
//     final listBrandProductModel = listBrandProductModelFromJson(jsonString);

import 'dart:convert';

ListBrandProductModel listBrandProductModelFromJson(String str) => ListBrandProductModel.fromJson(json.decode(str));

String listBrandProductModelToJson(ListBrandProductModel data) => json.encode(data.toJson());

class ListBrandProductModel {
  ListBrandProductModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ListBrandProductModel.fromJson(Map<String, dynamic> json) => ListBrandProductModel(
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
    this.image,
    this.status,
    this.color,
    this.deskripsi,
    this.jumlahBarang,
    this.jumlahReview,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String title;
  String image;
  int status;
  String color;
  String deskripsi;
  String jumlahBarang;
  String jumlahReview;
  DateTime createdAt;
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    title: json["title"],
    image: json["image"],
    status: json["status"],
    color: json["color"],
    deskripsi: json["deskripsi"],
    jumlahBarang: json["jumlah_barang"],
    jumlahReview: json["jumlah_review"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image": image,
    "status": status,
    "color": color,
    "deskripsi": deskripsi,
    "jumlah_barang": jumlahBarang,
    "jumlah_review": jumlahReview,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
