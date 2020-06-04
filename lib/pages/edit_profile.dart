import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:tutr_connect/models/user.dart';
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var selectedDepartment, selectedProgram, selectedLevel;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController matricNumberController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user
        .displayName; // to put the user's display name n the text field immediately
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Display name',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
              hintText: 'Update Display name',
              errorText: _displayNameValid ? null : 'Display name too short'),
        )
      ],
    );
  }

  buildMatricNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Display name',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
            ),
          ),
        ),
        TextField(
          controller: matricNumberController,
          decoration: InputDecoration(hintText: 'Update Matric number'),
        )
      ],
    );
  }

  buildDepartmentDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('departments')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading...');
        } else {
          List<DropdownMenuItem> departmentItems = [];
          for (int i = 0;
              i < snapshot.data.documents.length;
              i++) {
            DocumentSnapshot snap =
                snapshot.data.documents[i];
            departmentItems.add(DropdownMenuItem(
              child: Text(
                snap.documentID,
                style: TextStyle(
                  color:
                      Theme.of(context).primaryColor,
                  fontFamily: 'Raleway',
                ),
              ),
              value: '${snap.documentID}',
            ));
          }
          return DropdownButton(
            items: departmentItems,
            onChanged: (departmentValue) {
              setState(() {
                selectedDepartment = departmentValue;
              });
            },
            value: selectedDepartment,
            isExpanded: false,
            hint: new Text(
              'Choose your department',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontFamily: 'Raleway'),
            ),
          );
        }
      },
    );
  }

  buildProgramDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('departments')
          .document(selectedDepartment)
          .collection('programmes')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading...');
        } else {
          List<DropdownMenuItem> programItems = [];
          for (int i = 0;
              i < snapshot.data.documents.length;
              i++) {
            DocumentSnapshot snap =
                snapshot.data.documents[i];
            programItems.add(DropdownMenuItem(
              child: Text(
                snap.documentID,
                style: TextStyle(
                  color:
                      Theme.of(context).primaryColor,
                  fontFamily: 'Raleway',
                ),
              ),
              value: '${snap.documentID}',
            ));
          }
          return DropdownButton(
            items: programItems,
            onChanged: (programValue) {
              setState(() {
                selectedProgram = programValue;
              });
            },
            value: selectedProgram,
            isExpanded: false,
            hint: new Text(
              'Choose your program',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontFamily: 'Raleway'),
            ),
          );
        }
      },
    );
  }

  buildLevelDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('departments')
          .document(selectedDepartment)
          .collection('programmes')
          .document(selectedProgram)
          .collection('levels')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading...');
        } else {
          List<DropdownMenuItem> levelItems = [];
          for (int i = 0;
          i < snapshot.data.documents.length;
          i++) {
            DocumentSnapshot snap =
            snapshot.data.documents[i];
            levelItems.add(DropdownMenuItem(
              child: Text(
                snap.documentID,
                style: TextStyle(
                  color:
                  Theme.of(context).primaryColor,
                  fontFamily: 'Raleway',
                ),
              ),
              value: '${snap.documentID}',
            ));
          }
          return DropdownButton(
            items: levelItems,
            onChanged: (levelValue) {
              setState(() {
                selectedLevel = levelValue;
              });
            },
            value: selectedLevel,
            isExpanded: false,
            hint: new Text(
              'Choose your level',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontFamily: 'Raleway'),
            ),
          );
        }
      },
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
    });

    if (_displayNameValid) {
      usersRef.document(widget.currentUserId).updateData({
        'display name': displayNameController.text,
        'department': selectedDepartment,
        'program': selectedProgram,
        'level': selectedLevel,
        'matricNumber': matricNumberController.text,
      });
      SnackBar snackbar = SnackBar(content: Text('Profile Updated.'));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.deepPurple,
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundColor: Theme.of(context).accentColor,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              buildDisplayNameField(),
                              buildMatricNumber(),
                              SizedBox(height: 20.0),
                              buildDepartmentDropdown(),
                              SizedBox(height: 20.0),
                              buildProgramDropdown(),
                              SizedBox(height: 20.0),
                              buildLevelDropdown(),
                            ],
                          ),
                        ),
                        RaisedButton(
                          onPressed: () => updateProfileData(),
                          color: Theme.of(context).accentColor,
                          child: Text(
                            'Update Profile',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontFamily: 'Raleway',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
