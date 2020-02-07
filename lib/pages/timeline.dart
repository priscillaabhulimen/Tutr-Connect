import 'package:flutter/material.dart';
import 'package:tutr_connect/widgets/header.dart';
//import 'package:tutr_connect/widgets/progress.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      drawer: Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer'),
          ),
          ListTile(),
          ListTile(),
          ListTile(),
          ListTile(),
          ListTile(),
          ListTile(),
          ListTile(),
        ],
      ),
    ),
      body: Text('Timeline'),
    );
  }
}
