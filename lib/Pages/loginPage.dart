import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_sharing/Pages/signupPage.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);

class LoginPage extends StatefulWidget {
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: buildBody())
    );
  }

  Widget buildBody () {
    return Container(
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
    );
  }

  Future<void> _handleSignIn() async {
    try{
      var isDismiss = await _googleSignIn.signIn();
      if(isDismiss != null){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => SignUpPage(currentUser: _currentUser, signOut: _handleSignOut)));
      }
    }catch(error){
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
    Navigator.of(context).pop();
  }

}