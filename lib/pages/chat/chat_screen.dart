import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/widgets/progress.dart';

class Chats extends StatefulWidget {
  final String peerName;
  final String peerId;
  final String peerAvatar;
  final String messageOwnerId;

  Chats({this.peerName, this.peerId, this.peerAvatar, this.messageOwnerId});

  @override
  _ChatsState createState() => _ChatsState(
        peerName: this.peerName,
        peerId: this.peerId,
        peerAvatar: peerAvatar,
      );
}

class _ChatsState extends State<Chats> {
  final String peerName;
  final String peerId;
  final String peerAvatar;
  final String messageId;
  final String messageOwnerId;
  Future<QuerySnapshot> searchResultsFuture;
  TextEditingController messageController = TextEditingController();

  _ChatsState({
    this.peerName,
    this.peerId,
    this.peerAvatar,
    this.messageId,
    this.messageOwnerId,
  });

  addMessage() {
    bool isMessageSender = messageOwnerId != peerId;
    if (isMessageSender) {
      addMessageSent();
    } else {
      addMessageReceived();
    }
  }

  buildMessages() {
    return StreamBuilder(
        stream: messagesRef
            .document(currentUser.id)
            .collection('messages')
            .document(peerId)
            .collection('userMessages')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            List<Message> messages = [];
            snapshot.data.documents.forEach((doc) {
              messages.add(Message.fromDocument(doc));
            });
            return ListView(
              children: messages,
            );
          }
        });
  }

  addMessageSent() {
    // add sent message to peer document as received; sent by current
    messagesRef
        .document(currentUser.id)
        .collection('messages')
        .document(peerId)
        .collection('userMessages')
        .add({
      'senderName': currentUser.username,
      'receiverName': peerName,
      'message': messageController.text,
      'timestamp': timestamp,
      'senderAvatar': currentUser.photoUrl,
      'receiverId': peerId,
      'messageType': 'sending'
    });
    // add sent message to current user document as sent; received by peer
    messagesRef
        .document(peerId)
        .collection('messages')
        .document(currentUser.id)
        .collection('userMessages')
        .add({
      'senderName': currentUser.username,
      'receiverName': peerName,
      'message': messageController.text,
      'timestamp': timestamp,
      'senderAvatar': currentUser.photoUrl,
      'receiverId': peerId,
      'messageType': 'receiving'
    });
    messageController.clear();
  }

  addMessageReceived() {
    // add received message to current user document as received; received by current
    messagesRef
        .document(peerId)
        .collection('messages')
        .document(currentUser.id)
        .collection('userMessages')
        .add({
      'senderName': peerName,
      'receiverName': currentUser.username,
      'message': messageController.text,
      'timestamp': timestamp,
      'senderAvatar': peerAvatar,
      'receiverId': currentUser.id,
      'messageType': 'sending'
    });
    // add received message to current user document as sent; sent by peer
    messagesRef
        .document(currentUser.id)
        .collection('messages')
        .document(peerId)
        .collection('userMessages')
        .add({
      'senderName': peerName,
      'receiverName': currentUser.username,
      'message': messageController.text,
      'timestamp': timestamp,
      'senderAvatar': peerAvatar,
      'receiverId': currentUser.id,
      'messageType': 'receiving'
    });
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(peerName),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: buildMessages()),
            Divider(
              height: 2.0,
              color: Colors.grey,
            ),
            ListTile(
              title: TextFormField(
                controller: messageController,
                decoration: InputDecoration(labelText: 'Write a message...'),
                textCapitalization: TextCapitalization.sentences,
              ),
              trailing: IconButton(
                icon: Icon(Icons.send),
                onPressed: addMessage,
              ),
            ),
          ],
        ));
  }
}

class Message extends StatelessWidget {
  final String senderName;
  final String receiverId;
  final String senderAvatar;
  final String message;
  final String messageType;
  final Timestamp timestamp;

  Message(
      {this.senderName,
      this.receiverId,
      this.senderAvatar,
      this.message,
      this.timestamp,
      this.messageType});

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      senderName: doc['senderName'],
      receiverId: doc['receiverId'],
      senderAvatar: doc['senderAvatar'],
      message: doc['message'],
      timestamp: doc['timestamp'],
      messageType: doc['messageType'],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasAvatar = senderAvatar != null;
    return Column(
      crossAxisAlignment: messageType == 'sending'
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: messageType == 'sending'
              ? EdgeInsets.only(left: 40.0, top: 4.0)
              : EdgeInsets.only(right: 40.0, top: 4.0),
          decoration: BoxDecoration(
              color: messageType == 'sending'
                  ? Color(0xFFB0E0E6)
                  : Theme.of(context).accentColor,
              borderRadius: messageType == 'sending'
                  ? BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      bottomLeft: Radius.circular(25.0))
                  : BorderRadius.only(
                      topRight: Radius.circular(25.0),
                      bottomRight: Radius.circular(25.0))),
          child: ListTile(
            leading: messageType == 'sending'
                ? CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(senderAvatar),
                  )
                : Text(timeago.format(timestamp.toDate()),
                    style: TextStyle(fontSize: 10.0, fontFamily: 'Raleway')),
            title: Text(
              message,
              style: TextStyle(fontSize: 12.0, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
            ),
            trailing: messageType == 'sending'
                ? Text(
                    timeago.format(timestamp.toDate()),
                    style: TextStyle(fontSize: 10.0, fontFamily: 'Raleway'),
                  )
                : CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(senderAvatar),
                  ),
          ),
        )
      ],
    );
  }
}
