import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/main.dart';

class SignUpPage extends StatefulWidget {
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
//                    add photo
//                    child: GoogleUserCircleAvatar(
//                      identity: widget.currentUser,
//                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(currentUser.id)
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
      ),
    );
  }
  _Nextpage(){
    Navigator.pushReplacement(context,MaterialPageRoute(
        builder : (context) => HomeNavigation()));
  }
}

