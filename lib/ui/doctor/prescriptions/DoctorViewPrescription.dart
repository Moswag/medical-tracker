import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/DoctorRoutes.dart';
import 'package:medicaltracker/constants/UserRoutes.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/BookedService.dart';
import 'package:medicaltracker/model/Emergency.dart';
import 'package:medicaltracker/model/Prescription.dart';
import 'package:medicaltracker/model/PrescriptionFeedback.dart';
import 'package:medicaltracker/model/State.dart';
import 'dart:async';

import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/repository/BookedServiceRepository.dart';
import 'package:medicaltracker/repository/EmergencyRepository.dart';
import 'package:medicaltracker/repository/FeedbackRepository.dart';
import 'package:medicaltracker/repository/PrescriptionRepository.dart';
import 'package:medicaltracker/repository/UserRepository.dart';
import 'package:medicaltracker/ui/admin/emergency/ViewOnMap.dart';
import 'package:medicaltracker/ui/chat/chat.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/ui/user/prescriptions/AddPrescriptionFeedback.dart';
import 'package:medicaltracker/util/alert_dialog.dart';
import 'package:medicaltracker/util/auth.dart';
import 'package:medicaltracker/util/loading.dart';
import 'package:medicaltracker/util/state_widget.dart';
import 'package:medicaltracker/util/validator.dart';


class DoctorViewPrescription extends StatefulWidget {
  DoctorViewPrescription({this.prescription});

  final Prescription prescription;

  @override
  State createState() => _ViewScheduleState();
}

class _ViewScheduleState extends State<DoctorViewPrescription> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  String doctor;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController reasonController = new TextEditingController();
  TextEditingController diseaseController = new TextEditingController();
  TextEditingController prescriptionController = new TextEditingController();
  TextEditingController endDateController = new TextEditingController();
  TextEditingController numOfCoursesController = TextEditingController();
  TextEditingController perDayController = new TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController statusController = new TextEditingController();
  TextEditingController feedbackController = new TextEditingController();


  User user;
  BookedService bookedService;
  PrescriptionFeedback prescriptionFeedback;
  StateModel appState;

//  Future _addData(
//      {Prescription prescription,}) async {
//    if (_formKey.currentState.validate()) {
//      try {
//        SystemChannels.textInput.invokeMethod('TextInput.hide');
//        await _changeLoadingVisible();
//        var id = utf8.encode(prescription.prescription +
//            prescription.disease +
//            prescription.startDate+ prescription.endDate); // data being hashed
//
//        prescription.id = sha1.convert(id).toString();
//        PrescriptionRepository.addPrescription(prescription).then((onValue) {
//          if (onValue) {
//            //update doctor appointment
//            widget.bookedService.doctorStatus=STATUS_ATTENDED;
//            BookedServiceRepository.updateSchedule(widget.bookedService).then((onValue) {
//              if (onValue) {
//                AlertDiag.showAlertDialog(context, 'Status',
//                    'Prescription Successfully saved',
//                    DoctorRoutes.VIEW_SCHEDULES);
//              }else{
//                AlertDiag.showAlertDialog(
//                    context,
//                    'Status',
//                    'Failed to update schedule, please contact developer',
//                    DoctorRoutes.VIEW_SCHEDULES);
//              }
//            });
//          } else {
//            AlertDiag.showAlertDialog(
//                context,
//                'Status',
//                'Failed to Add prescription, please contact developer',
//                DoctorRoutes.VIEW_SCHEDULES);
//          }
//        });
//
//      } catch (e) {
//        print("Sign Up Error: $e");
//        Flushbar(
//            title: "Error",
//            message: "Error occured",
//            duration: Duration(seconds: 5))
//            .show(context);
//      }
//    } else {
//      setState(() => _autoValidate = true);
//    }
//  }

  _asyncMethod() async {
    bookedService = await BookedServiceRepository.getService(widget.prescription.scheduleId);


    user = await UserRepository.getUser(widget.prescription.patientId);
    nameController.text='Patient Name: '+user.firstName+' '+user.lastName;
    reasonController.text='Reason: '+bookedService.reason;
    diseaseController.text='Disease Name: '+widget.prescription.disease;
    prescriptionController.text='Prescription: '+widget.prescription.prescription;
    numOfCoursesController.text='Number Of Courses: '+widget.prescription.numberOfCourses;
    perDayController.text='Take '+widget.prescription.takingPerDay+' courses per day';
    startDateController.text='Start Date: '+widget.prescription.startDate;
    endDateController.text='End Date: '+widget.prescription.endDate;
    statusController.text='Status: '+widget.prescription.status;

    if(widget.prescription.hasFeedBack) {
      prescriptionFeedback = await FeedbackRepository.getFeedBack(widget.prescription.id);
      feedbackController.text='Feedback: '+prescriptionFeedback.feedback;
    }
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

      final reasonField = TextFormField(
        autofocus: false,
        textCapitalization: TextCapitalization.words,
        controller: reasonController,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.description,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Reason',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final diseaseField = TextFormField(
        autofocus: false,
        readOnly: true,
        textCapitalization: TextCapitalization.words,
        controller: diseaseController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.trip_origin,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Disease',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );


      final prescriptionField = TextFormField(
        autofocus: false,
        readOnly: true,
        textCapitalization: TextCapitalization.words,
        controller: prescriptionController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.description,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Prescription',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );


      final numOfCoursesField = TextFormField(
        readOnly: true,
        keyboardType: TextInputType.number,
        controller: numOfCoursesController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.settings_system_daydream,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Number Of Courses',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final perDayField = TextFormField(
        readOnly: true,
        keyboardType: TextInputType.number,
        controller: perDayController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.star,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Course Per Day',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final startDateField = TextFormField(
        readOnly: true,
        keyboardType: TextInputType.number,
        controller: startDateController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.date_range,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Start Date',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );
      final endDateField = TextFormField(
        readOnly: true,
        keyboardType: TextInputType.number,
        controller: endDateController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.date_range,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'End Date',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );


      final statusField = TextFormField(
        readOnly: true,
        keyboardType: TextInputType.number,
        controller: statusController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Status',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final feedbackField = TextFormField(
        readOnly: true,
        keyboardType: TextInputType.text,
        controller: feedbackController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.feedback,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Feedback',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );




      final cancelButton = Expanded(
        child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: greyColor,
            textColor: Theme
                .of(context)
                .primaryColorLight,
            child: Text(
              'Chat With Patient',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Chat(
                            peerId: widget.prescription.patientId,
                            name: user.firstName + ' ' + user.lastName,
                            peerAvatar: '',
                            userId: userId,
                          )));
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
                    nameField,
                    SizedBox(height: 24.0),
                    reasonField,
                    SizedBox(height: 24.0),
                    diseaseField,
                    SizedBox(height: 24.0),
                    prescriptionField,
                    SizedBox(height: 24.0),
                    numOfCoursesField,
                    SizedBox(height: 24.0),
                    perDayField,
                    SizedBox(height: 24.0),
                    startDateField,
                    SizedBox(height: 24.0),
                    endDateField,
                    SizedBox(height: 24.0),
                    statusField,
                    SizedBox(height: 24.0),
                    Visibility(
                      visible:
                      widget.prescription.hasFeedBack,
                      child:
                      feedbackField,
                    ),
                    SizedBox(height: 24.0),
                    Visibility(
                      visible:
                      widget.prescription.status == STATUS_PENDING
                          ? true
                          : false,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: <Widget>[
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
          title: Text('View Schedule'),
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
      this.doctor = newValueSelected;
    });
  }

}
