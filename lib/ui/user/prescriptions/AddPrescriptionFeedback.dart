import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/UserRoutes.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/BookedService.dart';
import 'package:medicaltracker/model/MedicalService.dart';
import 'package:medicaltracker/model/Prescription.dart';
import 'package:medicaltracker/model/PrescriptionFeedback.dart';
import 'package:medicaltracker/model/State.dart';
import 'dart:async';

import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/repository/BookedServiceRepository.dart';
import 'package:medicaltracker/repository/FeedbackRepository.dart';
import 'package:medicaltracker/repository/PrescriptionRepository.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/util/alert_dialog.dart';
import 'package:medicaltracker/util/auth.dart';
import 'package:medicaltracker/util/loading.dart';
import 'package:medicaltracker/util/state_widget.dart';
import 'package:medicaltracker/util/validator.dart';


class AddPrescriptionFeedback extends StatefulWidget {
  AddPrescriptionFeedback({this.prescription});

  final Prescription prescription;
  @override
  State createState() => _BookServiceState();
}

class _BookServiceState extends State<AddPrescriptionFeedback> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  String workerCategory;
  bool isWorker=false;
  StateModel appState;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController diseaseController = new TextEditingController();
  TextEditingController feedbackController = new TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();

  final format = DateFormat("yyyy-MM-dd HH:mm");


  _asyncMethod(){
    diseaseController.text='Disease Name: '+widget.prescription.disease;
  }

  Future _addData(
      {PrescriptionFeedback prescriptionFeedback,
      }) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();

        var id = utf8.encode(prescriptionFeedback.patientId +prescriptionFeedback.prescriptionId ); // data being hashed

        prescriptionFeedback.id = prescriptionFeedback.prescriptionId;

        FeedbackRepository.addFeedback(prescriptionFeedback).then((onValue) {
          if (onValue) {
            widget.prescription.hasFeedBack=true;
            PrescriptionRepository.updatePrescription(widget.prescription).then((onValue) {
              if (onValue) {
                AlertDiag.showAlertDialog(context, 'Status',
                    'Prescription feedback Successfully Added',
                    UserRoutes.VIEW_PRESCRIPTIONS);
              }
              else{
                AlertDiag.showAlertDialog(
                    context,
                    'Status',
                    'Failed to update prescription, please contact developer',
                    UserRoutes.VIEW_PRESCRIPTIONS);
              }
            });
          } else {
            AlertDiag.showAlertDialog(
                context,
                'Status',
                'Failed to add feedback, please contact developer',
                UserRoutes.VIEW_PRESCRIPTIONS);
          }
        });

      } catch (e) {
        print("Booking Service: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
            title: "Booking Service Error",
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
    _asyncMethod();
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


      final diseaseField = TextFormField(
        keyboardType: TextInputType.text,
        autofocus: false,
        readOnly: true,
        controller: diseaseController,
        validator: Validator.validateField,
        maxLines: 3,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.description,
              color: Colors.grey,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Feedback',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );


      final reasonField = TextFormField(
        keyboardType: TextInputType.text,
        autofocus: false,
        controller: feedbackController,
        validator: Validator.validateField,
        maxLines: 3,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.feedback,
              color: Colors.grey,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Feedback',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final datePickerField = TextFormField(
          controller: dateTimeController,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Icon(
                Icons.date_range,
                color: Colors.grey,
              ), // icon is 48px widget.
            ), // icon is 48px widget.
            hintText: 'Date and Time of Job',
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0)),
          ),
          onTap: () async {
            FocusScope.of(context).requestFocus(new FocusNode());
            final date = await showDatePicker(
                context: context,
                firstDate: DateTime(DateTime
                    .now()
                    .year),
                initialDate: DateTime.now(),
                lastDate: DateTime(2100));
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(DateTime.now()),
              );
              String tim = DateTimeField.combine(date, time).toString();
              dateTimeController.text = tim;
            }
          });


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
                PrescriptionFeedback prescriptionFeedback = new PrescriptionFeedback(
                  date: DateTime.now().toString(),
                  patientId: widget.prescription.patientId,
                  feedback: feedbackController.text,
                  prescriptionId: widget.prescription.id
                );

                _addData(
                  prescriptionFeedback: prescriptionFeedback,
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
                feedbackController.text='';
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
                    diseaseField,
                    SizedBox(height: 24.0),
                    reasonField,
                    SizedBox(height: 24.0),
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

      return  Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          elevation: 0.1,
          backgroundColor: primaryColor,
          title: Text('Add Feedback'),
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

}
