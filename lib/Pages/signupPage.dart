import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:travel_sharing/Pages/dashboard.dart';
import 'package:travel_sharing/Pages/home.dart';
import 'package:travel_sharing/Pages/map.dart';

class SignUpPage extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final Function signOut;

  SignUpPage({this.currentUser, this.signOut});

  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Sign Up to Travel Sharing'),
      ),
      body: Stack(
        children: <Widget>[Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 96.0,
                  height: 96.0,
                  child: GoogleUserCircleAvatar(
                    identity: widget.currentUser,
                  ),
                ),
                RaisedButton(
                  onPressed: widget.signOut,
                  child: Text('SIGN OUT'),
                ),

              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.arrow_forward),
                  onPressed: _Nextpage,
                ),
              ],
            ),
          ),
        ],

      )
    );
  }

  _Nextpage(){
    Navigator.push(context,MaterialPageRoute(
        builder : (context) => Dashboard()));
  }
}

