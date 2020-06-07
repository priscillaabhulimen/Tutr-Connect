import 'package:cloud_firestore/cloud_firestore.dart';

class Course{
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
      students: doc['students'],
      tutors: doc['tutors'],
    );
  }
}