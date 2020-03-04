import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

header(context, { bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false: true,
    title: Text(
      isAppTitle ? 'Tutr Connect': titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : 'Raleway',
        fontSize: isAppTitle ? 50.0: 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}
