// To parse this JSON data, do
//
//     final checkoutModel = checkoutModelFromJson(jsonString);

import 'dart:convert';

CheckoutModel checkoutModelFromJson(String str) => CheckoutModel.fromJson(json.decode(str));

String checkoutModelToJson(CheckoutModel data) => json.encode(data.toJson());

class CheckoutModel {
  CheckoutModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory CheckoutModel.fromJson(Map<String, dynamic> json) => CheckoutModel(
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
    this.invoiceNo,
    this.grandtotal,
    this.kodeUnik,
    this.totalTransfer,
    this.bankLogo,
    this.bankName,
    this.bankAtasNama,
    this.bankAcc,
    this.bankCode,
  });

  String invoiceNo;
  String grandtotal;
  String kodeUnik;
  int totalTransfer;
  String bankLogo;
  String bankName;
  String bankAtasNama;
  String bankAcc;
  String bankCode;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    invoiceNo: json["invoice_no"],
    grandtotal: json["grandtotal"],
    kodeUnik: json["kode_unik"],
    totalTransfer: json["total_transfer"],
    bankLogo: json["bank_logo"],
    bankName: json["bank_name"],
    bankAtasNama: json["bank_atas_nama"],
    bankAcc: json["bank_acc"],
    bankCode: json["bank_code"],
  );

  Map<String, dynamic> toJson() => {
    "invoice_no": invoiceNo,
    "grandtotal": grandtotal,
    "kode_unik": kodeUnik,
    "total_transfer": totalTransfer,
    "bank_logo": bankLogo,
    "bank_name": bankName,
    "bank_atas_nama": bankAtasNama,
    "bank_acc": bankAcc,
    "bank_code": bankCode,
  };
}
