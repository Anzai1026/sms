import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sms/firebase_options.dart';
import 'package:sms/firestore/user_firestore.dart';
import 'package:sms/pages/auth_page.dart';
import 'package:sms/utils/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Shared Preferences
  await SharedPrefs.setPrefsInstance();

  // Fetch UID and create user if not exist
  String? uid = SharedPrefs.fetchUid();
  if (uid == null) {
    await UserFirestore.createUser();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color set to blue
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}
