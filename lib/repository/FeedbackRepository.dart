

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/PrescriptionFeedback.dart';

class FeedbackRepository {


  static Future<bool> addFeedback(PrescriptionFeedback prescriptionFeedback) async {
    try {
      Firestore.instance
          .document(TABLE_PRESCRIPTION_FEEDBACK + "/${prescriptionFeedback.id}")
          .setData(prescriptionFeedback.toJson());
      print("Prescription feedback successfully added");
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<PrescriptionFeedback> getFeedBack(String serviceId) async {
    final docRef = Firestore.instance
        .collection(TABLE_PRESCRIPTION_FEEDBACK)
        .document(serviceId);
    final document = await docRef.get();
    final service = PrescriptionFeedback.fromDocument(document);
    return service;
  }
}
