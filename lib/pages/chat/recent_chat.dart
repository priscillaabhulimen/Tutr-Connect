import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../home.dart';
import 'chat_screen.dart';

class RecentChats extends StatefulWidget {
  final String thisUserId;
  final String peerId;

  RecentChats({this.thisUserId, this.peerId});

  @override
  _RecentChatsState createState() => _RecentChatsState(
        thisUserId: this.thisUserId,
    peerId: peerId,
      );
}

class _RecentChatsState extends State<RecentChats> {
  final String thisUserId;
  final String peerId;

  _RecentChatsState({
    this.thisUserId,
    this.peerId
  });

  getRecentChats() async{
      QuerySnapshot snapshot = await messageFeedRef
          .document(currentUser.id)
          .collection('recents')
          .document(peerId)
          .collection('recentMessages')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .getDocuments();
      List<RecentChatItem> feedItems = [];
      snapshot.documents.forEach((doc) async {
          feedItems.add(RecentChatItem.fromDocument(doc));
      });
      return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Chats'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop
        ),
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

class RecentChatItem extends StatelessWidget {
  final String username;
  final String userId;
  final String peerName;
  final String peerId;
  final String peerAvatar;
  final String type; // 'read', 'unread'
  final String messageId;
  final String messageData;
  final Timestamp timestamp;

  RecentChatItem(
      {this.username,
        this.userId,
        this.peerName,
        this.peerId,
        this.peerAvatar,
        this.type,
        this.messageId,
        this.messageData,
        this.timestamp});

  factory RecentChatItem.fromDocument(DocumentSnapshot doc){
    return RecentChatItem(
      username: doc['username'],
      userId: doc['userId'],
      peerName: doc['peerName'],
      peerId: doc['peerId'],
      peerAvatar: doc['peerAvatar'],
      type: doc['type'],
      messageId: doc['messageId'],
      messageData: doc['messageData'],
      timestamp: doc['timestamp'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Chats(
            peerAvatar: peerAvatar,
            peerName: peerName,
            peerId: peerId,
            messageOwnerId: currentUser.id,
          ))),
          onLongPress: () => print('deleting chat'),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(peerAvatar),
            ),
            title: Text(messageData),
            trailing: Text(timeago.format(timestamp.toDate())),
          ),
        ),
      ),
    );
  }
}

