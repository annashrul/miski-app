// To parse this JSON data, do
//
//     final resiModel = resiModelFromJson(jsonString);

import 'dart:convert';

ResiModel resiModelFromJson(String str) => ResiModel.fromJson(json.decode(str));

String resiModelToJson(ResiModel data) => json.encode(data.toJson());

class ResiModel {
  ResiModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ResiModel.fromJson(Map<String, dynamic> json) => ResiModel(
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
    this.resi,
    this.kurir,
    this.ongkir,
  });

  String resi;
  String kurir;
  Ongkir ongkir;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    resi: json["resi"],
    kurir: json["kurir"],
    ongkir: Ongkir.fromJson(json["ongkir"]),
  );

  Map<String, dynamic> toJson() => {
    "resi": resi,
    "kurir": kurir,
    "ongkir": ongkir.toJson(),
  };
}

class Ongkir {
  Ongkir({
    this.delivered,
    this.summary,
    this.details,
    this.deliveryStatus,
    this.manifest,
  });

  bool delivered;
  Summary summary;
  Details details;
  DeliveryStatus deliveryStatus;
  List<Manifest> manifest;

  factory Ongkir.fromJson(Map<String, dynamic> json) => Ongkir(
    delivered: json["delivered"],
    summary: Summary.fromJson(json["summary"]),
    details: Details.fromJson(json["details"]),
    deliveryStatus: DeliveryStatus.fromJson(json["delivery_status"]),
    manifest: List<Manifest>.from(json["manifest"].map((x) => Manifest.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "delivered": delivered,
    "summary": summary.toJson(),
    "details": details.toJson(),
    "delivery_status": deliveryStatus.toJson(),
    "manifest": List<dynamic>.from(manifest.map((x) => x.toJson())),
  };
}

class DeliveryStatus {
  DeliveryStatus({
    this.status,
    this.podReceiver,
    this.podDate,
    this.podTime,
  });

  String status;
  String podReceiver;
  DateTime podDate;
  String podTime;

  factory DeliveryStatus.fromJson(Map<String, dynamic> json) => DeliveryStatus(
    status: json["status"],
    podReceiver: json["pod_receiver"],
    podDate: DateTime.parse(json["pod_date"]),
    podTime: json["pod_time"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "pod_receiver": podReceiver,
    "pod_date": "${podDate.year.toString().padLeft(4, '0')}-${podDate.month.toString().padLeft(2, '0')}-${podDate.day.toString().padLeft(2, '0')}",
    "pod_time": podTime,
  };
}

class Details {
  Details({
    this.waybillNumber,
    this.waybillDate,
    this.waybillTime,
    this.weight,
    this.origin,
    this.destination,
    this.shippperName,
    this.shipperAddress1,
    this.shipperAddress2,
    this.shipperAddress3,
    this.shipperCity,
    this.receiverName,
    this.receiverAddress1,
    this.receiverAddress2,
    this.receiverAddress3,
    this.receiverCity,
  });

  String waybillNumber;
  DateTime waybillDate;
  String waybillTime;
  String weight;
  String origin;
  String destination;
  String shippperName;
  String shipperAddress1;
  String shipperAddress2;
  String shipperAddress3;
  String shipperCity;
  String receiverName;
  String receiverAddress1;
  String receiverAddress2;
  String receiverAddress3;
  String receiverCity;

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    waybillNumber: json["waybill_number"],
    waybillDate: DateTime.parse(json["waybill_date"]),
    waybillTime: json["waybill_time"],
    weight: json["weight"],
    origin: json["origin"],
    destination: json["destination"],
    shippperName: json["shippper_name"],
    shipperAddress1: json["shipper_address1"],
    shipperAddress2: json["shipper_address2"],
    shipperAddress3: json["shipper_address3"],
    shipperCity: json["shipper_city"],
    receiverName: json["receiver_name"],
    receiverAddress1: json["receiver_address1"],
    receiverAddress2: json["receiver_address2"],
    receiverAddress3: json["receiver_address3"],
    receiverCity: json["receiver_city"],
  );

  Map<String, dynamic> toJson() => {
    "waybill_number": waybillNumber,
    "waybill_date": "${waybillDate.year.toString().padLeft(4, '0')}-${waybillDate.month.toString().padLeft(2, '0')}-${waybillDate.day.toString().padLeft(2, '0')}",
    "waybill_time": waybillTime,
    "weight": weight,
    "origin": origin,
    "destination": destination,
    "shippper_name": shippperName,
    "shipper_address1": shipperAddress1,
    "shipper_address2": shipperAddress2,
    "shipper_address3": shipperAddress3,
    "shipper_city": shipperCity,
    "receiver_name": receiverName,
    "receiver_address1": receiverAddress1,
    "receiver_address2": receiverAddress2,
    "receiver_address3": receiverAddress3,
    "receiver_city": receiverCity,
  };
}

class Manifest {
  Manifest({
    this.manifestCode,
    this.manifestDescription,
    this.manifestDate,
    this.manifestTime,
    this.cityName,
  });

  String manifestCode;
  String manifestDescription;
  DateTime manifestDate;
  String manifestTime;
  String cityName;

  factory Manifest.fromJson(Map<String, dynamic> json) => Manifest(
    manifestCode: json["manifest_code"],
    manifestDescription: json["manifest_description"],
    manifestDate: DateTime.parse(json["manifest_date"]),
    manifestTime: json["manifest_time"],
    cityName: json["city_name"],
  );

  Map<String, dynamic> toJson() => {
    "manifest_code": manifestCode,
    "manifest_description": manifestDescription,
    "manifest_date": "${manifestDate.year.toString().padLeft(4, '0')}-${manifestDate.month.toString().padLeft(2, '0')}-${manifestDate.day.toString().padLeft(2, '0')}",
    "manifest_time": manifestTime,
    "city_name": cityName,
  };
}

class Summary {
  Summary({
    this.courierCode,
    this.courierName,
    this.waybillNumber,
    this.serviceCode,
    this.waybillDate,
    this.shipperName,
    this.receiverName,
    this.origin,
    this.destination,
    this.status,
  });

  String courierCode;
  String courierName;
  String waybillNumber;
  String serviceCode;
  DateTime waybillDate;
  String shipperName;
  String receiverName;
  String origin;
  String destination;
  String status;

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    courierCode: json["courier_code"],
    courierName: json["courier_name"],
    waybillNumber: json["waybill_number"],
    serviceCode: json["service_code"],
    waybillDate: DateTime.parse(json["waybill_date"]),
    shipperName: json["shipper_name"],
    receiverName: json["receiver_name"],
    origin: json["origin"],
    destination: json["destination"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "courier_code": courierCode,
    "courier_name": courierName,
    "waybill_number": waybillNumber,
    "service_code": serviceCode,
    "waybill_date": "${waybillDate.year.toString().padLeft(4, '0')}-${waybillDate.month.toString().padLeft(2, '0')}-${waybillDate.day.toString().padLeft(2, '0')}",
    "shipper_name": shipperName,
    "receiver_name": receiverName,
    "origin": origin,
    "destination": destination,
    "status": status,
  };
}
