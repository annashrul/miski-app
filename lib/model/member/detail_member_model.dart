// To parse this JSON data, do
//
//     final detailMemberModel = detailMemberModelFromJson(jsonString);

import 'dart:convert';

DetailMemberModel detailMemberModelFromJson(String str) => DetailMemberModel.fromJson(json.decode(str));

String detailMemberModelToJson(DetailMemberModel data) => json.encode(data.toJson());

class DetailMemberModel {
  DetailMemberModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory DetailMemberModel.fromJson(Map<String, dynamic> json) => DetailMemberModel(
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
    this.nama,
    this.alamat,
    this.status,
    this.email,
    this.tlp,
    this.password,
    this.foto,
    this.tglUltah,
    this.jenisKelamin,
    this.tokenResetPassword,
    this.oneSignalId,
    this.biografi,
    this.lastLogin,
    this.platform,
    this.createdAt,
    this.updatedAt,
    this.otpTemp,
  });

  String id;
  String nama;
  String alamat;
  String status;
  String email;
  String tlp;
  String password;
  String foto;
  DateTime tglUltah;
  String jenisKelamin;
  String tokenResetPassword;
  String oneSignalId;
  String biografi;
  DateTime lastLogin;
  String platform;
  DateTime createdAt;
  DateTime updatedAt;
  String otpTemp;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    nama: json["nama"],
    alamat: json["alamat"],
    status: json["status"],
    email: json["email"],
    tlp: json["tlp"],
    password: json["password"],
    foto: json["foto"],
    tglUltah: DateTime.parse(json["tgl_ultah"]),
    jenisKelamin: json["jenis_kelamin"],
    tokenResetPassword: json["token_reset_password"],
    oneSignalId: json["one_signal_id"],
    biografi: json["biografi"],
    lastLogin: DateTime.parse(json["last_login"]),
    platform: json["platform"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    otpTemp: json["otp_temp"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "alamat": alamat,
    "status": status,
    "email": email,
    "tlp": tlp,
    "password": password,
    "foto": foto,
    "tgl_ultah": tglUltah.toIso8601String(),
    "jenis_kelamin": jenisKelamin,
    "token_reset_password": tokenResetPassword,
    "one_signal_id": oneSignalId,
    "biografi": biografi,
    "last_login": lastLogin.toIso8601String(),
    "platform": platform,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "otp_temp": otpTemp,
  };
}
