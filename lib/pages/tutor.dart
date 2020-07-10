import 'package:flutter/material.dart';

class Tutor extends StatefulWidget {
  @override
  _TutorState createState() => _TutorState();
}

class _TutorState extends State<Tutor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View students'),
      ),
      body: Column(children: <Widget>[
        Expanded(
                  child: Container(
          color: Colors.black,
          ),
        ),
        GestureDetector(child: Container(
          color: Colors.grey,
          child: Text('Unenroll'),),)
      ],)
    );
  }
}