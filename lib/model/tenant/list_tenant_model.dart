// To parse this JSON data, do
//
//     final listTenantModel = listTenantModelFromJson(jsonString);

import 'dart:convert';

ListTenantModel listTenantModelFromJson(String str) => ListTenantModel.fromJson(json.decode(str));

String listTenantModelToJson(ListTenantModel data) => json.encode(data.toJson());

class ListTenantModel {
  ListTenantModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ListTenantModel.fromJson(Map<String, dynamic> json) => ListTenantModel(
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
  String currentPage;
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

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
