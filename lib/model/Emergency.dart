import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

Emergency userFromJson(String str) {
  final jsonData = json.decode(str);
  return Emergency.fromJson(jsonData);
}

String userToJson(Emergency data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Emergency {
  String id;
  String patient;
  double latitude;
  double longitude;
  String address;
  String date;
  String status;

  Emergency({
    this.id,
    this.patient,
    this.latitude,
    this.longitude,
    this.address,
    this.date,
    this.status
  });

  factory Emergency.fromJson(Map<String, dynamic> json) => new Emergency(
      id: json["id"],
      patient: json["patient"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      address: json["address"],
      date: json["date"],
      status: json["status"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient": patient,
    "latitude": latitude,
    "longitude": longitude,
    "address": address,
    "date":date,
    "status":status
  };

  factory Emergency.fromDocument(DocumentSnapshot doc) {
    return Emergency.fromJson(doc.data);
  }
}
