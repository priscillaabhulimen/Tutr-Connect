import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/pages/post_screen.dart';
import 'package:tutr_connect/pages/profile.dart';
import 'package:tutr_connect/widgets/header.dart';
import 'package:tutr_connect/widgets/progress.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  bool isEmpty = true;

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(60)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.3),
      appBar: header(context, titleText: 'Activity Feed'),
      body: FutureBuilder(
          future: getActivityFeed(),
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

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // 'like', 'follow', 'comment', 'request', 'accepted', 'message'
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem(
      {this.username,
      this.userId,
      this.type,
      this.mediaUrl,
      this.postId,
      this.userProfileImg,
      this.commentData,
      this.timestamp});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
    );
  }

  showPost(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postId: postId,
                  userId: userId,
                )));
  }

  configureMediaPreview(context) async{
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(mediaUrl),
              )),
            ),
          ),
        ),
      );
    } else if(type == 'request'){
      mediaPreview = GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context){
                            return SimpleDialog(
                              title: Text('I would like to...'),
                              children: <Widget>[
                                SimpleDialogOption(
                                  child: Text('Accept'),
                                  onPressed: (){
                                    courseRef
                                    .document(postId)
                                    .collection('Tutors')
                                    .document(currentUser.id)
                                    .collection('Students')
                                    .document(userId)
                                    .setData({
                                      'id': userId,
                                      'username': username,
                                      'photoUrl': userProfileImg
                                    });
                                    activityFeedRef.document(userId).collection('feedItems').add({
                                      'type': 'accepted',
                                      'studentId': userId,
                                      'postId': postId,
                                      'username': currentUser.username,
                                      'userId': currentUser.id,
                                      'userProfileImg': currentUser.photoUrl,
                                      'timestamp': DateTime.now()
                                    });
                                    Navigator.pop(context);
                                    Scaffold.of(context).showSnackBar(SnackBar(content: 
                                      Text(
                                        'You accepted the request!', 
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )); 
                                  }
                                ),
                                Divider(
                                  height: 2.0,
                                ),
                                SimpleDialogOption(
                                  child: Text(
                                    'Decline',
                                    style: TextStyle(color: Colors.red)
                                  ),
                                  onPressed: (){
                                    activityFeedRef.document(userId).collection('feedItems').add({
                                      'type': 'declined',
                                      'studentId': userId,
                                      'postId': postId,
                                      'username': currentUser.username,
                                      'userId': currentUser.id,
                                      'userProfileImg': currentUser.photoUrl,
                                      'timestamp': DateTime.now()
                                    });
                                    Navigator.pop(context);
                                    Scaffold.of(context).showSnackBar(SnackBar(content: 
                                      Text(
                                        'You declined the request!', 
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ));
                                  },
                                )
                              ],
                            );
                          }
                        );
                      },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          height: 40.0,
                          width: 60.0,
                          child: Center(
                            child: Text(
                              'Respond',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                ),
                            ),
                          ),
                      ),
                    );
    } else{
      mediaPreview = Text('');
    }

    if (type == 'like') {
      activityItemText = 'liked your post';
    } else if (type == 'follow') {
      activityItemText = 'is following you';
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else if (type == 'request'){
      activityItemText = 'needs a tutorial in $postId';
    } else if (type == 'accepted'){
      activityItemText = 'accepted your $postId request';
    }else if (type == 'declined'){
      activityItemText = 'declined your $postId request';
    } else if (type == 'message'){
      activityItemText = 'sent you a message';
    } else {
      activityItemText = "Error: Unknown type'$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        margin: EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0)
        ),
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Raleway',
                    fontSize: MediaQuery.of(context).size.width / 30,
                  ),
                  children: [
                    TextSpan(
                        text: username,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: ' $activityItemText',
                    )
                  ]),
            ),
          ),
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => Profile(profileId: profileId)));
}
