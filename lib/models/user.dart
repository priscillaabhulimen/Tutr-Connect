import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String rating;
  final String matriculationNumber;
  final String department;
  final String program;
  final String level;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.rating,
    this.matriculationNumber,
    this.department,
    this.program,
    this.level,
});

  factory User.fromDocument(DocumentSnapshot doc){
      return User(
        id: doc['id'],
        email: doc['email'],
        username: doc['username'],
        photoUrl: doc['photoUrl'],
        displayName: doc['display name'],
        rating: doc['rating'],
        matriculationNumber: doc['matricNumber'],
        department: doc['department'],
        program: doc['program'],
        level: doc['level']
      );
  }

}
