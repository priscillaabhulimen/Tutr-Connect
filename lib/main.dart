import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/pages/home.dart';


void main() {
  runApp(MyApp());
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    print('Timestamps enabled in snapshots\n');
  }, onError: (_){
    print('Error enabling timestamps in snapshots\n');
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutr Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF301BFF),
        accentColor: Color(0xFFFFA0F9)
      ),
      home: Home()
    );
  }
}

