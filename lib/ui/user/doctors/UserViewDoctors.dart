import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/State.dart';
import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/ui/admin/AdminDrawer.dart';
import 'package:medicaltracker/ui/admin/admin/AddAdmin.dart';
import 'package:medicaltracker/ui/admin/doctor/AddDoctor.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/ui/user/UserDrawer.dart';
import 'package:medicaltracker/util/state_widget.dart';


class UserViewDoctors extends StatefulWidget {

  @override
  State createState() => _UserViewDoctorsState();
}

class _UserViewDoctorsState extends State<UserViewDoctors> {
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
          drawer: UserDrawer(),
          appBar: new AppBar(
            title: new Text('Doctors',
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
                          .collection(TABLE_USERS)
                          .where("access", isEqualTo: ACCESS_DOCTOR)
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
                                    'No $ACCESS_DOCTOR Added',
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
          User user=User.fromDocument(document[position]);

          if(userId==user.userId){
            return Container();
          }


          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: Container(
                decoration:
                BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0), child: Icon(Icons.person)),
                  title: Text('Name:  ${user.firstName} ${user.lastName}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal)),
                  subtitle: Text(
                      'Email: ${user.email} \nPhone: ${user.phonenumber} \nAddress:  ${user.address} \nStatus: ${user.status}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300)),

                  onTap: () {
                    debugPrint("ListTile Tapped");
                  },
                ),
              ));
        },
      );
    }

    return getNoteListView();
  }
}
