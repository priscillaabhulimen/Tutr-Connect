import 'package:flutter/material.dart';
import 'package:tutr_connect/pages/chat/recent_chat.dart';
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
          Divider(
            height: 3.0,
            color: Colors.blue,
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('Courses'),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Chats'),
            onTap: () =>
                Navigator.push(
                context, MaterialPageRoute(builder: (context) => RecentChats())),
          ),
          Divider(
            height: 3.0,
            color: Colors.blue,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('FAQ'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Tut\'r Connect'),
          ),
        ],
      ),
    ),
      body: Text('Timeline'),
    );
  }
}
