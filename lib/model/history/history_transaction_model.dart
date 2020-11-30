// To parse this JSON data, do
//
//     final historyTransactionModel = historyTransactionModelFromJson(jsonString);

import 'dart:convert';

HistoryTransactionModel historyTransactionModelFromJson(String str) => HistoryTransactionModel.fromJson(json.decode(str));

String historyTransactionModelToJson(HistoryTransactionModel data) => json.encode(data.toJson());

class HistoryTransactionModel {
  HistoryTransactionModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory HistoryTransactionModel.fromJson(Map<String, dynamic> json) => HistoryTransactionModel(
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
    this.tenant,
    this.kdTrx,
    this.grandtotal,
    this.status,
    this.statusMessage,
    this.createdAt,
    this.bankTujuan,
    this.rekeningTujuan,
    this.jumlahTf,
    this.bukti,
    this.bankLogo,
    this.atasNama,
    this.kodeUnik,
    this.bankCode,
    this.detail,
  });

  String totalrecords;
  String tenant;
  String kdTrx;
  String grandtotal;
  int status;
  String statusMessage;
  DateTime createdAt;
  String bankTujuan;
  String rekeningTujuan;
  String jumlahTf;
  String bukti;
  String bankLogo;
  String atasNama;
  String kodeUnik;
  String bankCode;
  List<Detail> detail;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    totalrecords: json["totalrecords"],
    tenant: json["tenant"],
    kdTrx: json["kd_trx"],
    grandtotal: json["grandtotal"],
    status: json["status"],
    statusMessage: json["status_message"],
    createdAt: DateTime.parse(json["created_at"]),
    bankTujuan: json["bank_tujuan"],
    rekeningTujuan: json["rekening_tujuan"],
    jumlahTf: json["jumlah_tf"],
    bukti: json["bukti"],
    bankLogo: json["bank_logo"],
    atasNama: json["atas_nama"],
    kodeUnik: json["kode_unik"],
    bankCode: json["bank_code"],
    detail: List<Detail>.from(json["detail"].map((x) => Detail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalrecords": totalrecords,
    "tenant": tenant,
    "kd_trx": kdTrx,
    "grandtotal": grandtotal,
    "status": status,
    "status_message": statusMessage,
    "created_at": createdAt.toIso8601String(),
    "bank_tujuan": bankTujuan,
    "rekening_tujuan": rekeningTujuan,
    "jumlah_tf": jumlahTf,
    "bukti": bukti,
    "bank_logo": bankLogo,
    "atas_nama": atasNama,
    "kode_unik": kodeUnik,
    "bank_code": bankCode,
    "detail": List<dynamic>.from(detail.map((x) => x.toJson())),
  };
}

class Detail {
  Detail({
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
  String varian;
  String subvarian;
  int qty;
  String hargaJual;
  int disc;
  String subtotal;
  int tax;
  DateTime createdAt;
  DateTime updatedAt;
  String totalrecords;

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    kdTrx: json["kd_trx"],
    kodeBarang: json["kode_barang"],
    barang: json["barang"],
    gambar: json["gambar"],
    varian: json["varian"] == null ? null : json["varian"],
    subvarian: json["subvarian"] == null ? null : json["subvarian"],
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
    "varian": varian == null ? null : varian,
    "subvarian": subvarian == null ? null : subvarian,
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
