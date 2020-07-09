import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/pages/student.dart';
import 'package:tutr_connect/pages/tutor.dart';
import 'package:tutr_connect/widgets/progress.dart';

class Course extends StatefulWidget {
  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends State<Course> {
  final String currentUserId = currentUser?.id; 
  String courseId;
  Registered regUser;
  bool registered = true;
  bool isStudent = false;
  bool isTutor = false;

  
  final courseRef = departmentRef
  .document(currentUser.department)
  .collection('programmes')
  .document(currentUser.program)
  .collection('levels')
  .document(currentUser.level)
  .collection('semester')
  .document(currentUser.currentSemester)
  .collection('Courses');


  isRegistered(courseId) async{
     DocumentSnapshot registeredUser = await courseRef
     .document(courseId)
     .collection('Registered')
     .document(currentUser.id)
     .get();
     regUser = Registered.fromDocument(registeredUser);
            if (registeredUser.exists){
              registered = true;
              
              print(regUser.isStudent);
              isTutor = regUser.isTutor;
              isStudent = regUser.isStudent;

            } else {
              registered = false;
            }
  }
  

  getCourse() {
    return StreamBuilder<QuerySnapshot>(
      stream: courseRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData){
          return circularProgress();
        } else{
          List<Container> coursesL = [];
          for (int i = 0; i < snapshot.data.documents.length; i++) {
            DocumentSnapshot snap = snapshot.data.documents[i];
            isRegistered(snap.documentID);
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
                              registered ? Navigator.push(context, 
                              MaterialPageRoute(
                                builder: (context) => isStudent ? Student() : Tutor()
                                ))
                              : showDialog(
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
                                          .collection('Registered')
                                          .document(currentUserId)
                                          .setData({
                                            'isStudent' : true,
                                            'isTutor': false
                                          });
                                          Navigator.pop(context);
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
                                          .collection('Registered')
                                          .document(currentUserId)
                                          .setData({
                                            'isStudent': false,
                                            'isTutor' : true,
                                          });
                                          Navigator.pop(context);
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
                                  'Access',
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
      body: getCourse(),
    );
  }
}

class Registered {
  final bool isStudent;
  final bool isTutor;

  Registered({
    this.isStudent,
    this.isTutor,
  });

  factory Registered.fromDocument(DocumentSnapshot doc){
    return Registered(
      isStudent: doc['isStudent'],
      isTutor: doc['isTutor'],
      );
  }
}