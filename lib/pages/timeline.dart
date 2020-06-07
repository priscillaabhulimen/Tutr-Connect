import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/models/user.dart';
import 'package:tutr_connect/pages/course_model.dart';
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/pages/search.dart';
import 'package:tutr_connect/widgets/header.dart';
import 'package:tutr_connect/widgets/post.dart';
import 'package:tutr_connect/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) { 
      return buildUsersToFollow();
    } else {
      return ListView(children: posts);
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          final bool isNotInUserProgram = currentUser.program != user.program;
          final bool isNotInUserLevel = currentUser.level != user.level;
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else if (isNotInUserProgram && isNotInUserLevel) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          color: Theme.of(context).accentColor.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Users to Follow",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(children: userResults),
            ],
          ),
        );
      },
    );
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text (currentUser.displayName), 
                accountEmail: Text (currentUser.email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
                ),
              ),
              ListTile(
                leading: Icon(Icons.library_books),
                title: Text('Courses'),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Courses()
                    )
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About'),
                onTap: (){},
              ),
              Padding(
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              ListTile(
                leading: Icon(Icons.question_answer),
                title: Text('FAQ'),
                onTap: (){},
              ),
              Padding(
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.clear,
                  color: Color(0xFFFF000B),
                  ),
                title: Text('Logout'),
                onTap: logout,
              )
            ],
          )
        ),
        body: RefreshIndicator(
            onRefresh: () => getTimeline(), child: buildTimeline()));
  }
}

