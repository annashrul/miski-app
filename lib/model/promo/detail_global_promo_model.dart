// To parse this JSON data, do
//
//     final detailGlobalPromoModel = detailGlobalPromoModelFromJson(jsonString);

import 'dart:convert';

DetailGlobalPromoModel detailGlobalPromoModelFromJson(String str) => DetailGlobalPromoModel.fromJson(json.decode(str));

String detailGlobalPromoModelToJson(DetailGlobalPromoModel data) => json.encode(data.toJson());

class DetailGlobalPromoModel {
  DetailGlobalPromoModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory DetailGlobalPromoModel.fromJson(Map<String, dynamic> json) => DetailGlobalPromoModel(
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
    this.deskripsi,
    this.kode,
    this.maxUses,
    this.maxUsesUser,
    this.minTrx,
    this.maxDisc,
    this.disc1,
    this.disc2,
    this.isFixed,
    this.isVoucher,
    this.type,
    this.idBrand,
    this.brand,
    this.kelompok,
    this.idKelompok,
    this.periodeStart,
    this.periodeEnd,
    this.status,
    this.idTenant,
    this.gambar,
    this.createdAt,
    this.updatedAt,
    this.detail,
  });

  String id;
  String title;
  String deskripsi;
  String kode;
  int maxUses;
  int maxUsesUser;
  String minTrx;
  String maxDisc;
  int disc1;
  int disc2;
  int isFixed;
  int isVoucher;
  int type;
  String idBrand;
  String brand;
  String kelompok;
  String idKelompok;
  DateTime periodeStart;
  DateTime periodeEnd;
  int status;
  String idTenant;
  String gambar;
  DateTime createdAt;
  DateTime updatedAt;
  List<Detail> detail;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    title: json["title"],
    deskripsi: json["deskripsi"],
    kode: json["kode"],
    maxUses: json["max_uses"],
    maxUsesUser: json["max_uses_user"],
    minTrx: json["min_trx"],
    maxDisc: json["max_disc"],
    disc1: json["disc1"],
    disc2: json["disc2"],
    isFixed: json["is_fixed"],
    isVoucher: json["is_voucher"],
    type: json["type"],
    idBrand: json["id_brand"],
    brand: json["brand"],
    kelompok: json["kelompok"],
    idKelompok: json["id_kelompok"],
    periodeStart: DateTime.parse(json["periode_start"]),
    periodeEnd: DateTime.parse(json["periode_end"]),
    status: json["status"],
    idTenant: json["id_tenant"],
    gambar: json["gambar"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    detail: List<Detail>.from(json["detail"].map((x) => Detail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "deskripsi": deskripsi,
    "kode": kode,
    "max_uses": maxUses,
    "max_uses_user": maxUsesUser,
    "min_trx": minTrx,
    "max_disc": maxDisc,
    "disc1": disc1,
    "disc2": disc2,
    "is_fixed": isFixed,
    "is_voucher": isVoucher,
    "type": type,
    "id_brand": idBrand,
    "brand": brand,
    "kelompok": kelompok,
    "id_kelompok": idKelompok,
    "periode_start": periodeStart.toIso8601String(),
    "periode_end": periodeEnd.toIso8601String(),
    "status": status,
    "id_tenant": idTenant,
    "gambar": gambar,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "detail": List<dynamic>.from(detail.map((x) => x.toJson())),
  };
}

class Detail {
  Detail({
    this.id,
    this.idPromo,
    this.kodeBarang,
    this.barang,
    this.disc1,
    this.disc2,
    this.gambar,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String idPromo;
  String kodeBarang;
  dynamic barang;
  int disc1;
  int disc2;
  String gambar;
  DateTime createdAt;
  DateTime updatedAt;

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    idPromo: json["id_promo"],
    kodeBarang: json["kode_barang"],
    barang: json["barang"],
    disc1: json["disc1"],
    disc2: json["disc2"],
    gambar: json["gambar"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_promo": idPromo,
    "kode_barang": kodeBarang,
    "barang": barang,
    "disc1": disc1,
    "disc2": disc2,
    "gambar": gambar,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
