// To parse this JSON data, do
//
//     final globalPromoModel = globalPromoModelFromJson(jsonString);

import 'dart:convert';

GlobalPromoModel globalPromoModelFromJson(String str) => GlobalPromoModel.fromJson(json.decode(str));

String globalPromoModelToJson(GlobalPromoModel data) => json.encode(data.toJson());

class GlobalPromoModel {
  GlobalPromoModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory GlobalPromoModel.fromJson(Map<String, dynamic> json) => GlobalPromoModel(
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
    this.idKelompok,
    this.periodeStart,
    this.periodeEnd,
    this.status,
    this.idTenant,
    this.gambar,
    this.createdAt,
    this.updatedAt,
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
  String idKelompok;
  DateTime periodeStart;
  DateTime periodeEnd;
  int status;
  String idTenant;
  String gambar;
  DateTime createdAt;
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
    idKelompok: json["id_kelompok"],
    periodeStart: DateTime.parse(json["periode_start"]),
    periodeEnd: DateTime.parse(json["periode_end"]),
    status: json["status"],
    idTenant: json["id_tenant"],
    gambar: json["gambar"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
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
    "id_kelompok": idKelompok,
    "periode_start": periodeStart.toIso8601String(),
    "periode_end": periodeEnd.toIso8601String(),
    "status": status,
    "id_tenant": idTenant,
    "gambar": gambar,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
