import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/signupPage.dart';
import 'package:travel_sharing/main.dart';
import 'loginPage.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class Splashscreen extends StatefulWidget {
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  var initializationSettings;


  @override
  void initState() {
    super.initState();
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showNotification(message);
        }
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    // Local Notification Init
    try{
      var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          // your call back to the UI
          print("onDidReceiveLocalNotification called.");
        },
      );
      initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);
    }catch(e){
      print(e.toString());
    }

    _signInCheck();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FlutterLogo(size: 180.0),
        ),
      ),
    );
  }

  initsocket(){
    socket = IO.io(HTTP().API_IP,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .setExtraHeaders({'uid': currentUser.uid}) // optional // disable auto-connection
            .build());
    socket = socket.connect();
    socket.onConnect((_) {
      print('connect');
    });
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future<void> _signInCheck() async {
    var isSignedIn = await googleSignIn.isSignedIn();
    // Future.delayed(Duration(seconds: 1), () async {
      if(isSignedIn){
        googleUser = await googleSignIn.signInSilently();
        GoogleSignInAuthentication Auth = await googleUser.authentication;
        u.GoogleAuthCredential a =  u.GoogleAuthProvider.credential(
          accessToken: Auth.accessToken,
          idToken: Auth.idToken,
        );
        firebaseAuth = await u.FirebaseAuth.instance.signInWithCredential(a);
        bool isRegister = await User().getCurrentuser(googleUser.id) != null ? true : false;
        if (isRegister){
          String tokenID = await firebaseMessaging.getToken();
          currentUser =  await User().getCurrentuser(googleUser.id);
          await currentUser.updateToken(tokenID);

          initsocket();
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => HomeNavigation()));
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => SignUpPage()));
        }
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => LoginPage()));
      }
    // });
  }
}