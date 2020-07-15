import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/UserRoutes.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/model/Emergency.dart';
import 'dart:async';

import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/repository/EmergencyRepository.dart';
import 'package:medicaltracker/repository/UserRepository.dart';
import 'package:medicaltracker/ui/admin/emergency/ViewOnMap.dart';
import 'package:medicaltracker/util/alert_dialog.dart';
import 'package:medicaltracker/util/auth.dart';
import 'package:medicaltracker/util/loading.dart';
import 'package:medicaltracker/util/validator.dart';


class ViewEmergency extends StatefulWidget {
  ViewEmergency({this.emergency});

  final Emergency emergency;

  @override
  State createState() => _ViewEmergencyState();
}

class _ViewEmergencyState extends State<ViewEmergency> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  String workerCategory;
  bool isWorker=false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController surnameController = new TextEditingController();
  TextEditingController phonenumberController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController statusController = new TextEditingController();


  Future _addData(
      {Emergency emergency}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();


        EmergencyRepository.updateEmergency(emergency).then((onValue) {
          if (onValue) {
            AlertDiag.showAlertDialog(context, 'Status',
                'Emergency Successfully Updated To Attended',AdminRoutes.VIEW_EMERGENCIES);
          } else {
            AlertDiag.showAlertDialog(
                context,
                'Status',
                'Failed to book Service, please contact developer',
                UserRoutes.BOOKED_SERVICES);
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

  _asyncMethod() async {
    final User user = await UserRepository.getUser(widget.emergency.patient);
    nameController.text='Name: '+user.firstName;
    surnameController.text='Surname: '+user.lastName;
    phonenumberController.text="Mobile: "+user.phonenumber;
    addressController.text="Emergency Address: "+widget.emergency.address;
    statusController.text="Status: "+widget.emergency.status;
  }
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //define form fields
    final header = Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(LOGO),
            fit: BoxFit.cover),
        color: Colors.white30,
      ),
    );



    final nameField = TextFormField(
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      controller: nameController,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final surnameField = TextFormField(
      autofocus: false,
      readOnly: true,
      textCapitalization: TextCapitalization.words,
      controller: surnameController,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Surname',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );



    final phonenumberField = TextFormField(
      keyboardType: TextInputType.number,
      readOnly: true,
      controller: phonenumberController,
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

    final addressField = TextFormField(
      autofocus: false,
      readOnly: true,
      textCapitalization: TextCapitalization.words,
      controller: addressController,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Address',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final statusField = TextFormField(
      autofocus: false,
      readOnly: true,
      controller: statusController,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Status',
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
            'Attented',
            textScaleFactor: 1.5,
          ),
          onPressed: () {
            setState(() {
              debugPrint("Save clicked");
              widget.emergency.status=STATUS_ATTENDED;
              _addData(
                  emergency: widget.emergency);
            });
          }),
    );

    final cancelButton = Expanded(
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: greyColor,
          textColor: Theme.of(context).primaryColorLight,
          child: Text(
            'View Map',
            textScaleFactor: 1.5,
          ),
          onPressed: () {
            setState(() {
              debugPrint("Cancel button clicked");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewOnMap(emergency: widget.emergency,)
                  ));
            });
          }),
    );

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
                  nameField,
                  SizedBox(height: 24.0),
                  surnameField,
                  SizedBox(height: 24.0),
                  phonenumberField,
                  SizedBox(height: 24.0),
                  addressField,
                  SizedBox(height: 24.0),
                  statusField,
                Visibility(
                  visible:
                  widget.emergency.status== STATUS_PENDING ? true : false,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        submitButton,
                        Container(
                          width: 5.0,
                        ), //for adding space between buttons
                        cancelButton
                      ],
                    ),
                  ),
                )
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
            title: Text('View Emergency'),
          ),
          body: LoadingScreen(
              child: form,
              inAsyncCall: _loadingVisible),
        );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
  void _onCategoryItemSelected(String newValueSelected) {
    setState(() {
      this.workerCategory = newValueSelected;
    });
  }

}
