import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tutr_connect/models/user.dart';
import 'package:tutr_connect/pages/chat/chat_screen.dart';
import 'package:tutr_connect/pages/edit_profile.dart';
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/widgets/header.dart';
import 'package:tutr_connect/widgets/post.dart';
import 'package:tutr_connect/widgets/post_tile.dart';
import 'package:tutr_connect/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  String postOrientation = 'grid';
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Widget buildCountColumn(String label, int count) {
    bool isNotPosts = label != 'posts';
    return isNotPosts ? GestureDetector(
      onTap: (){
           Navigator.push(context, MaterialPageRoute(builder: (context) => FollowDetail( profileId: widget.profileId, label: label, count: count)));
        },
          child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Raleway',
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
            )
          ],
        ),
    ): Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Raleway',
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
            )
          ],
        );
  }


  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 37.0,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
                color: isFollowing ? Colors.white : Colors.white,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold),
          ),
          decoration: BoxDecoration(
              border: Border.all(
                color:
                    isFollowing ? Color(0xFF73DAFF) : Colors.blueGrey.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: 'Edit Profile',
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: 'Unfollow',
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: 'Follow',
        function: handleFollowUser,
      );
    }
  }

  handleFollowUser() async{
    setState(() {
      isFollowing = true;
    });
    //Make auth user follower of ANOTHER user (update THEIR activity feed followers collection)
    DocumentSnapshot doc = await usersRef.document(widget.profileId).get();
    User peer = User.fromDocument(doc);
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({
          'ownerId': peer.id,
      'username': currentUser.username,
      'id': currentUserId,
      'photoUrl': currentUser.photoUrl,
      'timestamp': DateTime.now(),
        });
    //Put that user on your following collection (update your following collection)
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({
          'ownerId': currentUser.id,
      'username': peer.username,
      'id': peer.id,
      'photoUrl': peer.photoUrl,
      'timestamp': DateTime.now(),
        });
    //add activity feed item to notify about new user following (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUserId,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': DateTime.now(),
    });
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove following
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //delete activity feed item for them
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildProfileHeader() {
    bool isProfileOwner = currentUserId == widget.profileId;
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.only(top: 16.0, left: 16.0),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  CircleAvatar(
                radius: 50.0,
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.username,
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  )),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                  ),
                ),
              ),
                ],
              ),
              Expanded(
                              child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        buildCountColumn('posts', postCount),
                        buildCountColumn('followers', followerCount),
                        buildCountColumn('following', followingCount),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    buildProfileButton(),
                    isProfileOwner
                        ? SizedBox(height: 10.0)
                        : FlatButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Chats(
                                          peerAvatar: user.photoUrl,
                                          peerName: user.username,
                                          peerId: user.id,
                                          messageOwnerId: currentUser.id,
                                        ))),
                            child: Container(
                              width: 250.0,
                              height: 37.0,
                              alignment: Alignment.center,
                              child: Text(
                                'Send a message',
                                style: TextStyle(
                                    color: isFollowing
                                        ? Colors.black
                                        : Colors.white,
                                      fontSize: 16.0,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.bold),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0xFF73DAFF).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        color: Theme.of(context).accentColor.withOpacity(0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.8
                  : MediaQuery.of(context).size.height * 0.5,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No Posts Yet',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    color: Colors.white,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == 'grid') {
      List<GridTile> postGrid = [];
      posts.forEach((post) {
        postGrid.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: postGrid,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on,
              color: postOrientation == 'grid'
                  ? Theme.of(context).primaryColor
                  : Colors.grey),
          onPressed: () => setPostOrientation('grid'),
        ),
        IconButton(
          icon: Icon(Icons.list,
              color: postOrientation == 'list'
                  ? Theme.of(context).primaryColor
                  : Colors.grey),
          onPressed: () => setPostOrientation('list'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}

class FollowingListItem extends StatelessWidget {
  final User following;
  final bool isUserProfile;
  String profileId;

  FollowingListItem({this.following, this.isUserProfile}); 

  handleUnfollow(){
    //remove follower
    followersRef
        .document(following.id)
        .collection('userFollowers')
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove following
    followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .document(following.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //delete activity feed item for them
    activityFeedRef
        .document(following.id)
        .collection('feedItems')
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Profile(profileId: following.id)));
                  },
                                  child: CircleAvatar(
                              backgroundColor: Theme.of(context).accentColor,
                              backgroundImage: CachedNetworkImageProvider(following.photoUrl),
                            ),
                ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              following.username,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.bold
                                ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          isUserProfile ? GestureDetector(
                            onTap: () => handleUnfollow(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10.0)
                                ),
                                height: 40.0,
                                width: 100.0,
                                child: Center(
                                  child: Text(
                                    'Unfollow',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                  ),
                                ),
                            ),
                          )
                          : Text(''),
              ],
            ),
          ),
          Divider(color: Colors.black54,)
        ],
      ),
    );
  }
}

class FollowDetail extends StatelessWidget {
  User following;
  String profileId;
  bool isUserProfile = false;
  String label;
  int count;

  FollowDetail({this.profileId, this.label, this.count});


  getfollowDetail() {
    if (label == 'following'){
      return StreamBuilder<QuerySnapshot>(
        stream: followingRef.document(profileId)
        .collection('userFollowing')
        .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return circularProgress();
          } else if (snapshot.data.documents.length == 0){
            return Container(
          color: Colors.white,
          child: Center(
             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text(
                'You aren\'t following anyone yet.',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 30.0
                ),
            ),
             ),
          )
        );
          } else {
            List<FollowingListItem> followingList = [];
            snapshot.data.documents.forEach((snap){
              following = User.fromDocument(snap);
              isUserProfile = profileId == currentUser.id;
              FollowingListItem followingListItem = FollowingListItem(following: following, isUserProfile: isUserProfile,);
              followingList.add(followingListItem);
            });
            return Container(
              child: ListView(children: followingList),
            );
          }
        },
      );
    }
    else if (label == 'followers'){
      return StreamBuilder<QuerySnapshot>(
        stream: followersRef.document(profileId)
        .collection('userFollowers')
        .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return circularProgress();
          } else if (snapshot.data.documents.length == 0){
            return Container(
          color: Colors.white,
          child: Center(
             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text(
                'No one has followed you yet.',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 30.0
                ),
            ),
             ),
          )
        );
          } else {
            List<FollowingListItem> followingList = [];
            snapshot.data.documents.forEach((snap){
              following = User.fromDocument(snap);
              isUserProfile = profileId == currentUser.id;
              FollowingListItem followingListItem = FollowingListItem(following: following, isUserProfile: isUserProfile);
              followingList.add(followingListItem);
            });
            return Container(
              child: ListView(children: followingList),
            );
          }
        },
      );
    } else {
      return;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Container(
            color: Colors.grey.withOpacity(0.1),
            padding: EdgeInsets.all(40.0),
        child: GestureDetector(
          onTap: (){Navigator.pop(context);},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 40.0,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 4.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Raleway',
                          fontSize: 35.0,
                          fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
              ),
              Divider(color: Colors.black87,),
              Expanded(
                child: Container(child: getfollowDetail(),),
              )
            ],
          ),
        ),
      ),
    );
  }
}