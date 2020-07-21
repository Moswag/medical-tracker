import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/Emergency.dart';
import 'package:medicaltracker/model/Prescription.dart';
import 'package:medicaltracker/model/State.dart';
import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/ui/admin/AdminDrawer.dart';
import 'package:medicaltracker/ui/admin/admin/AddAdmin.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/ui/user/UserDrawer.dart';
import 'package:medicaltracker/ui/user/emergencies/ReportEmergency.dart';
import 'package:medicaltracker/util/state_widget.dart';


class PatientHistory extends StatefulWidget {

  PatientHistory({this.user});
  final User user;

  @override
  State createState() => _PatientHistoryState();
}

class _PatientHistoryState extends State<PatientHistory> {
  DateTime backButtonPressedTime;
  StateModel appState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = StateWidget
        .of(context)
        .state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return SignInPage();
    } else {
      final userId = appState?.firebaseUserAuth?.uid ?? '';
      final email = appState?.firebaseUserAuth?.email ?? '';
      final name = appState?.user?.firstName ?? '';
      final surname = appState?.user?.lastName ?? '';
      final access = appState?.user?.access ?? '';

      final makeBottom = Container(
        height: 55.0,
        child: BottomAppBar(
          color: Color.fromRGBO(58, 66, 86, 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) =>
                              ReportEmergency()));
                },
              )
            ],
          ),
        ),
      );

      return Scaffold(
          appBar: new AppBar(
            title: new Text('${widget.user.firstName} ${widget.user.lastName} Medical History',
                style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        centerTitle: true,
        backgroundColor: primaryColor,
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          body: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: StreamBuilder(
                      stream: Firestore.instance
                          .collection(TABLE_PRESCRIPTION)
                          .where("patientId", isEqualTo: widget.user.userId)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return new Container(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ));
                        } else {
                          if (snapshot.data.documents.length != null &&
                              snapshot.data.documents.length > 0) {
                            return new TaskList(
                              document: snapshot.data.documents,
                              userId: userId,
                            );
                          } else {
                            return Container(
                              child: Center(
                                child: Text(
                                    'No prescriptions',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ));
    }
  }

}

class TaskList extends StatelessWidget {
  TaskList({this.document, this.userId});
  final List<DocumentSnapshot> document;
  final String userId;
  @override
  Widget build(BuildContext context) {
    ListView getNoteListView() {
      TextStyle titleStyle = Theme.of(context).textTheme.subhead;
      return ListView.builder(
        itemCount: document.length,
        itemBuilder: (BuildContext context, int position) {
          Prescription prescription=Prescription.fromDocument(document[position]);


          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: Container(
                decoration:
                BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0), child: Icon(Icons.description)),
                  title: Text('Disease:  ${prescription.disease}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal)),
                  subtitle: Text(
                      'Prescription: ${prescription.prescription} '
                          '\nNumber of courses: ${prescription.numberOfCourses}'
                          '\nTake ${prescription.takingPerDay} courses per day'
                          '\nEnding ${prescription.endDate}'
                          '\nStatus: ${prescription.status}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300)),


                ),
              ));
        },
      );
    }

    return getNoteListView();
  }
}
