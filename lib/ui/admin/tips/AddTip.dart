import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/model/HealthTip.dart';
import 'package:medicaltracker/model/State.dart';
import 'dart:async';

import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/repository/HealthTipRepository.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/util/alert_dialog.dart';
import 'package:medicaltracker/util/auth.dart';
import 'package:medicaltracker/util/loading.dart';
import 'package:medicaltracker/util/state_widget.dart';
import 'package:medicaltracker/util/validator.dart';


class AddTip extends StatefulWidget {
  @override
  State createState() => _AddTipState();
}

class _AddTipState extends State<AddTip> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  String workerCategory;
  bool isWorker=false;
  StateModel appState;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController tipController = new TextEditingController();



  Future _addData(
      {HealthTip healthTip,
       }) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();

        var id = utf8.encode(healthTip.tip +
            healthTip.addedBy); // data being hashed
        healthTip.id = sha1.convert(id).toString();

        HealthTipRepository.addTip(healthTip).then((onValue){
          if(onValue){
            AlertDiag.showAlertDialog(context, 'Status',
                'Healthy tip Successfully Added', AdminRoutes.VIEW_HEALTH_TIPS);
          }
          else{
            AlertDiag.showAlertDialog(
                context,
                'Status',
                'Failed to add Service, please contact developer',
                AdminRoutes.VIEW_HEALTH_TIPS);
          }

        });


      } catch (e) {
        print("Adding error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
            title: "Adding Error",
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
      //define form fields
      final backButton = IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          moveToLastScreen();
        },
      );
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


      final tipField = TextFormField(
        autofocus: false,
        textCapitalization: TextCapitalization.words,
        controller: tipController,
        validator: Validator.validateField,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.description,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Description',
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
            textColor: Theme
                .of(context)
                .primaryColorLight,
            child: Text(
              'Save',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              setState(() {
                debugPrint("Save clicked");
                HealthTip healthTip = new HealthTip(
                    tip: tipController.text,
                    date: DateTime.now().toString(),
                    status: STATUS_ACTIVE,
                    addedBy: userId
                );


                _addData(
                  healthTip: healthTip,
                );
              });
            }),
      );

      final cancelButton = Expanded(
        child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: redColor,
            textColor: Theme
                .of(context)
                .primaryColorLight,
            child: Text(
              'Cancel',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              setState(() {
                debugPrint("Cancel button clicked");
                Navigator.pop(context);
              });
            }),
      );

      Form form = new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    header,
                    SizedBox(height: 48.0),
                    tipField,
                    Padding(
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
              title: Text('Add Health Tip'),
            ),
            body: LoadingScreen(
                child: form,
                inAsyncCall: _loadingVisible),
          );
    }
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
