// To parse this JSON data, do
//
//     final detailProductTenantModel = detailProductTenantModelFromJson(jsonString);

import 'dart:convert';

DetailProductTenantModel detailProductTenantModelFromJson(String str) => DetailProductTenantModel.fromJson(json.decode(str));

String detailProductTenantModelToJson(DetailProductTenantModel data) => json.encode(data.toJson());

class DetailProductTenantModel {
  DetailProductTenantModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory DetailProductTenantModel.fromJson(Map<String, dynamic> json) => DetailProductTenantModel(
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
    this.stock,
    this.stockSales,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.listImage,
    this.varian,
    this.hargaBertingkat,
    this.review,
    this.disc1,
    this.disc2,
  });

  String id;
  String idTenant;
  String kode;
  String title;
  String tenant;
  String idKelompok;
  String kelompok;
  String idBrand;
  dynamic brand;
  String deskripsi;
  String harga;
  String hargaCoret;
  int berat;
  int preOrder;
  int freeReturn;
  String gambar;
  String stock;
  String stockSales;
  String rating;
  DateTime createdAt;
  DateTime updatedAt;
  List<ListImage> listImage;
  List<Varian> varian;
  List<HargaBertingkat> hargaBertingkat;
  List<Review> review;
  String disc1;
  String disc2;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
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
    stock: json["stock"],
    stockSales: json["stock_sales"],
    rating: json["rating"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    listImage: List<ListImage>.from(json["list_image"].map((x) => ListImage.fromJson(x))),
    varian: List<Varian>.from(json["varian"].map((x) => Varian.fromJson(x))),
    hargaBertingkat: List<HargaBertingkat>.from(json["harga_bertingkat"].map((x) => HargaBertingkat.fromJson(x))),
    review: List<Review>.from(json["review"].map((x) => Review.fromJson(x))),
    disc1: json["disc1"],
    disc2: json["disc2"],
  );

  Map<String, dynamic> toJson() => {
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
    "stock": stock,
    "stock_sales": stockSales,
    "rating": rating,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "list_image": List<dynamic>.from(listImage.map((x) => x.toJson())),
    "varian": List<dynamic>.from(varian.map((x) => x.toJson())),
    "harga_bertingkat": List<dynamic>.from(hargaBertingkat.map((x) => x.toJson())),
    "review": List<dynamic>.from(review.map((x) => x.toJson())),
    "disc1": disc1,
    "disc2": disc2,
  };
}

class HargaBertingkat {
  HargaBertingkat({
    this.id,
    this.idBarang,
    this.dari,
    this.sampai,
    this.harga,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String idBarang;
  int dari;
  int sampai;
  String harga;
  DateTime createdAt;
  DateTime updatedAt;

  factory HargaBertingkat.fromJson(Map<String, dynamic> json) => HargaBertingkat(
    id: json["id"],
    idBarang: json["id_barang"],
    dari: json["dari"],
    sampai: json["sampai"],
    harga: json["harga"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_barang": idBarang,
    "dari": dari,
    "sampai": sampai,
    "harga": harga,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class ListImage {
  ListImage({
    this.id,
    this.idBarang,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String idBarang;
  String image;
  DateTime createdAt;
  DateTime updatedAt;

  factory ListImage.fromJson(Map<String, dynamic> json) => ListImage(
    id: json["id"],
    idBarang: json["id_barang"],
    image: json["image"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_barang": idBarang,
    "image": image,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Review {
  Review({
    this.id,
    this.idMember,
    this.kdBrg,
    this.nama,
    this.caption,
    this.rate,
    this.foto,
    this.jumlahReview,
    this.time,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String idMember;
  String kdBrg;
  String nama;
  String caption;
  String rate;
  String foto;
  String jumlahReview;
  String time;
  DateTime createdAt;
  DateTime updatedAt;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json["id"],
    idMember: json["id_member"],
    kdBrg: json["kd_brg"],
    nama: json["nama"],
    caption: json["caption"],
    rate: json["rate"],
    foto: json["foto"],
    jumlahReview: json["jumlah_review"],
    time: json["time"],
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
    "jumlah_review": jumlahReview,
    "time": time,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Varian {
  Varian({
    this.id,
    this.idBarang,
    this.title,
    this.harga,
    this.stock,
    this.createdAt,
    this.updatedAt,
    this.subVarian,
    this.idVarian,
  });

  String id;
  String idBarang;
  String title;
  String harga;
  String stock;
  DateTime createdAt;
  DateTime updatedAt;
  List<Varian> subVarian;
  String idVarian;

  factory Varian.fromJson(Map<String, dynamic> json) => Varian(
    id: json["id"],
    idBarang: json["id_barang"] == null ? null : json["id_barang"],
    title: json["title"],
    harga: json["harga"],
    stock: json["stock"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    subVarian: json["sub_varian"] == null ? null : List<Varian>.from(json["sub_varian"].map((x) => Varian.fromJson(x))),
    idVarian: json["id_varian"] == null ? null : json["id_varian"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_barang": idBarang == null ? null : idBarang,
    "title": title,
    "harga": harga,
    "stock": stock,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
    "sub_varian": subVarian == null ? null : List<dynamic>.from(subVarian.map((x) => x.toJson())),
    "id_varian": idVarian == null ? null : idVarian,
  };
}
