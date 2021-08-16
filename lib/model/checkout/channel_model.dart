// To parse this JSON data, do
//
//     final channelModel = channelModelFromJson(jsonString);

import 'dart:convert';

ChannelModel channelModelFromJson(String str) => ChannelModel.fromJson(json.decode(str));

String channelModelToJson(ChannelModel data) => json.encode(data.toJson());

class ChannelModel {
    ChannelModel({
        this.result,
        this.msg,
        this.status,
    });

    Result result;
    String msg;
    String status;

    factory ChannelModel.fromJson(Map<String, dynamic> json) => ChannelModel(
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
        this.success,
        this.message,
        this.data,
    });

    bool success;
    String message;
    List<Datum> data;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        success: json["success"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        this.group,
        this.code,
        this.name,
        this.type,
        this.feeMerchant,
        this.feeCustomer,
        this.totalFee,
        this.active,
    });

    String group;
    String code;
    String name;
    String type;
    FeeCustomer feeMerchant;
    FeeCustomer feeCustomer;
    FeeCustomer totalFee;
    bool active;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        group: json["group"],
        code: json["code"],
        name: json["name"],
        type: json["type"],
        feeMerchant: FeeCustomer.fromJson(json["fee_merchant"]),
        feeCustomer: FeeCustomer.fromJson(json["fee_customer"]),
        totalFee: FeeCustomer.fromJson(json["total_fee"]),
        active: json["active"],
    );

    Map<String, dynamic> toJson() => {
        "group": group,
        "code": code,
        "name": name,
        "type": type,
        "fee_merchant": feeMerchant.toJson(),
        "fee_customer": feeCustomer.toJson(),
        "total_fee": totalFee.toJson(),
        "active": active,
    };
}

class FeeCustomer {
    FeeCustomer({
        this.flat,
        this.percent,
    });

    var flat;
    var percent;

    factory FeeCustomer.fromJson(Map<String, dynamic> json) => FeeCustomer(
        flat: json["flat"],
        percent: json["percent"],
    );

    Map<String, dynamic> toJson() => {
        "flat": flat,
        "percent": percent,
    };
}
