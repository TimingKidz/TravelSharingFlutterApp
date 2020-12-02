import 'dart:convert';
import 'dart:io';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/InfoFill.dart';
import 'package:travel_sharing/Pages/signupPage.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'ChatFile/chatPage.dart';
import 'Class/User.dart';
import 'Pages/loginPage.dart';
import 'Pages/map.dart';
import 'Pages/dashboard.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
void main() {
  //  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
//
//    // statusBarColor is used to set Status bar color in Android devices.
//    statusBarColor: Colors.transparent,
//
//    // To make Status bar icons color white in Android devices.
//    statusBarIconBrightness: Brightness.dark,
//
//    // statusBarBrightness is used to set Status bar icon color in iOS.
//    statusBarBrightness: Brightness.dark,
//    // Here light means dark color Status bar icons.
//
//    systemNavigationBarColor: Colors.transparent,
//    systemNavigationBarIconBrightness: Brightness.dark
//
//  ));
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print('44');
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    print(data);
  }
  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print(message);
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Theme.of(context).colorScheme.orange,
          accentColor: Theme.of(context).colorScheme.redOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            elevation: 0.0,
          )
        ),
        initialRoute: '/',
        routes: {
          '/' : (context) => ChatPage(),
          '/login' : (context) => LoginPage(googleSignIn: _googleSignIn),
          '/homeNavigation' : (context) => HomeNavigation(),
          '/dashboard' : (context) => Dashboard(),
          '/joinMap' : (context) => CreateRoute_Join(),
          '/inviteMap' : (context) => CreateRoute(),
          '/tripInfo' : (context) => InfoFill()
        },
      );
  }
}

class HTTP{
  final String API_IP = "https://68.183.226.229";
  final Map<String,String> header = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};
}

class Splashscreen extends StatefulWidget {
  SplashscreenState createState() => SplashscreenState();

}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class SplashscreenState extends State<Splashscreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();



  @override
  void initState() {
    super.initState();


    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        print(message['notification']);
      },
      onLaunch: (Map<String, dynamic> message) async{
        print(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,


    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    Get_token();
    _signInCheck();
  }

  Get_token() async {
    print(await _firebaseMessaging.getToken());
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
    Future.delayed(Duration(seconds: 1), () async {
      if(isSignedIn){
        GoogleSignInAccount G_user = await _googleSignIn.signIn();
        print(G_user.id);
        User Current_user =  await User().getCurrentuser(G_user.id);

        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomeNavigation(currentUser: Current_user,googleSignIn: _googleSignIn)));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => LoginPage(googleSignIn: _googleSignIn)));
      }
    });
  }

}


