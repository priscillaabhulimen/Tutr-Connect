import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tutr_connect/models/user.dart';
import 'package:tutr_connect/pages/activity_feed.dart';
import 'package:tutr_connect/pages/create_account.dart';
import 'package:tutr_connect/pages/profile.dart';
import 'package:tutr_connect/pages/search.dart';
import 'package:tutr_connect/pages/timeline.dart';
import 'package:tutr_connect/pages/upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final messagesRef = Firestore.instance.collection('messages');
final commentsRef = Firestore.instance.collection('comments');
final timelineRef = Firestore.instance.collection('timeline');
final activityFeedRef = Firestore.instance.collection('feed');
final messageFeedRef = Firestore.instance.collection('recent');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final departmentRef = Firestore.instance.collection('departments');
final coursesRef = Firestore.instance.collection('courses');
DateTime timestamp = DateTime.now();
User currentUser;
//enables a number of methods allow users to login and logout

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    //since it is created in init state method, it needs to be disposed when it's not needed
    pageController = PageController();
    //sign in listener to detect when someone signs in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    //Re-authenticate user when app is openedst
    googleSignIn.signInSilently(suppressErrors: false)
        //to resolve what comes back from executing signInSilently
        .then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async{
    //if statement to set authorised if user data is available
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    }
    //else it remains false
    else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    //if user doesn't exist, take them to the create account page
    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      //then get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'display name': user.displayName,
        'matricNumber': '',
        'currentSemester': '',
        'isRegistered': '',
        'level': '',
        'department': '',
        'program': '',
        'timestamp': timestamp,
      });

      //make new user their own follower to add their posts to their timeline
      await followersRef
        .document(user.id)
        .collection('userFollowers')
        .document(user.id)
        .setData({});

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  //necessary to open login module
  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), //duration of animation
        curve: Curves.easeInOut);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Color(0xFF73DAFF),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Tut\'r Connect',
              style: TextStyle(
                  fontFamily: 'Signatra', fontSize: 90.0, color: Colors.white),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
