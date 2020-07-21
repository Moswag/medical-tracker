import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/Emergency.dart';
import 'package:medicaltracker/model/State.dart';
import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/ui/admin/AdminDrawer.dart';
import 'package:medicaltracker/ui/admin/admin/AddAdmin.dart';
import 'package:medicaltracker/ui/admin/emergency/ViewEmergency.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/ui/user/UserDrawer.dart';
import 'package:medicaltracker/ui/user/emergencies/ReportEmergency.dart';
import 'package:medicaltracker/util/state_widget.dart';


class AdminViewEmergencies extends StatefulWidget {

  @override
  State createState() => _ViewEmergenciesState();
}

class _ViewEmergenciesState extends State<AdminViewEmergencies> {
  DateTime backButtonPressedTime;
  StateModel appState;

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


      return Scaffold(
          drawer: AdminDrawer(),
          appBar: new AppBar(
            title: new Text('Emergencies',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: primaryColor,
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          body: WillPopScope(
              onWillPop: onWillPop,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: StreamBuilder(
                      stream: Firestore.instance
                          .collection(TABLE_EMERGENCY)
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
                                    'No Emergency Recorded',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              )));
    }
  }
  Future<bool> onWillPop() async{
    DateTime currentTime=DateTime.now();

    bool backButton=backButtonPressedTime==null ||
        currentTime.difference(backButtonPressedTime)>Duration(seconds: 3);

    if(backButton){
      backButtonPressedTime=currentTime;
      Fluttertoast.showToast(
          msg: "Double click to exit app",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return false;
    }
    Navigator.pop(context, 1);
    return true;
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
          Emergency emergency=Emergency.fromDocument(document[position]);



          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: Container(
                decoration:
                BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0), child: Icon(Icons.person)),
                  title: Text('Address:  ${emergency.address}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal)),
                  subtitle: Text(
                      'Time: ${emergency.date}  \nStatus: ${emergency.status}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300)),
                  onTap: (){
                    print('Emergency clicked');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext ctx) =>
                                ViewEmergency(emergency: emergency,)));
                  },


                ),
              ));
        },
      );
    }

    return getNoteListView();
  }
}
