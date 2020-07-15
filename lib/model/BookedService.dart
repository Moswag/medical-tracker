import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

BookedService userFromJson(String str) {
  final jsonData = json.decode(str);
  return BookedService.fromJson(jsonData);
}

String userToJson(BookedService data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class BookedService {
  String id;
  String patient;
  String serviceId;
  String reason;
  String assignedDoctor;
  String startTime;
  String endTime;
  String status;
  String doctorStatus;

  BookedService({
    this.id,
    this.patient,
    this.serviceId,
    this.reason,
    this.assignedDoctor,
    this.startTime,
    this.endTime,
    this.status,
    this.doctorStatus
  });

  factory BookedService.fromJson(Map<String, dynamic> json) => new BookedService(
      id: json["id"],
      patient: json["patient"],
      serviceId: json["serviceId"],
      reason: json["reason"],
      assignedDoctor: json["assignedDoctor"],
      startTime: json["startTime"],
      endTime: json["endTime"],
      status: json["status"],
      doctorStatus: json["doctorStatus"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient": patient,
    "serviceId": serviceId,
    "reason": reason,
    "assignedDoctor": assignedDoctor,
    "startTime":startTime,
    "endTime":endTime,
    "status":status,
    "doctorStatus":doctorStatus
  };

  factory BookedService.fromDocument(DocumentSnapshot doc) {
    return BookedService.fromJson(doc.data);
  }
}
