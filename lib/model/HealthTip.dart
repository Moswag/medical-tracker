import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

HealthTip userFromJson(String str) {
  final jsonData = json.decode(str);
  return HealthTip.fromJson(jsonData);
}

String userToJson(HealthTip data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class HealthTip {
  String id;
  String addedBy;
  String tip;
  String date;
  String status;

  HealthTip({
    this.id,
    this.addedBy,
    this.tip,
    this.date,
    this.status
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) => new HealthTip(
      id: json["id"],
      addedBy: json["addedBy"],
      tip: json["tip"],
      date: json["date"],
      status: json["status"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "addedBy": addedBy,
    "tip": tip,
    "date":date,
    "status":status
  };

  factory HealthTip.fromDocument(DocumentSnapshot doc) {
    return HealthTip.fromJson(doc.data);
  }
}
