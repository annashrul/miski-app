// To parse this JSON data, do
//
//     final detailCheckoutVirtualAccountModel = detailCheckoutVirtualAccountModelFromJson(jsonString);

import 'dart:convert';

DetailCheckoutVirtualAccountModel detailCheckoutVirtualAccountModelFromJson(String str) => DetailCheckoutVirtualAccountModel.fromJson(json.decode(str));

String detailCheckoutVirtualAccountModelToJson(DetailCheckoutVirtualAccountModel data) => json.encode(data.toJson());

class DetailCheckoutVirtualAccountModel {
  DetailCheckoutVirtualAccountModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory DetailCheckoutVirtualAccountModel.fromJson(Map<String, dynamic> json) => DetailCheckoutVirtualAccountModel(
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
    this.paymentMethod,
    this.paymentName,
    this.amount,
    this.admin,
    this.totalPay,
    this.payCode,
    this.expiredDate,
    this.expiredTime,
    this.instruction,
  });

  dynamic invoiceNo;
  dynamic paymentMethod;
  dynamic paymentName;
  dynamic amount;
  dynamic admin;
  dynamic totalPay;
  dynamic payCode;
  DateTime expiredDate;
  dynamic expiredTime;
  List<Instruction> instruction;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    invoiceNo: json["invoice_no"],
    paymentMethod: json["payment_method"],
    paymentName: json["payment_name"],
    amount: json["amount"],
    admin: json["admin"],
    totalPay: json["total_pay"],
    payCode: json["pay_code"],
    expiredDate: DateTime.parse(json["expired_date"]),
    expiredTime: json["expired_time"],
    instruction: List<Instruction>.from(json["instruction"].map((x) => Instruction.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "invoice_no": invoiceNo,
    "payment_method": paymentMethod,
    "payment_name": paymentName,
    "amount": amount,
    "admin": admin,
    "total_pay": totalPay,
    "pay_code": payCode,
    "expired_date": expiredDate.toIso8601String(),
    "expired_time": expiredTime,
    "instruction": List<dynamic>.from(instruction.map((x) => x.toJson())),
  };
}

class Instruction {
  Instruction({
    this.title,
    this.steps,
  });

  dynamic title;
  List<String> steps;

  factory Instruction.fromJson(Map<String, dynamic> json) => Instruction(
    title: json["title"],
    steps: List<String>.from(json["steps"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "steps": List<dynamic>.from(steps.map((x) => x)),
  };
}
