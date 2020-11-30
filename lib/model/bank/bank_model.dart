// To parse this JSON data, do
//
//     final bankModel = bankModelFromJson(jsonString);

import 'dart:convert';

BankModel bankModelFromJson(String str) => BankModel.fromJson(json.decode(str));

String bankModelToJson(BankModel data) => json.encode(data.toJson());

class BankModel {
  BankModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory BankModel.fromJson(Map<String, dynamic> json) => BankModel(
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
  int currentPage;
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
    this.noRekening,
    this.bankName,
    this.atasNama,
    this.bankCode,
    this.tfCode,
    this.logo,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String noRekening;
  String bankName;
  String atasNama;
  String bankCode;
  int tfCode;
  String logo;
  DateTime createdAt;
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    noRekening: json["no_rekening"],
    bankName: json["bank_name"],
    atasNama: json["atas_nama"],
    bankCode: json["bank_code"],
    tfCode: json["tf_code"],
    logo: json["logo"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "no_rekening": noRekening,
    "bank_name": bankName,
    "atas_nama": atasNama,
    "bank_code": bankCode,
    "tf_code": tfCode,
    "logo": logo,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
