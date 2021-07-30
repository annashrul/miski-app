// To parse this JSON data, do
//
//     final configAuthModel = configAuthModelFromJson(jsonString);

import 'dart:convert';

ConfigAuthModel configAuthModelFromJson(String str) => ConfigAuthModel.fromJson(json.decode(str));

String configAuthModelToJson(ConfigAuthModel data) => json.encode(data.toJson());

class ConfigAuthModel {
  ConfigAuthModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ConfigAuthModel.fromJson(Map<String, dynamic> json) => ConfigAuthModel(
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
    this.multitenant,
    this.tenant,
    this.type,
  });

  bool multitenant;
  Tenant tenant;
  String type;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    multitenant: json["multitenant"],
    tenant: Tenant.fromJson(json["tenant"]),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "multitenant": multitenant,
    "tenant": tenant.toJson(),
    "type": type,
  };
}

class Tenant {
  Tenant({
    this.id,
    this.nama,
    this.email,
    this.telp,
    this.alamat,
    this.long,
    this.lat,
    this.status,
    this.logo,
    this.uniqueCode,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String nama;
  String email;
  String telp;
  String alamat;
  String long;
  String lat;
  int status;
  String logo;
  String uniqueCode;
  DateTime createdAt;
  DateTime updatedAt;

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json["id"],
    nama: json["nama"],
    email: json["email"],
    telp: json["telp"],
    alamat: json["alamat"],
    long: json["long"],
    lat: json["lat"],
    status: json["status"],
    logo: json["logo"],
    uniqueCode: json["unique_code"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "email": email,
    "telp": telp,
    "alamat": alamat,
    "long": long,
    "lat": lat,
    "status": status,
    "logo": logo,
    "unique_code": uniqueCode,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
