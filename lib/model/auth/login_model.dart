// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  LoginModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
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
    this.token,
    this.nama,
    this.email,
    this.status,
    this.alamat,
    this.jenisKelamin,
    this.tglUltah,
    this.tlp,
    this.foto,
    this.biografi,
    this.lastLogin,
    this.otp,
    this.msgOtp,
  });

  String id;
  String token;
  String nama;
  String email;
  String status;
  String alamat;
  String jenisKelamin;
  DateTime tglUltah;
  String tlp;
  String foto;
  String biografi;
  DateTime lastLogin;
  String otp;
  String msgOtp;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    token: json["token"],
    nama: json["nama"],
    email: json["email"],
    status: json["status"],
    alamat: json["alamat"],
    jenisKelamin: json["jenis_kelamin"],
    tglUltah: DateTime.parse(json["tgl_ultah"]),
    tlp: json["tlp"],
    foto: json["foto"],
    biografi: json["biografi"],
    lastLogin: DateTime.parse(json["last_login"]),
    otp: json["otp"],
    msgOtp: json["msg_otp"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "token": token,
    "nama": nama,
    "email": email,
    "status": status,
    "alamat": alamat,
    "jenis_kelamin": jenisKelamin,
    "tgl_ultah": tglUltah.toIso8601String(),
    "tlp": tlp,
    "foto": foto,
    "biografi": biografi,
    "last_login": lastLogin.toIso8601String(),
    "otp": otp,
    "msg_otp": msgOtp,
  };
}
