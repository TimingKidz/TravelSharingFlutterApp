import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/test.dart';
import 'Pages/loginPage.dart';
import 'Pages/map.dart';
import 'Pages/dashboard.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(

    // statusBarColor is used to set Status bar color in Android devices.
    statusBarColor: Colors.transparent,

    // To make Status bar icons color white in Android devices.
    statusBarIconBrightness: Brightness.dark,

    // statusBarBrightness is used to set Status bar icon color in iOS.
    statusBarBrightness: Brightness.dark,
    // Here light means dark color Status bar icons.

    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark

  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            color: Colors.white
          )
        ),
        initialRoute: '/',
        routes: {
          '/' : (context) => Splashscreen(),
          '/login' : (context) => LoginPage(googleSignIn: _googleSignIn),
          '/homeNavigation' : (context) => HomeNavigation(),
          '/dashboard' : (context) => Dashboard(),
          '/joinMap' : (context) => CreateRoute_Join(),
          '/inviteMap' : (context) => CreateRoute(),
          '/tripInfo' : (context) => Test()
        },
      );
  }
}

class Splashscreen extends StatefulWidget {
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
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

  Future<void> _signInCheck() async {
    var isSignedIn = await _googleSignIn.isSignedIn();
    debugPrint('isSignedIn = $isSignedIn');
    Future.delayed(Duration(seconds: 1), () {
      if(isSignedIn){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomeNavigation(googleSignIn: _googleSignIn)));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => LoginPage(googleSignIn: _googleSignIn)));
      }
    });
  }

}


