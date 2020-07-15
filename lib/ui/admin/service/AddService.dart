import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/model/MedicalService.dart';
import 'package:medicaltracker/model/State.dart';
import 'package:medicaltracker/repository/ServiceRepository.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/util/alert_dialog.dart';
import 'package:medicaltracker/util/loading.dart';
import 'package:medicaltracker/util/state_widget.dart';
import 'package:medicaltracker/util/validator.dart';
import 'package:path/path.dart' as Path;
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';

class AddService extends StatefulWidget {
  AddService({this.email});

  final String email;

  @override
  State createState() => _AddProjectState();
}

class _AddProjectState extends State<AddService> {
  StateModel appState;
  bool _autoValidate = false;
  bool _loadingVisible = false;
  String startDate, endDate;
  String _fileName;
  String _path;
  File file;
  bool toggleValue = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();

  Future<File> imageFile;

  chooseImage() {
    setState(() {
      imageFile = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.hasData) {
          file = snapshot.data;
          return Image.file(
            snapshot.data,
            fit: BoxFit.fill,
          );
        } else if (snapshot.hasError) {
          return Text('Error picking image', textAlign: TextAlign.center);
        } else {
          return Text(
            'No image',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  String getExtension(String basename) {
    return lookupMimeType(basename);
  }

  Future _addService({MedicalService service}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();

        service.date = DateTime.now().toString();

        String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
            Path.basename(file.path);
        String myChild = FOLDER_SERVICES + fileName;
        final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(myChild);
        final StorageUploadTask task = firebaseStorageRef.putFile(file);
        StorageTaskSnapshot storageTaskSnapshot = await task.onComplete;
        String url = await storageTaskSnapshot.ref.getDownloadURL();

        // String url = firebaseStorageRef.getDownloadURL().toString();

        if (url != null) {
          service.imageUrl = url;

          var id = utf8.encode(service.name +
              service.description +
              service.imageUrl); // data being hashed

          service.id = sha1.convert(id).toString();

          ServiceRepository.addService(service).then((onValue) {
            if (onValue) {
              AlertDiag.showAlertDialog(context, 'Status',
                  'Service Successfully Added', AdminRoutes.VIEW_SERVICES);
            } else {
              AlertDiag.showAlertDialog(
                  context,
                  'Status',
                  'Failed to add Service, please contact developer',
                  AdminRoutes.VIEW_SERVICES);
            }
          });
        }
      } catch (e) {
        print("Adding Error: $e");
        Flushbar(
            title: "Adding Service Error",
            message: e,
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
    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return SignInPage();
    } else {
      final userId = appState?.firebaseUserAuth?.uid ?? '';

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
        keyboardType: TextInputType.text,
        controller: nameController,
        validator: Validator.validateName,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.title,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Name',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final descriptionField = TextFormField(
          autofocus: false,
          maxLines: 3,
          keyboardType: TextInputType.text,
          controller: descriptionController,
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
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ));

      final toggle = Center(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 1000),
          height: 40.0,
          width: 100.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: toggleValue
                  ? Colors.greenAccent[100]
                  : Colors.redAccent[100].withOpacity(0.5)),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeIn,
                top: 3.0,
                left: toggleValue ? 60.0 : 0.0,
                right: toggleValue ? 0.0 : 60.0,
                child: InkWell(
                  onTap: toggleButton,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 1000),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return RotationTransition(child: child, turns: animation);
                    },
                    child: toggleValue
                        ? Icon(Icons.check_circle,
                        color: Colors.green, size: 35.0, key: UniqueKey())
                        : Icon(Icons.remove_circle_outline,
                        color: Colors.red, size: 35.0, key: UniqueKey()),
                  ),
                ),
              )
            ],
          ),
        ),
      );

      final hasPriceField = Container(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Row(children: <Widget>[
            new Expanded(
              flex: 1,
              child: Text(''),
            ),
            new Expanded(
              flex: 2,
              child: Text(
                'Service Has Price?',
              ),
            ),
            Expanded(
                flex: 3,
                child: Container(
                    padding: EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                    child: toggle)),
          ]));

      final amountField = TextFormField(
        autofocus: false,
        keyboardType:
        TextInputType.numberWithOptions(signed: false, decimal: true),
        controller: priceController,
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter amount';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.attach_money,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Price',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );



      final priceField = Visibility(
          visible: toggleValue,
          child: Container(
              padding: EdgeInsets.only(bottom: 16.0),
              child: amountField));

      final docField = Container(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Row(children: <Widget>[
            new Expanded(
              flex: 1,
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Service Picture',
                  ),
                  onPressed: () {
                    chooseImage();
                  }),
            ),
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                  child: showImage(),
                )),
          ]));

      final submitButton = Expanded(
        child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: primaryColor,
            textColor: Theme.of(context).primaryColorLight,
            child: Text(
              'Save',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              setState(() {
                debugPrint("Save clicked");
                MedicalService service = new MedicalService();
                service.addedBy = userId;
                service.name = nameController.text;
                service.description = descriptionController.text;
                service.hasPrice = toggleValue;
                if (toggleValue) {
                  service.price = double.parse(priceController.text);
                }
                service.status = STATUS_ACTIVE;

                _addService(service: service);
              });
            }),
      );

      final cancelButton = Expanded(
        child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: redColor,
            textColor: Theme.of(context).primaryColorLight,
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

      Form form = Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    header,
                    SizedBox(height: 10.0),
                    nameField,
                    SizedBox(height: 24.0),
                    descriptionField,
                    SizedBox(height: 24.0),
                    hasPriceField,
                    SizedBox(height: 24.0),
                    priceField,
                    SizedBox(height: 24.0),
                    docField,
                    SizedBox(height: 24.0),
//                    showImage(),
//                    SizedBox(height: 24.0),
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
              )));

      return WillPopScope(
          onWillPop: () {
            moveToLastScreen();
          },
          child: Scaffold(
              appBar: new AppBar(
                elevation: 0.1,
                backgroundColor: primaryColor,
                title: Text('Add Service'),
              ),
              body: LoadingScreen(
                child: form,
                inAsyncCall: _loadingVisible,
              )));
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

  toggleButton() {
    setState(() {
      toggleValue = !toggleValue;
    });
  }
}
