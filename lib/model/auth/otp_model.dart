// To parse this JSON data, do
//
//     final otpModel = otpModelFromJson(jsonString);

import 'dart:convert';

OtpModel otpModelFromJson(String str) => OtpModel.fromJson(json.decode(str));

String otpModelToJson(OtpModel data) => json.encode(data.toJson());

class OtpModel {
  OtpModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory OtpModel.fromJson(Map<String, dynamic> json) => OtpModel(
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
    this.data,
    this.otp,
  });

  String data;
  String otp;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    data: json["data"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "data": data,
    "otp": otp,
  };
}
