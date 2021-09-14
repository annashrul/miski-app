// To parse this JSON data, do
//
//     final listProductTenantModel = listProductTenantModelFromJson(jsonString);

import 'dart:convert';

ListProductTenantModel listProductTenantModelFromJson(String str) => ListProductTenantModel.fromJson(json.decode(str));

String listProductTenantModelToJson(ListProductTenantModel data) => json.encode(data.toJson());

class ListProductTenantModel {
  ListProductTenantModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ListProductTenantModel.fromJson(Map<String, dynamic> json) => ListProductTenantModel(
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
    this.perPage,
    this.offset,
    this.to,
    this.lastPage,
    this.currentPage,
    this.from,
    this.data,
  });

  int total;
  int perPage;
  int offset;
  int to;
  int lastPage;
  int currentPage;
  int from;
  List<Datum> data;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    total: json["total"],
    perPage: json["per_page"],
    offset: json["offset"],
    to: json["to"],
    lastPage: json["last_page"],
    currentPage: json["current_page"],
    from: json["from"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "per_page": perPage,
    "offset": offset,
    "to": to,
    "last_page": lastPage,
    "current_page": currentPage,
    "from": from,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.totalrecords,
    this.id,
    this.idTenant,
    this.kode,
    this.title,
    this.tenant,
    this.idKelompok,
    this.kelompok,
    this.idBrand,
    this.brand,
    this.deskripsi,
    this.harga,
    this.hargaCoret,
    this.berat,
    this.preOrder,
    this.freeReturn,
    this.gambar,
    this.disc1,
    this.disc2,
    this.stock,
    this.stockSales,
    this.rating,
    this.createdAt,
    this.updatedAt,
  });

  dynamic totalrecords;
  dynamic id;
  dynamic idTenant;
  dynamic kode;
  dynamic title;
  dynamic tenant;
  dynamic idKelompok;
  dynamic kelompok;
  dynamic idBrand;
  dynamic brand;
  dynamic deskripsi;
  dynamic harga;
  dynamic hargaCoret;
  dynamic berat;
  dynamic preOrder;
  dynamic freeReturn;
  dynamic gambar;
  dynamic disc1;
  dynamic disc2;
  dynamic stock;
  dynamic stockSales;
  dynamic rating;
  DateTime createdAt;
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    totalrecords: json["totalrecords"],
    id: json["id"],
    idTenant: json["id_tenant"],
    kode: json["kode"],
    title: json["title"],
    tenant: json["tenant"],
    idKelompok: json["id_kelompok"],
    kelompok: json["kelompok"],
    idBrand: json["id_brand"],
    brand: json["brand"],
    deskripsi: json["deskripsi"],
    harga: json["harga"],
    hargaCoret: json["harga_coret"],
    berat: json["berat"],
    preOrder: json["pre_order"],
    freeReturn: json["free_return"],
    gambar: json["gambar"],
    disc1: json["disc1"],
    disc2: json["disc2"],
    stock: json["stock"],
    stockSales: json["stock_sales"],
    rating: json["rating"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "totalrecords": totalrecords,
    "id": id,
    "id_tenant": idTenant,
    "kode": kode,
    "title": title,
    "tenant": tenant,
    "id_kelompok": idKelompok,
    "kelompok": kelompok,
    "id_brand": idBrand,
    "brand": brand,
    "deskripsi": deskripsi,
    "harga": harga,
    "harga_coret": hargaCoret,
    "berat": berat,
    "pre_order": preOrder,
    "free_return": freeReturn,
    "gambar": gambar,
    "disc1": disc1,
    "disc2": disc2,
    "stock": stock,
    "stock_sales": stockSales,
    "rating": rating,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
