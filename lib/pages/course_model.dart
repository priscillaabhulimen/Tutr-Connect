import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  getCourses() async{
    await courseRef
      .document()
      .setData({
        'title': 'Mastering Flutter',
        'description': 'Programming Guide for Dart'
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses'
        ),
      ),      
    );
  }
}