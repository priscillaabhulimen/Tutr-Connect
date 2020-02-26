import 'package:flutter/material.dart';
import 'package:tutr_connect/pages/home.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutr Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF4A23FF),
        accentColor: Color(0xFFFF69F5)
      ),
      home: Home()
    );
  }
}
