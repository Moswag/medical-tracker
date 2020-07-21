import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'dart:async';

import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/repository/UserRepository.dart';
import 'package:medicaltracker/ui/doctor/DoctorDrawer.dart';
import 'package:medicaltracker/ui/doctor/history/PatientHistory.dart';
import 'package:medicaltracker/util/alert_dialog.dart';
import 'package:medicaltracker/util/auth.dart';
import 'package:medicaltracker/util/loading.dart';
import 'package:medicaltracker/util/validator.dart';

class EnterPatient extends StatefulWidget {
  @override
  State createState() => _EnterPatientState();
}

class _EnterPatientState extends State<EnterPatient> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  String workerCategory;
  bool isWorker = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phonenumberController = new TextEditingController();

  Future _addData({String phoneNumber}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();

        UserRepository.userWithPhoneExist(phoneNumber)
            .then((QuerySnapshot snapshot) async {
          if (snapshot.documents.isNotEmpty) {
            var userDataData = snapshot.documents[0].data;
            User user = new User(
              status: userDataData['status'],
              address: userDataData['address'],
              email: userDataData['email'],
              access: userDataData['access'],
              phonenumber: userDataData['phonenumber'],
              lastName: userDataData['lastName'],
              firstName: userDataData['firstName'],
              userId: userDataData['userId'],
              serviceId: userDataData['serviceId'],
            );
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PatientHistory(
                          user: user,
                        )));
          } else {
            Flushbar(
                    title: "Search Found Nothing",
                    message: 'User with such phonenumber do not exist',
                    duration: Duration(seconds: 5))
                .show(context);
          }
        });
      } catch (e) {
        print("Sign Up Error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
                title: "Sign Up Error",
                message: exception,
                duration: Duration(seconds: 5))
            .show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //define form fields

    final header = Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(LOGO), fit: BoxFit.cover),
        color: Colors.white30,
      ),
    );

    final phonenumberField = TextFormField(
      keyboardType: TextInputType.number,
      autofocus: false,
      controller: phonenumberController,
      validator: Validator.validateMobile,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.phone,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Phonenumber',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final submitButton = Expanded(
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: primaryColor,
          textColor: Theme.of(context).primaryColorLight,
          child: Text(
            'Search',
            textScaleFactor: 1.5,
          ),
          onPressed: () {
            setState(() {
              debugPrint("Save clicked");
              String phoneNumber = phonenumberController.text;
              _addData(phoneNumber: phoneNumber);
            });
          }),
    );

//    Form form = new Form(
//        key: _formKey,
//        autovalidate: _autoValidate,
//        child: Padding(
//            padding: const EdgeInsets.only(top: 0.0),
//            child: SingleChildScrollView(
//              child: Column(
//                children: <Widget>[
//                  header,
//                  SizedBox(height: 48.0),
//                  phonenumberField,
//                  SizedBox(height: 24.0),
//                  submitButton,
//                ],
//              ),
//            )));

    Form form=new Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  header,
                  SizedBox(height: 48.0),
                  phonenumberField,
                  SizedBox(height: 24.0),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        submitButton,
                        Container(
                          width: 5.0,
                        ), //for adding space between buttons

                      ],
                    ),
                  ),
//                  diseaseField,
//                  SizedBox(height: 24.0),
//                  prescriptionField,
//                  SizedBox(height: 24.0),
//                  numOfCoursesField,
//                  SizedBox(height: 24.0),
//                  perDayField,
//                  SizedBox(height: 24.0),
//                  endDateField,
//                  SizedBox(height: 24.0),

                ],
              ),
            )
        )

    );


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        elevation: 0.1,
        backgroundColor: primaryColor,
        title: Text('Search Patient History'),
      ),
      drawer: DoctorDrawer(),
      body: LoadingScreen(child: form, inAsyncCall: _loadingVisible),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }
}
