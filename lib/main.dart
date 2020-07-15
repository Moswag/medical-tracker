import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/DoctorRoutes.dart';
import 'package:medicaltracker/constants/UserRoutes.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/ui/admin/admin/ViewAdmins.dart';
import 'package:medicaltracker/ui/admin/doctor/ViewDoctors.dart';
import 'package:medicaltracker/ui/admin/emergency/AdminViewEmergencies.dart';
import 'package:medicaltracker/ui/admin/patients/ViewPatients.dart';
import 'package:medicaltracker/ui/admin/schedules/ViewSchedules.dart';
import 'package:medicaltracker/ui/admin/service/ViewServices.dart';
import 'package:medicaltracker/ui/doctor/schedules/DoctorViewSchedules.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/ui/signup.dart';
import 'package:medicaltracker/ui/splashscreen.dart';
import 'package:medicaltracker/ui/user/book_service/UserViewBookings.dart';
import 'package:medicaltracker/ui/user/doctors/UserViewDoctors.dart';
import 'package:medicaltracker/ui/user/emergencies/ViewEmergencies.dart';
import 'package:medicaltracker/ui/user/services/UserViewServices.dart';
import 'package:medicaltracker/util/state_widget.dart';

void main() {
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );

  runApp(stateWidget);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login",
      theme: ThemeData(primaryColor: Colors.orange[200]),
      routes: <String, WidgetBuilder>{
        SPLASH_SCREEN: (BuildContext context) =>  SplashScreen(),
        SIGN_IN: (BuildContext context) =>  SignInPage(),
        SIGN_UP: (BuildContext context) =>  SignUpScreen(),

        //admin
        AdminRoutes.VIEW_ADMINS: (BuildContext context) =>  ViewAdmins(),
        AdminRoutes.VIEW_DOCTORS:  (BuildContext context) =>  ViewDoctors(),
        AdminRoutes.VIEW_PATIENTS:  (BuildContext context) =>  ViewPatients(),
        AdminRoutes.VIEW_SERVICES:  (BuildContext context) =>  ViewServices(),
        AdminRoutes.VIEW_SCHEDULES:  (BuildContext context) =>  ViewSchedules(),
        AdminRoutes.VIEW_EMERGENCIES:  (BuildContext context) =>  AdminViewEmergencies(),

        //user
        UserRoutes.VIEW_SERVICES:  (BuildContext context) =>  UserViewServices(),
        UserRoutes.BOOKED_SERVICES:  (BuildContext context) =>  UserViewBookings(),
        UserRoutes.VIEW_MY_EMERGENCIES:  (BuildContext context) =>  ViewEmergencies(),
        UserRoutes.VIEW_DOCTORS:  (BuildContext context) =>  UserViewDoctors(),


        //doctor
        DoctorRoutes.VIEW_SCHEDULES:  (BuildContext context) =>  DoctorViewSchedules(),
        DoctorRoutes.VIEW_PATIENT_HISTORY:  (BuildContext context) =>  DoctorViewSchedules(),
        DoctorRoutes.VIEW_CHATS:  (BuildContext context) =>  DoctorViewSchedules(),

      },
      initialRoute: SPLASH_SCREEN,
    );
  }
}



