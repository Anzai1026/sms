import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sms/firebase_options.dart';
import 'package:sms/firestore/room_firestore.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/pages/auth_page.dart';
import 'package:sms/utils/shared_prefs.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPrefs.setPrefsInstance();
  String? uid = SharedPrefs.fetchUid();
  if(uid == null) await UserFirestore.createUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // ここで色を変更する
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}