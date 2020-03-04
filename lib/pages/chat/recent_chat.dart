import 'package:flutter/material.dart';
import 'package:tutr_connect/widgets/progress.dart';

class RecentChats extends StatefulWidget {
  final String thisUserId;

  RecentChats({this.thisUserId});

  @override
  _RecentChatsState createState() => _RecentChatsState(
        thisUserId: this.thisUserId,
      );
}

class _RecentChatsState extends State<RecentChats> {
  final String thisUserId;

  _RecentChatsState({
    this.thisUserId,
  });

  getRecentChats(){
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00C3C3),
      appBar: AppBar(
        title: Text('Recent Chats'),
      ),
      body: FutureBuilder(
          future: getRecentChats(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          }),
    );
  }
}
