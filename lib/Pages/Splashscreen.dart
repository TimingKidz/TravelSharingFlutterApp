import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/UI/NotificationBarSettings.dart';
import 'package:travel_sharing/main.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class Splashscreen extends StatefulWidget {
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  var initializationSettings;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
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
    navigationBarColorPrimary(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Image(image: AssetImage("assets/icons/TACtivity.png"), width: MediaQuery.of(context).size.width * 0.8),
        ),
      ),
    );
  }

  initsocket(){
    socket = IO.io(httpClass.API_IP,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableReconnection()
            .disableAutoConnect()
            .setExtraHeaders({'uid': currentUser.uid,'auth' : httpClass.header['auth']}) // optional // disable auto-connection
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

  Future<void> _getLocation() async {
    LocationData currentLoc = await Location().getLocation();
    current_Location = LatLng(currentLoc.latitude, currentLoc.longitude);
  }

  Future<void> _signInCheck() async {
    _getLocation();
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
        await httpClass.getNewHeader();
        currentUser = await User().getCurrentuser(googleUser.id);
        if (currentUser != null){
          if(currentUser.isVerify){
            if(await currentUser.amiOnline()){
              googleUser = await googleSignIn.signOut();
              unPopDialog(
                this.context,
                'Accept',
                Text("You already online with other device."),
                <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () async {
                      Navigator.pushReplacementNamed(context,"/login");
                    },
                  ),
                ],
              );
            }else{
              String tokenID = await firebaseMessaging.getToken();
              await currentUser.updateToken(tokenID);
              if( socket != null ){
                socket.io.options['extraHeaders'] = {'uid': currentUser.uid,'auth' : httpClass.header['auth']};
              }
              initsocket();
              navigationBarColorWhite();
              Navigator.pushReplacementNamed(context,"/homeNavigation");
            }
          }else{
            Navigator.pushReplacementNamed(context,"/VerificationPage");
          }
        }else{
          navigationBarColorWhite();
          Navigator.pushReplacementNamed(context,"/SignUp");
        }
      }else{
        Navigator.pushReplacementNamed(context,"/login");
      }
    // });
  }
}