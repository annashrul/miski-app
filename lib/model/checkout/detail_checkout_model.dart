// To parse this JSON data, do
//
//     final detailCheckoutModel = detailCheckoutModelFromJson(jsonString);

import 'dart:convert';

DetailCheckoutModel detailCheckoutModelFromJson(String str) => DetailCheckoutModel.fromJson(json.decode(str));

String detailCheckoutModelToJson(DetailCheckoutModel data) => json.encode(data.toJson());

class DetailCheckoutModel {
  DetailCheckoutModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory DetailCheckoutModel.fromJson(Map<String, dynamic> json) => DetailCheckoutModel(
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
    this.barang,
    this.kurir,
    this.alamat,
  });

  List<Barang> barang;
  List<Kurir> kurir;
  List<Alamat> alamat;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    barang: List<Barang>.from(json["barang"].map((x) => Barang.fromJson(x))),
    kurir: List<Kurir>.from(json["kurir"].map((x) => Kurir.fromJson(x))),
    alamat: List<Alamat>.from(json["alamat"].map((x) => Alamat.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "barang": List<dynamic>.from(barang.map((x) => x.toJson())),
    "kurir": List<dynamic>.from(kurir.map((x) => x.toJson())),
    "alamat": List<dynamic>.from(alamat.map((x) => x.toJson())),
  };
}

class Alamat {
  Alamat({
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

  factory Alamat.fromJson(Map<String, dynamic> json) => Alamat(
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

class Barang {
  Barang({
    this.id,
    this.idTenant,
    this.tenant,
    this.idMember,
    this.member,
    this.kodeBarang,
    this.barang,
    this.gambar,
    this.idVarian,
    this.varian,
    this.idSubvarian,
    this.subvarian,
    this.hargaJual,
    this.qty,
    this.stock,
    this.disc1,
    this.disc2,
    this.hargaMaster,
    this.hargaCoret,
    this.berat,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String idTenant;
  String tenant;
  String idMember;
  String member;
  String kodeBarang;
  String barang;
  String gambar;
  String idVarian;
  String varian;
  String idSubvarian;
  String subvarian;
  String hargaJual;
  String qty;
  String stock;
  String disc1;
  String disc2;
  String hargaMaster;
  String hargaCoret;
  String berat;
  DateTime createdAt;
  DateTime updatedAt;

  factory Barang.fromJson(Map<String, dynamic> json) => Barang(
    id: json["id"],
    idTenant: json["id_tenant"],
    tenant: json["tenant"],
    idMember: json["id_member"],
    member: json["member"],
    kodeBarang: json["kode_barang"],
    barang: json["barang"],
    gambar: json["gambar"],
    idVarian: json["id_varian"],
    varian: json["varian"],
    idSubvarian: json["id_subvarian"],
    subvarian: json["subvarian"],
    hargaJual: json["harga_jual"],
    qty: json["qty"],
    stock: json["stock"],
    disc1: json["disc1"],
    disc2: json["disc2"],
    hargaMaster: json["harga_master"],
    hargaCoret: json["harga_coret"],
    berat: json["berat"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_tenant": idTenant,
    "tenant": tenant,
    "id_member": idMember,
    "member": member,
    "kode_barang": kodeBarang,
    "barang": barang,
    "gambar": gambar,
    "id_varian": idVarian,
    "varian": varian,
    "id_subvarian": idSubvarian,
    "subvarian": subvarian,
    "harga_jual": hargaJual,
    "qty": qty,
    "stock": stock,
    "disc1": disc1,
    "disc2": disc2,
    "harga_master": hargaMaster,
    "harga_coret": hargaCoret,
    "berat": berat,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Kurir {
  Kurir({
    this.id,
    this.kurir,
    this.status,
    this.gambar,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String kurir;
  int status;
  String gambar;
  DateTime createdAt;
  DateTime updatedAt;

  factory Kurir.fromJson(Map<String, dynamic> json) => Kurir(
    id: json["id"],
    kurir: json["kurir"],
    status: json["status"],
    gambar: json["gambar"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "kurir": kurir,
    "status": status,
    "gambar": gambar,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
