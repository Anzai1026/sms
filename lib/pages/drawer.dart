import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sms/pages/account_page.dart';
import 'package:sms/pages/auth_page.dart';
import 'package:sms/pages/login_or_register_page.dart';
import 'package:sms/pages/setting_profile_page.dart';

import 'home_page.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();

  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: [
          DrawerHeader(
            child: Image.asset(
              'lib/images/ALIEN.png',
              width: 100,
              height: 100,
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(left: 25.0),
          //   child: ListTile(
          //     title: Text("H O M E"),
          //     leading: Icon(Icons.home),
          //     onTap: () {
          //       Navigator.push(
          //           context, MaterialPageRoute(builder: (context) => HomePage()));
          //     },
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.only(left: 25.0),
          //   child: ListTile(
          //     title: Text("S E T T I N G"),
          //     leading: Icon(Icons.settings),
          //     onTap: () {
          //       Navigator.pop(context);
          //
          //       Navigator.push(
          //           context,
          //         MaterialPageRoute(builder: (context) => SettingProfilePage())
          //       );
          //     },
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.only(left: 25.0),
          //   child: ListTile(
          //     title: Text("P R O F I L E"),
          //     leading: Icon(Icons.account_circle),
          //     onTap: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(builder: (context) => AccountPage())
          //       );
          //     },
          //   ),
          // ),
        ],),
        Padding(
          padding: EdgeInsets.only(left: 25.0, bottom: 25),
          child: ListTile(
            title: Text("L O G O U T"),
            leading: Icon(Icons.logout),
            onTap: () {
              signUserOut();
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()));
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthPage()) , (_) => false);
            },
          ),
        ),
      ],
    ),
    );
  }
}
