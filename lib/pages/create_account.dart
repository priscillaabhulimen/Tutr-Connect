import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tutr_connect/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  submit(){
    final form = _formKey.currentState;
    //performing validation
    if (form.validate()) {
      form.save();
      //display welcome message after user signs in
      SnackBar snackBar = SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Welcome $username!'),);
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });

    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: "Set up your profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    'Create a username',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 25.0
                    ),
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      autovalidate: true,
                      validator: (val){
                        if (val.trim().length < 3 || val.isEmpty){
                          return 'Username too short';
                        } else if (val.trim().length > 12){
                          return 'Username too long';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => username = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15.0,
                          color: Color(0xFF707070)
                        ),
                        hintText: 'Must be at least 3 characters long'
                      ),
                    )
                  ),
                ),
              ),
              GestureDetector(
                onTap: submit,
                child: Container(
                  height: 50.0,
                  width: 350.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF00C3C3),
                    borderRadius: BorderRadius.circular(7.0)
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              )
            ],),
          ),
        ],
      ),
    );
  }
}
