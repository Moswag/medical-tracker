import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class User {
  String userId;
  String firstName;
  String lastName;
  String email;
  String access;
  String phonenumber;
  String address;
  String status;
  String serviceId;

  User({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.access,
    this.phonenumber,
    this.address,
    this.status,
    this.serviceId
  });

  factory User.fromJson(Map<String, dynamic> json) => new User(
      userId: json["userId"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
      access: json["access"],
      phonenumber: json["phonenumber"],
      address: json["address"],
      status: json["status"],
      serviceId: json["serviceId"]
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "access":access,
    "phonenumber":phonenumber,
    "address":address,
    "status":status,
    "serviceId":serviceId

  };

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}
