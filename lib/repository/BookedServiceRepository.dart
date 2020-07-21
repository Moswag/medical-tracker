import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/BookedService.dart';
import 'package:medicaltracker/model/MedicalService.dart';
import 'package:medicaltracker/ui/user/book_service/BookService.dart';

class BookedServiceRepository {


  static Future<bool> bookService(BookedService bookedService) async {
    try {
      Firestore.instance
          .document(TABLE_BOOKED_SERVICES + "/${bookedService.id}")
          .setData(bookedService.toJson());
      print("Service booked successfully");
      return true;
    } catch (e) {
      return false;
    }
  }



  static Stream <List<MedicalService>> getBookedServices() async*  {
    yield* Firestore.instance
        .collection(TABLE_BOOKED_SERVICES)
        .snapshots()
        .asyncMap((snapshot) async {
      final list = snapshot.documents.map((doc) async {
        return MedicalService.fromDocument(doc);
      }).toList();
      return await Future.wait(list);
    });
  }


  static Future<bool> updateSchedule(BookedService bookedService) async {
    try {
      Firestore.instance
          .collection(TABLE_BOOKED_SERVICES)
          .document(bookedService.id)
          .updateData(bookedService.toJson())
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

  static Future<BookedService> getService(String serviceId) async {
    final docRef = Firestore.instance
        .collection(TABLE_BOOKED_SERVICES)
        .document(serviceId);
    final document = await docRef.get();
    final service = BookedService.fromDocument(document);
    return service;
  }

}
