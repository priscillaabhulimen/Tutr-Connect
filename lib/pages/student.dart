import 'package:flutter/material.dart';

class Student extends StatefulWidget {
  @override
  _StudentState createState() => _StudentState();
}

class _StudentState extends State<Student> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find a tutor'),
      ),
      body: Container(
        color: Colors.black,
      ),
    );
  }
}