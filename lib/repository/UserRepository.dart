import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/User.dart';

class UserRepository {

  static userWithPhoneExist(String phoneNumber) {
    return Firestore.instance
        .collection(TABLE_USERS)
        .where('phonenumber', isEqualTo: phoneNumber)
        .limit(1)
        .getDocuments();
  }

  static Future<User> getUser(String userId) async {
    final docRef = Firestore.instance
        .collection(TABLE_USERS)
        .document(userId);
    final document = await docRef.get();
    final user = User.fromDocument(document);
    return user;
  }



}