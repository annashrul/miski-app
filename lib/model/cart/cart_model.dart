// To parse this JSON data, do
//
//     final cartModel = cartModelFromJson(jsonString);

import 'dart:convert';

CartModel cartModelFromJson(String str) => CartModel.fromJson(json.decode(str));

String cartModelToJson(CartModel data) => json.encode(data.toJson());

class CartModel {
  CartModel({
    this.result,
    this.msg,
    this.status,
  });

  List<Result> result;
  String msg;
  String status;

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    msg: json["msg"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
    "msg": msg,
    "status": status,
  };
}

class Result {
  Result({
    this.id,
    this.idTenant,
    this.tenant,
    this.idMember,
    this.member,
    this.idBarang,
    this.kodeBarang,
    this.barang,
    this.idVarian,
    this.varian,
    this.idSubvarian,
    this.subvarian,
    this.hargaJual,
    this.varianHarga,
    this.subvarianHarga,
    this.qty,
    this.stock,
    this.disc1,
    this.disc2,
    this.hargaMaster,
    this.hargaCoret,
    this.berat,
    this.createdAt,
    this.updatedAt,
    this.bertingkat,
    this.gambar,
  });

  String id;
  String idTenant;
  String tenant;
  String idMember;
  String member;
  String idBarang;
  String kodeBarang;
  String barang;
  String idVarian;
  String varian;
  String idSubvarian;
  String subvarian;
  String hargaJual;
  String varianHarga;
  String subvarianHarga;
  String qty;
  String stock;
  String disc1;
  String disc2;
  String hargaMaster;
  String hargaCoret;
  String berat;
  DateTime createdAt;
  DateTime updatedAt;
  bool bertingkat;
  String gambar;


  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    idTenant: json["id_tenant"],
    tenant: json["tenant"],
    idMember: json["id_member"],
    member: json["member"],
    idBarang: json["id_barang"],
    kodeBarang: json["kode_barang"],
    barang: json["barang"],
    idVarian: json["id_varian"],
    varian: json["varian"],
    idSubvarian: json["id_subvarian"],
    subvarian: json["subvarian"],
    hargaJual: json["harga_jual"],
    varianHarga: json["varian_harga"],
    subvarianHarga: json["subvarian_harga"],
    qty: json["qty"],
    stock: json["stock"],
    disc1: json["disc1"],
    disc2: json["disc2"],
    hargaMaster: json["harga_master"],
    hargaCoret: json["harga_coret"],
    berat: json["berat"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    bertingkat: json["bertingkat"],
    gambar: json["gambar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_tenant": idTenant,
    "tenant": tenant,
    "id_member": idMember,
    "member": member,
    "id_barang": idBarang,
    "kode_barang": kodeBarang,
    "barang": barang,
    "id_varian": idVarian,
    "varian": varian,
    "id_subvarian": idSubvarian,
    "subvarian": subvarian,
    "harga_jual": hargaJual,
    "varian_harga": varianHarga,
    "subvarian_harga": subvarianHarga,
    "qty": qty,
    "stock": stock,
    "disc1": disc1,
    "disc2": disc2,
    "harga_master": hargaMaster,
    "harga_coret": hargaCoret,
    "berat": berat,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "bertingkat": bertingkat,
    "gambar": gambar,
  };
}
