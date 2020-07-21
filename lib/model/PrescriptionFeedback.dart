import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

PrescriptionFeedback userFromJson(String str) {
  final jsonData = json.decode(str);
  return PrescriptionFeedback.fromJson(jsonData);
}

String userToJson(PrescriptionFeedback data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class PrescriptionFeedback {
  String id;
  String patientId;
  String prescriptionId;
  String feedback;
  String date;


  PrescriptionFeedback({
    this.id,
    this.patientId,
    this.prescriptionId,
    this.feedback,
    this.date
  });

  factory PrescriptionFeedback.fromJson(Map<String, dynamic> json) => new PrescriptionFeedback(
      id: json["id"],
      patientId: json["patientId"],
      prescriptionId: json["prescriptionId"],
    feedback: json["feedback"],
      date: json["date"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patientId": patientId,
    "prescriptionId": prescriptionId,
    "feedback":feedback,
    "date":date,

  };

  factory PrescriptionFeedback.fromDocument(DocumentSnapshot doc) {
    return PrescriptionFeedback.fromJson(doc.data);
  }
}
