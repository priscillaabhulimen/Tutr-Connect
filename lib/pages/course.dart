import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/pages/student.dart';
import 'package:tutr_connect/pages/tutor.dart';
import 'package:tutr_connect/widgets/progress.dart';

class Course extends StatefulWidget {
  final String id;
  final dynamic tutors;
  final dynamic students;

  Course({
    this.id,
    this.tutors,
    this.students
  });

  factory Course.fromDocument(DocumentSnapshot doc) {
    return Course(
      id: doc['id'],
      tutors: doc['tutors'],
      students: doc['students'],
    );
  }
  @override
  _CourseState createState() => _CourseState(
    id: this.id,
    tutors: this.tutors,
    students: this.students
  );
}

class _CourseState extends State<Course> {
  final String currentUserId = currentUser?.id;
  final String id;
  bool isStudent;
  Map tutors;
  Map students;

  _CourseState({
    this.id,
    this.tutors,
    this.students
  });

  final courseRef = departmentRef
  .document(currentUser.department)
  .collection('programmes')
  .document(currentUser.program)
  .collection('levels')
  .document(currentUser.level)
  .collection('semester')
  .document(currentUser.currentSemester)
  .collection('Courses');

  getCourse() {
    return StreamBuilder<QuerySnapshot>(
      stream: courseRef.snapshots(),
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return circularProgress();
        } else{
          List<Container> coursesL = [];
          for (int i = 0; i < snapshot.data.documents.length; i++) {
            DocumentSnapshot snap = snapshot.data.documents[i];
            final studentsRef = departmentRef
            .document(currentUser.department)
            .collection('programmes')
            .document(currentUser.program)
            .collection('levels')
            .document(currentUser.level)
            .collection('semester')
            .document(currentUser.currentSemester)
            .collection('Courses')
            .document(snap.documentID)
            .collection('students');
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
                              showDialog(
                                context: this.context,
                                builder: (context){
                                  return SimpleDialog(
                                    title: Text('Register as...'),
                                    children: <Widget>[
                                      SimpleDialogOption(
                                        child: Text('Student'),
                                        onPressed: () {
                                          courseRef
                                          .document(snap.documentID)
                                          .collection('students')
                                          .document(currentUserId)
                                          .setData({
                                            'isStudent' : true,
                                          });
                                          Navigator.push(context, 
                                          MaterialPageRoute(
                                            builder: (context) => Student()
                                            )
                                          );
                                        },
                                      ),
                                      Divider(
                                        height: 2.0,
                                      ),
                                      SimpleDialogOption(
                                        child: Text('Tutor'),
                                        onPressed: (){
                                          courseRef
                                          .document(snap.documentID)
                                          .collection('tutors')
                                          .document(currentUserId)
                                          .setData({
                                            'isTutor' : true,
                                          });
                                          Navigator.push(context, 
                                          MaterialPageRoute(
                                            builder: (context) => Tutor()
                                            )
                                          );
                                        },
                                      ),
                                      Divider(
                                        height: 2.0,
                                      ),
                                      SimpleDialogOption(
                                        child: Text('Cancel'),
                                        onPressed: () => Navigator.pop(context)
                                      ),
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
    // isStudent = (widget.students[currentUserId] == true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses'
        ),
      ), 
      body: getCourse(),
    );
  }
}