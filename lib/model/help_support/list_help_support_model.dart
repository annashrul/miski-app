// To parse this JSON data, do
//
//     final listHelpSupportModel = listHelpSupportModelFromJson(jsonString);

import 'dart:convert';

ListHelpSupportModel listHelpSupportModelFromJson(String str) => ListHelpSupportModel.fromJson(json.decode(str));

String listHelpSupportModelToJson(ListHelpSupportModel data) => json.encode(data.toJson());

class ListHelpSupportModel {
  ListHelpSupportModel({
    this.result,
    this.msg,
    this.status,
  });

  Result result;
  String msg;
  String status;

  factory ListHelpSupportModel.fromJson(Map<String, dynamic> json) => ListHelpSupportModel(
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
    this.perPage,
    this.offset,
    this.to,
    this.lastPage,
    this.currentPage,
    this.from,
    this.data,
  });

  int total;
  int perPage;
  int offset;
  int to;
  int lastPage;
  int currentPage;
  int from;
  List<Datum> data;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    total: json["total"],
    perPage: json["per_page"],
    offset: json["offset"],
    to: json["to"],
    lastPage: json["last_page"],
    currentPage: json["current_page"],
    from: json["from"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "per_page": perPage,
    "offset": offset,
    "to": to,
    "last_page": lastPage,
    "current_page": currentPage,
    "from": from,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.totalrecords,
    this.id,
    this.idKategori,
    this.kategori,
    this.question,
    this.answer,
    this.createdAt,
    this.updatedAt,
  });

  String totalrecords;
  String id;
  String idKategori;
  String kategori;
  String question;
  String answer;
  DateTime createdAt;
  dynamic updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    totalrecords: json["totalrecords"],
    id: json["id"],
    idKategori: json["id_kategori"],
    kategori: json["kategori"],
    question: json["question"],
    answer: json["answer"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "totalrecords": totalrecords,
    "id": id,
    "id_kategori": idKategori,
    "kategori": kategori,
    "question": question,
    "answer": answer,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt,
  };
}
