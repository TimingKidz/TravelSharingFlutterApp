import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/loginPage.dart';
import 'package:travel_sharing/Pages/signupPage.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);

class Splashscreen extends StatefulWidget {
  static final GlobalKey<SplashscreenState> splashscreenKey = GlobalKey<SplashscreenState>();

  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      _currentUser = account;
    });
    _googleSignIn.signInSilently();
    _signInCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FlutterLogo(size: 180.0),
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

  Future<void> _signInCheck() async {
    var isSignedIn = await _googleSignIn.isSignedIn();
    debugPrint('isSignedIn = $isSignedIn');
    Future.delayed(Duration(seconds: 1), () {
      if(isSignedIn){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomeNavigation(signOut: _handleSignOut)));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => LoginPage(signIn: _handleSignIn)));
      }
    });
  }

  Future<void> _handleSignIn() async {
    try{
      var isDismiss = await _googleSignIn.signIn();
      debugPrint('$isDismiss');
      _loadingDialog();
      if(isDismiss != null){
        User user = new User(name: isDismiss.displayName,email: isDismiss.email,id: isDismiss.id);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("CurrentUser_id", user.id);
        if (await user.Register()){
          Navigator.of(context).pop(); //Pop Loading Dialog
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => SignUpPage(currentUser: _currentUser, signOut: _handleSignOut,)));
        }else{
          throw("Plaese check your connection.");
        }
      }
    }catch(error){
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => LoginPage(signIn: _handleSignIn)));
//    Navigator.of(context)
//        .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/'));
  }

}