import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/models/user.dart';
import 'package:tutr_connect/pages/chat/chat_screen.dart';
import 'package:tutr_connect/widgets/progress.dart';

import 'home.dart';

class Tutor extends StatefulWidget {
  String courseId;

  Tutor({this.courseId});

  @override
  _TutorState createState() => _TutorState(
    courseId: this.courseId
  );
}

class _TutorState extends State<Tutor> {
  String courseId;
  User student;

  _TutorState({this.courseId});

  getStudents() {
    return StreamBuilder<QuerySnapshot>(
      stream: courseRef
      .document(courseId)
      .collection('Tutors')
      .document(currentUser.id)
      .collection('Students')
      .snapshots(),
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return circularProgress();
        } else if (snapshot.data.documents.length == 0){
          return Container(
          color: Colors.white,
          child: Center(
             child: Text(
              'No students available',
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
          List<StudentResult> studentResults = [];
          snapshot.data.documents.forEach((snap){
            student = User.fromDocument(snap);
            StudentResult studentResult = StudentResult(student, courseId);
            studentResults.add(studentResult);
            // print(studentResults);
          });
          // print('reached');
          return Container(
            color: Colors.grey.withOpacity(0.6),
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              children: studentResults,
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
        title: Text('View students'),
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
                      courseRef
                        .document(courseId)
                        .collection('Tutors')
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
      body: getStudents(),
        );
  }
}

class StudentResult extends StatelessWidget {
  final User student;
  final String courseId;

  StudentResult(this.student, this.courseId);

  @override
  Widget build(BuildContext context) {
   return Container(
      margin: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0)
      ),
      height: 150.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CircleAvatar(
              radius: 40.0,
              backgroundColor: Theme.of(context).accentColor,
              backgroundImage: CachedNetworkImageProvider(student.photoUrl),
            ),
          ),
          SizedBox(height: 8.0),
          Center(
            child: Text(
              student.username,
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor
              ),
            )
          ),
          SizedBox(height: 8.0),
          GestureDetector(
                  onTap: () {
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => Chats(
                      peerName: student.username,
                      peerId: student.id,
                      peerAvatar: student.photoUrl,
                      messageOwnerId: currentUser.id,
                    )));
                  },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0)
                      ),
                      height: 40.0,
                      width: 120.0,
                      child: Center(
                        child: Text(
                          'Send a message',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                        ),
                      ),
                  ),
                ),
        ],
      ),
    );
  }
}