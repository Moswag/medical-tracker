import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

MedicalService userFromJson(String str) {
  final jsonData = json.decode(str);
  return MedicalService.fromJson(jsonData);
}

String userToJson(MedicalService data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class MedicalService {
  String id;
  String addedBy;
  String name;
  String description;
  String imageUrl;
  bool hasPrice;
  double price;
  String date;
  String status;

  MedicalService({
    this.id,
    this.addedBy,
    this.name,
    this.description,
    this.imageUrl,
    this.hasPrice,
    this.price,
    this.date,
    this.status
  });

  factory MedicalService.fromJson(Map<String, dynamic> json) => new MedicalService(
      id: json["id"],
      addedBy: json["addedBy"],
      name: json["name"],
      description: json["description"],
      imageUrl: json["imageUrl"],
      hasPrice: json["hasPrice"],
      price: json["price"],
      date: json["date"],
      status: json["status"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "addedBy": addedBy,
    "name": name,
    "description": description,
    "imageUrl": imageUrl,
    "hasPrice":hasPrice,
    "price":price,
    "date":date,
    "status":status
  };

  factory MedicalService.fromDocument(DocumentSnapshot doc) {
    return MedicalService.fromJson(doc.data);
  }
}
