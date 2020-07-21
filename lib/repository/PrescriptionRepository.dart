import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/BookedService.dart';
import 'package:medicaltracker/model/MedicalService.dart';
import 'package:medicaltracker/model/Prescription.dart';
import 'package:medicaltracker/ui/user/book_service/BookService.dart';

class PrescriptionRepository {


  static Future<bool> addPrescription(Prescription prescription) async {
    try {
      Firestore.instance
          .document(TABLE_PRESCRIPTION + "/${prescription.id}")
          .setData(prescription.toJson());
      print("Prescription saved successfully");
      return true;
    } catch (e) {
      return false;
    }
  }



  static Future<bool> updatePrescription(Prescription prescription) async {
    try {
      Firestore.instance
          .collection(TABLE_PRESCRIPTION)
          .document(prescription.id)
          .updateData(prescription.toJson())
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
