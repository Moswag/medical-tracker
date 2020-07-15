import 'package:flutter/material.dart';
import 'package:medicaltracker/constants/AdminRoutes.dart';
import 'package:medicaltracker/constants/UserRoutes.dart';
import 'package:medicaltracker/constants/color_const.dart';
import 'package:medicaltracker/constants/constants.dart';
import 'package:medicaltracker/model/State.dart';
import 'package:medicaltracker/ui/signin.dart';
import 'package:medicaltracker/util/auth.dart';
import 'package:medicaltracker/util/state_widget.dart';

class UserDrawer extends StatelessWidget {
  UserDrawer({this.auth, this.onSignedOut});

  final Auth auth;
  final VoidCallback onSignedOut;

  StateModel appState;
  bool _loadingVisible = false;

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

      void _signOut() async {
        try {
          await Auth.signOut();
          Navigator.of(context).pop();
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new SignInScreen()));
        } catch (e) {
          print(e);
        }
      }

      void showAlertDialog() {
        AlertDialog alertDialog = AlertDialog(
            title: Text('Status'),
            content: Text('Are you sure you want to logout from Medical Tracker'),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      new FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: primaryColor,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Ok',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          _signOut(); //signout
                        },
                      ),
                      Container(
                        width: 5.0,
                      ),
                      new FlatButton(
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
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ))
            ]);

        showDialog(context: context, builder: (_) => alertDialog);
      }

      return new Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: Stack(children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Image.asset(
                        LOGO,
                        width: 130,
                        height: 130,
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 12.0,
                      left: 16.0,
                      child: Text('${name} ${surname} [ ${access} ]',
                          style: TextStyle(
                              color: Color(0xFF545454),
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500))),
                ])),
            new ListTile(
              leading: Icon(Icons.person),
              title: new Text('Doctors'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, UserRoutes.VIEW_DOCTORS);
              },
            ),
            new ListTile(
              leading: Icon(Icons.person),
              title: new Text('Services'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context,UserRoutes.VIEW_SERVICES);
              },
            ),

            new ListTile(
              leading: Icon(Icons.payment),
              title: new Text('Schedules'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, UserRoutes.BOOKED_SERVICES);
              },
            ),
            new ListTile(
              leading: Icon(Icons.note),
              title: new Text('Emergencies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context,UserRoutes.VIEW_MY_EMERGENCIES);
              },
            ),
            new ListTile(
              leading: Icon(Icons.note),
              title: new Text('Prescriptions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context,UserRoutes.VIEW_MY_EMERGENCIES);
              },
            ),
            new ListTile(
              leading: Icon(Icons.panorama_fish_eye),
              title: new Text('Health Tips'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, UserRoutes.VIEW_MY_EMERGENCIES);
              },
            ),
            new ListTile(
              leading: Icon(Icons.all_out),
              title: new Text('Logout'),
              onTap: () {
                //Navigator.pop(context);
                showAlertDialog(); // _signOut();
              },
            )
          ],
        ),
      );
    }
  }
}
