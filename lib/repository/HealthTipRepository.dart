import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/BookedService.dart';
import 'package:medicaltracker/model/Emergency.dart';
import 'package:medicaltracker/model/HealthTip.dart';
import 'package:medicaltracker/model/MedicalService.dart';
import 'package:medicaltracker/ui/user/book_service/BookService.dart';

class HealthTipRepository {

  static Future<bool> addTip(HealthTip healthTip) async {
    try {
      Firestore.instance
          .document(TABLE_TIPS + "/${healthTip.id}")
          .setData(healthTip.toJson());
      print("Tip successfully added");
      return true;
    } catch (e) {
      return false;
    }
  }

}
