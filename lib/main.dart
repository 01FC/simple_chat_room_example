import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat room",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: Colors.grey[50],
      ),
      home: LoginPage(),
    );
  }
}
