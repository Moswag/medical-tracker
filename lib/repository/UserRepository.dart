import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/User.dart';

class UserRepository {

  static userExist(String email) {
    return Firestore.instance
        .collection(TABLE_USERS)
        .where('email', isEqualTo: email)
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