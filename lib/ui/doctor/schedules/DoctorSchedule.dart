import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
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
import 'package:medicaltracker/constants/db_constants.dart';
import 'package:medicaltracker/model/BookedService.dart';
import 'package:medicaltracker/model/Emergency.dart';
import 'package:medicaltracker/model/State.dart';
import 'dart:async';

import 'package:medicaltracker/model/User.dart';
import 'package:medicaltracker/repository/BookedServiceRepository.dart';
import 'package:medicaltracker/repository/EmergencyRepository.dart';
import 'package:medicaltracker/repository/UserRepository.dart';
import 'package:medicaltracker/ui/admin/emergency/ViewOnMap.dart';
import 'package:medicaltracker/ui/chat/chat.dart';
import 'package:medicaltracker/ui/doctor/schedules/AddPrescription.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/util/alert_dialog.dart';
import 'package:medicaltracker/util/auth.dart';
import 'package:medicaltracker/util/loading.dart';
import 'package:medicaltracker/util/state_widget.dart';
import 'package:medicaltracker/util/validator.dart';


class DoctorSchedule extends StatefulWidget {
  DoctorSchedule({this.bookedService});

  final BookedService bookedService;

  @override
  State createState() => _ViewScheduleState();
}

class _ViewScheduleState extends State<DoctorSchedule> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  String doctor;

  StateModel appState;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController serviceController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController surnameController = new TextEditingController();
  TextEditingController phonenumberController = new TextEditingController();
  TextEditingController reasonController = new TextEditingController();
  TextEditingController startTimeController = new TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController statusController = new TextEditingController();

   User user;

  _asyncMethod() async {
     user = await UserRepository.getUser(widget.bookedService.patient);
    nameController.text='Name: '+user.firstName;
    surnameController.text='Surname: '+user.lastName;
    phonenumberController.text="Mobile: "+user.phonenumber;
    startTimeController.text=widget.bookedService.startTime;
    endTimeController.text=widget.bookedService.endTime;
    reasonController.text="Reason: "+widget.bookedService.reason;
    statusController.text="Status: "+widget.bookedService.doctorStatus;
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
    appState = StateWidget.of(context).state;
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

      final reasonField = TextFormField(
        keyboardType: TextInputType.number,
        readOnly: true,
        controller: reasonController,
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

      final startTimeField = Container(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                  child: Text(
                    "Start Time",
                  ),
                )),
            new Expanded(
                flex: 4,
                child: TextFormField(
                    controller: startTimeController,
                    validator: Validator.validateField,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Icon(
                          Icons.date_range,
                          color: Colors.grey,
                        ), // icon is 48px widget.
                      ), // icon is 48px widget.
                      hintText: "Pick Start Time",
                      contentPadding: EdgeInsets.fromLTRB(
                          20.0, 10.0, 20.0, 10.0),
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
                        String tim = DateTimeField.combine(date, time)
                            .toString();
                        startTimeController.text = tim;
                      }
                    })

            ),

          ],
        ),
      );


      final endTimeField = Container(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                  child: Text(
                    "End Time",
                  ),
                )),
            new Expanded(
                flex: 4,
                child: TextFormField(
                    controller: endTimeController,
                    validator: Validator.validateField,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Icon(
                          Icons.date_range,
                          color: Colors.grey,
                        ), // icon is 48px widget.
                      ), // icon is 48px widget.
                      hintText: "End Time",
                      contentPadding: EdgeInsets.fromLTRB(
                          20.0, 10.0, 20.0, 10.0),
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
                        String tim = DateTimeField.combine(date, time)
                            .toString();
                        endTimeController.text = tim;
                      }
                    })

            ),

          ],
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
              'Add Prescription',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              setState(() {
                debugPrint("Going to add prescription");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext ctx) =>
                            AddPrescription(
                              bookedService: widget.bookedService,)));
              });
            }),
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
              'Chat',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              setState(() {
                debugPrint("Going to chat with Patient");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Chat(
                              peerId: widget.bookedService.patient,
                              name: user.firstName+' '+user.lastName,
                              peerAvatar: '',
                              userId: userId,
                            )));
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
                    nameField,
                    SizedBox(height: 24.0),
                    surnameField,
                    SizedBox(height: 24.0),
                    phonenumberField,
                    SizedBox(height: 24.0),
                    reasonField,
                    SizedBox(height: 24.0),
                    startTimeField,
                    SizedBox(height: 24.0),
                    endTimeField,
                    SizedBox(height: 24.0),
                    statusField,
                    Visibility(
                      visible:
                      widget.bookedService.doctorStatus == STATUS_PENDING
                          ? true
                          : false,
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
          title: Text('View Schedule'),
        ),
        body: LoadingScreen(
            child: form,
            inAsyncCall: _loadingVisible),
      );
    }
  }

}
