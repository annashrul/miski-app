// To parse this JSON data, do
//
//     final checkOngkirModel = checkOngkirModelFromJson(jsonString);

import 'dart:convert';

CheckOngkirModel checkOngkirModelFromJson(String str) => CheckOngkirModel.fromJson(json.decode(str));

String checkOngkirModelToJson(CheckOngkirModel data) => json.encode(data.toJson());

class CheckOngkirModel {
  CheckOngkirModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory CheckOngkirModel.fromJson(Map<String, dynamic> json) => CheckOngkirModel(
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
    this.asal,
    this.tujuan,
    this.kurir,
    this.name,
    this.ongkir,
  });

  String asal;
  String tujuan;
  String kurir;
  String name;
  List<Ongkir> ongkir;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    asal: json["asal"],
    tujuan: json["tujuan"],
    kurir: json["kurir"],
    name: json["name"],
    ongkir: List<Ongkir>.from(json["ongkir"].map((x) => Ongkir.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "asal": asal,
    "tujuan": tujuan,
    "kurir": kurir,
    "name": name,
    "ongkir": List<dynamic>.from(ongkir.map((x) => x.toJson())),
  };
}

class Ongkir {
  Ongkir({
    this.service,
    this.description,
    this.cost,
    this.estimasi,
  });

  String service;
  String description;
  int cost;
  String estimasi;

  factory Ongkir.fromJson(Map<String, dynamic> json) => Ongkir(
    service: json["service"],
    description: json["description"],
    cost: json["cost"],
    estimasi: json["estimasi"],
  );

  Map<String, dynamic> toJson() => {
    "service": service,
    "description": description,
    "cost": cost,
    "estimasi": estimasi,
  };
}
