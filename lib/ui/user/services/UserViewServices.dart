import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/MedicalService.dart';
import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/repository/ServiceRepository.dart';
import 'package:medicaltracker/ui/user/UserDrawer.dart';
import 'package:medicaltracker/ui/user/book_service/BookService.dart';


class UserViewServices extends StatefulWidget {
  @override
  _UserViewServicesState createState() => _UserViewServicesState();
}

class _UserViewServicesState extends State<UserViewServices> {


  @override
  Widget build(BuildContext context) {


    Widget card(MedicalService medicalService) {
      return Card(
          color: Colors.white,
          elevation: 0,
          child: InkWell(
              child: Center(
                child: Column(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: medicalService.imageUrl,
                      width: 200,
                      height: 120,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Center(child:CircularProgressIndicator(value: downloadProgress.progress)),
                      errorWidget: (context, url, error) => Icon(Icons.error),

                    ),
                    Text(medicalService.name,
                        style: TextStyle(
                            color: Color(0xFF000000),
                            fontFamily: 'Roboto-Light.ttf',
                            fontSize: 12))
                  ],
                ),
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookService(
                        medicalService: medicalService,
                      )),
                );
              }));
      ;
    }


    return Scaffold(
          drawer: UserDrawer(),
          appBar: new AppBar(
            title: new Text('Services',
                style: TextStyle(color: Colors.white),
          ),
      centerTitle: true,
      backgroundColor: primaryColor,
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),

        body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
              children: <Widget>[
          Expanded(
          child: StreamBuilder(
              stream: Firestore.instance
              .collection(TABLE_SERVICES)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: const Text('Loading services...'));
            }
            return GridView.builder(
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                MedicalService medicalService=MedicalService.fromDocument(snapshot.data.documents[index]);
                return card(medicalService);
              },

            );
          },
        ))
        ],
      ),
    ),)
    ,
    );
  }
}