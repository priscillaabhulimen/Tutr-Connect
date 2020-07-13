import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/models/user.dart';
import 'package:tutr_connect/pages/activity_feed.dart';
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/widgets/progress.dart';

class Student extends StatefulWidget {
  String courseId;

  Student({this.courseId});
  
  @override
  _StudentState createState() => _StudentState(
    courseId: this.courseId
  );
}

class _StudentState extends State<Student> {
  String courseId;
  User tutor;

  _StudentState({this.courseId});

  getTutors() {
    return StreamBuilder<QuerySnapshot>(
      stream: courseRef
      .document(courseId)
      .collection('Tutors')
      .snapshots(),
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return circularProgress();
        } else if(snapshot.data.documents.length == 0) {
          return Container(
          color: Colors.white,
          child: Center(
             child: Text(
              'No tutors available',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 30.0
              ),
            ),
          )
        );
        } else{
          List<TutorResult> tutorResults = [];
          snapshot.data.documents.forEach((snap){
            tutor = User.fromDocument(snap);
            TutorResult tutorResult = TutorResult(tutor, courseId);
            tutorResults.add(tutorResult);
          });
          return Container(
            child: ListView(
              children: tutorResults,
            )
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find a tutor'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){ 
          showDialog(
            context: context,
            builder: (context){
              return SimpleDialog(
                title: Text('Are you sure you want to unenroll?'),
                children: <Widget>[
                  SimpleDialogOption(
                    child: Text('Yes'),
                    onPressed: (){
                      courseRef
                        .document(courseId)
                        .collection('Registered')
                        .document(currentUser.id)
                        .delete();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  ),
                  SimpleDialogOption(
                    child: Text('No'),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            }
          );
        },
        child: Icon(
          Icons.clear
        )
      ),
      body: getTutors(),
    );
  }
}

class TutorResult extends StatelessWidget {
  final User tutor;
  final String courseId;

  TutorResult(this.tutor, this.courseId);

  addRequestToActivityFeed(){
    activityFeedRef.document(tutor.id).collection('feedItems').add({
      'type': 'request',
      'tutorId': tutor.id,
      'postId': courseId,
      'username': currentUser.username,
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': DateTime.now()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(4.0),
      color: Color(0xFF73DAFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top:8.0, left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      backgroundImage: CachedNetworkImageProvider(tutor.photoUrl),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          tutor.displayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left:16.0, top: 5.0, bottom: 5.0),
                    child: GestureDetector(
                      onTap: () => showProfile(context, profileId: tutor.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          height: 40.0,
                          width: 180.0,
                          child: Center(
                            child: Text(
                              'View Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                ),
                            ),
                          ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left:16.0, top: 5.0, bottom: 5.0),
                    child: GestureDetector(
                      onTap: (){
                        // print('Sent request!');
                        addRequestToActivityFeed();
                      },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          height: 40.0,
                          width: 180.0,
                          child: Center(
                            child: Text(
                              'Send request',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ),
                      ),
                    ),
                  ),
                ]
              )
            ] 
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}

