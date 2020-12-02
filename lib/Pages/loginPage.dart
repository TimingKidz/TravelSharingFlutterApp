import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/signupPage.dart';

class LoginPage extends StatefulWidget {
  final GoogleSignIn googleSignIn;
  LoginPage({this.googleSignIn});
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  GoogleSignInAccount _currentUser;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    widget.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      _currentUser = account;
    });
    widget.googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: buildBody())
    );
  }

  Widget buildBody () {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlutterLogo(size: 150.0),
            SizedBox(height: 150.0),
            Container(
              width: 300.0,
              child: RaisedButton(
                highlightElevation: 0.0,
                padding: EdgeInsets.all(16.0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
//              side: BorderSide(color: Colors.grey.shade200, width: 4.0)
                ),
                child: Row(
                  children: <Widget>[
                    Image(image: AssetImage("assets/icons/google_logo.png"), height: 18.0),
                    SizedBox(width: 24.0),
                    Text('SIGN IN WITH GOOGLE', style: TextStyle(color: Colors.black54, fontSize: 14.0, fontFamily: 'Roboto'))
                  ],
                ),
                onPressed: _handleSignIn,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _loadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            margin: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16.0),
                Text("Signing in..."),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignIn() async {
    try{
      var isDismiss = await widget.googleSignIn.signIn();
      debugPrint('$isDismiss');
      if(isDismiss != null){
        _loadingDialog();
        User user = new User(name: isDismiss.displayName,email: isDismiss.email,id: isDismiss.id,token: await _firebaseMessaging.getToken());
        if (await user.Register()){
          User Current_user = await user.getCurrentuser(user.id);
          Navigator.of(context).pop(); //Pop Loading Dialog
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => SignUpPage(currentUser: Current_user, googleSignIn: widget.googleSignIn)));
        }else{
          throw("Please check your connection.");
        }
      }
    }catch(error){
      print(error);
    }
  }
}