import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';

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
      body: Center(
          child: Container(
            padding: EdgeInsets.all(24.0),
            child: Column(
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
                )
              ],
            ),
          )
      )
    );
  }

}