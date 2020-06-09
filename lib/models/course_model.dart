import 'package:cloud_firestore/cloud_firestore.dart';

class Courses {
  final String id;
  final dynamic tutors;
  final dynamic students;

  Courses({
    this.id,
    this.tutors,
    this.students
  });

  factory Courses.fromDocument(DocumentSnapshot doc) {
    return Courses(
      id: doc['id'],
      tutors: doc['tutors'],
      students: doc['students'],
    );
  }
}