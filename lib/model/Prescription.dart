import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

Prescription userFromJson(String str) {
  final jsonData = json.decode(str);
  return Prescription.fromJson(jsonData);
}

String userToJson(Prescription data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Prescription {
  String id;
  String scheduleId;
  String patientId;
  String doctorId;
  String disease;
  String prescription;
  String numberOfCourses;
  String takingPerDay;
  String startDate;
  String endDate;
  String date;
  String status;

  Prescription({
    this.id,
    this.scheduleId,
    this.patientId,
    this.doctorId,
    this.disease,
    this.prescription,
    this.numberOfCourses,
    this.takingPerDay,
    this.startDate,
    this.endDate,
    this.date,
    this.status,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) =>
      new Prescription(
        id: json["id"],
        scheduleId: json["scheduleId"],
        patientId: json["patientId"],
        doctorId: json["doctorId"],
        disease: json["disease"],
        prescription: json["prescription"],
        numberOfCourses: json["numberOfCourses"],
        takingPerDay: json["takingPerDay"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        date: json["date"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "scheduleId": scheduleId,
        "patientId": patientId,
        "doctorId": doctorId,
        "disease": disease,
        "prescription": prescription,
        "numberOfCourses": numberOfCourses,
        "takingPerDay": takingPerDay,
        "startDate": startDate,
        "endDate": endDate,
        "date": date,
        "status": status,
      };

  factory Prescription.fromDocument(DocumentSnapshot doc) {
    return Prescription.fromJson(doc.data);
  }
}
