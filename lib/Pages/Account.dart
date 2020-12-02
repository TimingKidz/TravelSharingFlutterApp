import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_sharing/Class/User.dart';

class Account extends StatefulWidget {
  final User currentUser;
  final GoogleSignIn googleSignIn;

  Account({this.currentUser,this.googleSignIn});
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: _handleSignOut,
          child: Text('Sign Out'),
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    await widget.googleSignIn.disconnect();
//    Navigator.pushReplacement(context, MaterialPageRoute(
//        builder: (context) => LoginPage(signIn: _handleSignIn)));
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/'));
  }

}