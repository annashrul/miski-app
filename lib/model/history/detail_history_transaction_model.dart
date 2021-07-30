// To parse this JSON data, do
//
//     final detailHistoryTransactionModel = detailHistoryTransactionModelFromJson(jsonString);

import 'dart:convert';

DetailHistoryTransactionModel detailHistoryTransactionModelFromJson(String str) => DetailHistoryTransactionModel.fromJson(json.decode(str));

String detailHistoryTransactionModelToJson(DetailHistoryTransactionModel data) => json.encode(data.toJson());

class DetailHistoryTransactionModel {
  DetailHistoryTransactionModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory DetailHistoryTransactionModel.fromJson(Map<String, dynamic> json) => DetailHistoryTransactionModel(
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
    this.totalrecords,
    this.kdTrx,
    this.idTenant,
    this.tenant,
    this.idMember,
    this.member,
    this.subtotal,
    this.disc,
    this.tax,
    this.ongkir,
    this.grandtotal,
    this.metodePembayaran,
    this.idPromo,
    this.kodeVoucher,
    this.status,
    this.statusMessage,
    this.resi,
    this.kurir,
    this.service,
    this.validResi,
    this.tglResi,
    this.tglTerima,
    this.bankTujuan,
    this.rekeningTujuan,
    this.jumlahTf,
    this.bukti,
    this.createdAt,
    this.updatedAt,
    this.oneSignalId,
    this.logo,
    this.atasNama,
    this.kodeUnik,
    this.bankCode,
    this.logoKurir,
    this.logoTenant,
    this.barang,
  });

  String totalrecords;
  String kdTrx;
  String idTenant;
  String tenant;
  String idMember;
  String member;
  String subtotal;
  int disc;
  int tax;
  String ongkir;
  String grandtotal;
  String metodePembayaran;
  String idPromo;
  String kodeVoucher;
  int status;
  String statusMessage;
  String resi;
  String kurir;
  String service;
  int validResi;
  dynamic tglResi;
  dynamic tglTerima;
  String bankTujuan;
  String rekeningTujuan;
  String jumlahTf;
  String bukti;
  DateTime createdAt;
  DateTime updatedAt;
  String oneSignalId;
  String logo;
  String atasNama;
  String kodeUnik;
  String bankCode;
  String logoKurir;
  String logoTenant;
  List<Barang> barang;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    totalrecords: json["totalrecords"],
    kdTrx: json["kd_trx"],
    idTenant: json["id_tenant"],
    tenant: json["tenant"],
    idMember: json["id_member"],
    member: json["member"],
    subtotal: json["subtotal"],
    disc: json["disc"],
    tax: json["tax"],
    ongkir: json["ongkir"],
    grandtotal: json["grandtotal"],
    metodePembayaran: json["metode_pembayaran"],
    idPromo: json["id_promo"],
    kodeVoucher: json["kode_voucher"],
    status: json["status"],
    statusMessage: json["status_message"],
    resi: json["resi"],
    kurir: json["kurir"],
    service: json["service"],
    validResi: json["valid_resi"],
    tglResi: json["tgl_resi"],
    tglTerima: json["tgl_terima"],
    bankTujuan: json["bank_tujuan"],
    rekeningTujuan: json["rekening_tujuan"],
    jumlahTf: json["jumlah_tf"],
    bukti: json["bukti"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    oneSignalId: json["one_signal_id"],
    logo: json["logo"],
    atasNama: json["atas_nama"],
    kodeUnik: json["kode_unik"],
    bankCode: json["bank_code"],
    logoKurir: json["logo_kurir"],
    logoTenant: json["logo_tenant"],
    barang: List<Barang>.from(json["barang"].map((x) => Barang.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalrecords": totalrecords,
    "kd_trx": kdTrx,
    "id_tenant": idTenant,
    "tenant": tenant,
    "id_member": idMember,
    "member": member,
    "subtotal": subtotal,
    "disc": disc,
    "tax": tax,
    "ongkir": ongkir,
    "grandtotal": grandtotal,
    "metode_pembayaran": metodePembayaran,
    "id_promo": idPromo,
    "kode_voucher": kodeVoucher,
    "status": status,
    "status_message": statusMessage,
    "resi": resi,
    "kurir": kurir,
    "service": service,
    "valid_resi": validResi,
    "tgl_resi": tglResi,
    "tgl_terima": tglTerima,
    "bank_tujuan": bankTujuan,
    "rekening_tujuan": rekeningTujuan,
    "jumlah_tf": jumlahTf,
    "bukti": bukti,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "one_signal_id": oneSignalId,
    "logo": logo,
    "atas_nama": atasNama,
    "kode_unik": kodeUnik,
    "bank_code": bankCode,
    "logo_kurir": logoKurir,
    "logo_tenant": logoTenant,
    "barang": List<dynamic>.from(barang.map((x) => x.toJson())),
  };
}

class Barang {
  Barang({
    this.id,
    this.kdTrx,
    this.kodeBarang,
    this.barang,
    this.gambar,
    this.varian,
    this.subvarian,
    this.qty,
    this.hargaJual,
    this.disc,
    this.subtotal,
    this.tax,
    this.createdAt,
    this.updatedAt,
    this.totalrecords,
  });

  String id;
  String kdTrx;
  String kodeBarang;
  String barang;
  String gambar;
  dynamic varian;
  dynamic subvarian;
  int qty;
  String hargaJual;
  int disc;
  String subtotal;
  int tax;
  DateTime createdAt;
  DateTime updatedAt;
  String totalrecords;

  factory Barang.fromJson(Map<String, dynamic> json) => Barang(
    id: json["id"],
    kdTrx: json["kd_trx"],
    kodeBarang: json["kode_barang"],
    barang: json["barang"],
    gambar: json["gambar"],
    varian: json["varian"],
    subvarian: json["subvarian"],
    qty: json["qty"],
    hargaJual: json["harga_jual"],
    disc: json["disc"],
    subtotal: json["subtotal"],
    tax: json["tax"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    totalrecords: json["totalrecords"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "kd_trx": kdTrx,
    "kode_barang": kodeBarang,
    "barang": barang,
    "gambar": gambar,
    "varian": varian,
    "subvarian": subvarian,
    "qty": qty,
    "harga_jual": hargaJual,
    "disc": disc,
    "subtotal": subtotal,
    "tax": tax,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "totalrecords": totalrecords,
  };
}
