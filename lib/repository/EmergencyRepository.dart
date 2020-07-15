import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/BookedService.dart';
import 'package:medicaltracker/model/Emergency.dart';
import 'package:medicaltracker/model/MedicalService.dart';
import 'package:medicaltracker/ui/user/book_service/BookService.dart';

class EmergencyRepository {


  static Future<bool> reportEmergency(Emergency emergency) async {
    try {
      Firestore.instance
          .document(TABLE_EMERGENCY + "/${emergency.id}")
          .setData(emergency.toJson());
      print("Emegency booked successfully");
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateEmergency(Emergency emergency) async {
    try {
      Firestore.instance
          .collection(TABLE_EMERGENCY)
          .document(emergency.id)
          .updateData(emergency.toJson())
          .then((result) {
        return true;
      }).catchError((onError) {
        return false;
      });
      return true;
    } catch (e) {
      return false;
    }
  }




}
