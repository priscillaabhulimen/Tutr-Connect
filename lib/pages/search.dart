import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tutr_connect/models/user.dart';
import 'package:tutr_connect/pages/activity_feed.dart';
import 'package:tutr_connect/pages/home.dart';
import 'package:tutr_connect/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search>{
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch (String query){
    Future<QuerySnapshot> users = usersRef
     .where('display name', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch(){
    searchController.clear();
  }

  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear,),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent(){
    final  Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        //using listview because we need the view to be able to resize when the
        //keyboard comes up to avoid overflow errors
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              //to adjust image size based on screen resolution
              height: orientation == Orientation.portrait ? 300.0 : 150.0,
            ),
            Text('Find Users', textAlign: TextAlign.center, style:
              TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
                fontFamily: 'Raleway'
              ),)
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot){
        if (!snapshot.hasData){ // if information has been captured from the database
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return Container(
          color: Colors.white,
          child: searchResults.isNotEmpty ? ListView(
            children: searchResults,
          ) : Center(
             child: Text(
              'No results available',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 30.0
              ),
            ),
          )
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Color(0xFF73DAFF),
      appBar: buildSearchField(),
      body:
        searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }

}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF73DAFF),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}

