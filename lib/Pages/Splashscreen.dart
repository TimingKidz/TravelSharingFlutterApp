import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/main.dart';
import 'loginPage.dart';


class Splashscreen extends StatefulWidget {
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var initializationSettings;

  @override
  void initState() {
    super.initState();
    // Firebase Notification Init
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showNotification(message);
        }
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FlutterLogo(size: 180.0),
      ),
    );
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future<void> _signInCheck() async {
    var isSignedIn = await googleSignIn.isSignedIn();
    Future.delayed(Duration(seconds: 1), () async {
      if(isSignedIn){
        googleUser = await googleSignIn.signIn();
        String tokenID = await _firebaseMessaging.getToken();
        currentUser =  await User().getCurrentuser(googleUser.id);
        await currentUser.updateToken(tokenID);
        currentUser =  await User().getCurrentuser(googleUser.id);
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomeNavigation()));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => LoginPage()));
      }
    });
  }
}