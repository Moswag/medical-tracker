import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/MedicalService.dart';

class ServiceRepository {


  static Future<bool> addService(MedicalService service) async {
    try {
      Firestore.instance
          .document(TABLE_SERVICES + "/${service.id}")
          .setData(service.toJson());
      print("Service added");
      return true;
    } catch (e) {
      return false;
    }
  }



  static Stream <List<MedicalService>> getServices() async*  {
    yield* Firestore.instance
        .collection(TABLE_SERVICES)
        .snapshots()
        .asyncMap((snapshot) async {
      final list = snapshot.documents.map((doc) async {
        return MedicalService.fromDocument(doc);
      }).toList();
      return await Future.wait(list);
    });
  }



}
