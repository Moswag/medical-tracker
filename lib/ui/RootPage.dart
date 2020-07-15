import 'package:flutter/material.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/model/State.dart';
import 'package:medicaltracker/ui/admin/admin/ViewAdmins.dart';
import 'package:medicaltracker/ui/doctor/schedules/DoctorViewSchedules.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/ui/user/services/UserViewServices.dart';
import 'package:medicaltracker/util/auth.dart';
import 'package:medicaltracker/util/state_widget.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State createState() => _RootPageState();
}

enum AuthStatus { notSignedIn, signedIn }

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  StateModel appState;
  bool _loadingVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
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
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }

      final userId = appState?.firebaseUserAuth?.uid ?? '';
      final email = appState?.firebaseUserAuth?.email ?? '';
      final name = appState?.user?.firstName ?? '';
      final surname = appState?.user?.lastName ?? '';
      final access = appState?.user?.access ?? '';

      switch (authStatus) {
        case AuthStatus.notSignedIn:
          return new SignInPage();

        case AuthStatus.signedIn:
          if (access == ACCESS_ADMIN) {
            return ViewAdmins();
          } else if (access == ACCESS_DOCTOR) {
            return DoctorViewSchedules();
          } else if (access == ACCESS_USER) {
            return UserViewServices();
          } else {
            return CircularProgressIndicator();
          }
      }
    }
  }
}
