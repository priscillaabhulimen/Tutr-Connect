import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/models/course.dart';
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/widgets/progress.dart';

class Courses extends StatefulWidget {
  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  final courseRef = departmentRef
  .document(currentUser.department)
  .collection('programmes')
  .document(currentUser.program)
  .collection('levels')
  .document(currentUser.level)
  .collection('semester')
  .document(currentUser.currentSemester)
  .collection('Courses');

  getCourses() {
    return StreamBuilder<QuerySnapshot>(
      stream: courseRef.snapshots(),
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return circularProgress();
        } else{
          List<Container> coursesL = [];
          for (int i = 0; i < snapshot.data.documents.length; i++){
            DocumentSnapshot snap = snapshot.data.documents[i];
            coursesL.add(
              Container(
                margin: EdgeInsets.only(top:10.0, left: 8.0, right: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                height: 150.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        snap.documentID,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Center(
                        child:  GestureDetector(
                            onTap: (){
                              print('Registered!');
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
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                  ),
                              )
                                ),
                          ),
                    )
                  ]
                )
              )
            );
            courseRef.document(snap.documentID).setData({
              'id': snap.documentID,
            });
          }
          return Container(
            color: Colors.grey.withOpacity(0.6),
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                ),
              children: coursesL,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses'
        ),
      ), 
      body: getCourses(),
    );
  }
}