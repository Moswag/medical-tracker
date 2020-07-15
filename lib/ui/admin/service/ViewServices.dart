import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/MedicalService.dart';
import 'package:medicaltracker/ui/admin/AdminDrawer.dart';
import 'package:medicaltracker/ui/admin/service/AddService.dart';


class ViewServices extends StatefulWidget {
  ViewServices({this.user});
  final FirebaseUser user;

  @override
  State createState() => _ViewServicesState();
}

class _ViewServicesState extends State<ViewServices> {
  DateTime backButtonPressedTime;

  @override
  Widget build(BuildContext context) {


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
                        builder: (BuildContext ctx) => AddService()));
              },
            )
          ],
        ),
      ),
    );

    return Scaffold(
        drawer: AdminDrawer(),
        appBar: new AppBar(
          title: new Text('Services'),
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        bottomNavigationBar: makeBottom,
        body:  WillPopScope(
            onWillPop: onWillPop,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection(TABLE_SERVICES)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return new Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ));
                      } else {
                        if (snapshot.data.documents.length!=null &&snapshot.data.documents.length>0) {
                          return new TaskList(
                            document: snapshot.data.documents,
                          );
                        } else {
                          return Container(
                            child: Center(
                              child: Text('No Services Added',
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
  TaskList({this.document});
  final List<DocumentSnapshot> document;
  @override
  Widget build(BuildContext context) {
    ListView getNoteListView() {
      TextStyle titleStyle = Theme.of(context).textTheme.subhead;
      return ListView.builder(
        itemCount: document.length,
        itemBuilder: (BuildContext context, int position) {
          MedicalService service=MedicalService.fromDocument(document[position]);

          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: Container(
                decoration:
                BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                child: ListTile(
                  leading:   CachedNetworkImage(
                    imageUrl: service.imageUrl,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        CircularProgressIndicator(value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),


                  ),
                  title: Text("Name: " +service.name,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal)),
                  subtitle: Text(
                      'Description: ${service.description} \nHas Price: ${service.hasPrice.toString()} \nPrice:  ${service.price.toString()} \nStatus: ${service.status}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300)),
                  trailing: GestureDetector(
                    //to make the icon clickable and respond
                    child: Icon(Icons.delete, color: Colors.white, size: 25.0),
                    onTap: () {
                      Firestore.instance.collection(TABLE_SERVICES).document(service.id).delete();

                      Scaffold.of(context).showSnackBar(
                          new SnackBar(content: new Text('Service Deleted')));
                    },
                  ),
                  onTap: () {
                    debugPrint("ListTile Tapped");
//                    Navigator.of(context).push(MaterialPageRoute(
//                        builder: (BuildContext context)=>new EditController(
//                          name:  name,
//                          email: email,
//                          nationalId: nationalId ,
//                          phonenumber: phonenumber,
//                          index: document[positon].reference,
//                        )));
                  },
                ),
              ));
        },
      );
    }

    return getNoteListView();
  }
}
