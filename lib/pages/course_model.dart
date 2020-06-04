import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutr_connect/pages/home.dart';

class Course extends StatefulWidget {
  final String id;
  final dynamic tutors;
  final dynamic students;

  Course({
    this.id,
    this.tutors,
    this.students});

  factory Course.fromDocument(DocumentSnapshot doc){
      return Course(
        id: doc['id'],
        tutors: doc['tutors'],
        students: doc['students'],
      );
  }

  int getTutorCount(tutors) {
    // if no tutors, return 0
    if (tutors == null) {
      return 0;
    }
    int count = 0;
    // if key is set to true, add a tutor
    tutors.values.forEach((val){
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  int getStudentCount(students) {
    // if no students, return 0
    if (students == null) {
      return 0;
    }
    int count = 0;
    // if key is set to true, add a student
    students.values.forEach((val){
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _CourseState createState() => _CourseState(
    id: this.id,
    tutors: this.tutors,
    tutorCount: getTutorCount(this.tutors),
    students: this.students,
    studentCount: getStudentCount(this.students)
  );
}

class _CourseState extends State<Course> {
   final String id;
   Map tutors;
   Map students;
   int tutorCount;
   int studentCount;

  _CourseState({
    this.id,
    this.tutors,
    this.students,
    this.tutorCount,
    this.studentCount,
  });

  handleRegisterForCourse() async{
    bool _isStudent = students[currentUser.id] == true;
    bool _isTutor = tutors[currentUser.id] == true;
    //TODO figure out if it need to do anything here
    if (!_isStudent) {
      coursesRef
      .document(currentUser.id)
      .updateData({'students.$currentUser.id': false});
    }
    else if(!_isTutor){
      coursesRef
      .document(currentUser.id)
      .updateData({'tutors.$currentUser.id': false});
    }
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[],
        ),
      ),
    );
  }
}

