import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/InfoFill.dart';
import 'package:travel_sharing/Pages/signupPage.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:http/http.dart' as Http;
import 'ChatFile/chatPage.dart';
import 'Class/User.dart';
import 'Pages/loginPage.dart';
import 'Pages/map.dart';
import 'Pages/dashboard.dart';

GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
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
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
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
          '/' : (context) => Splashscreen(),
          '/login' : (context) => LoginPage(googleSignIn: googleSignIn),
          '/homeNavigation' : (context) => HomeNavigation(),
          '/dashboard' : (context) => Dashboard(),
          '/joinMap' : (context) => CreateRoute_Join(),
          '/inviteMap' : (context) => CreateRoute(),
          '/tripInfo' : (context) => InfoFill(),
          '/chatPage' : (context) => ChatPage()
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

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> showNotification(Map<String, dynamic> message) async {
  var androidChannelSpecifics = AndroidNotificationDetails(
    'CHANNEL_ID',
    'CHANNEL_NAME',
    "CHANNEL_DESCRIPTION",
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    // timeoutAfter: 5000,
    styleInformation: DefaultStyleInformation(true, true),
  );
  var iosChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics =
  NotificationDetails(android: androidChannelSpecifics, iOS: iosChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message['data']['title'],
    message['data']['body'], //null
    platformChannelSpecifics,
    payload: 'New Payload',
  );
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

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
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

  Future<void> Get_token(String id) async {
    print(await _firebaseMessaging.getToken());
    String token = await _firebaseMessaging.getToken();
    try{
      var url = "${HTTP().API_IP}/api/routes/updateToken";
      Http.Response response = await Http.post(url, headers: HTTP().header, body: jsonEncode({"id":id, "token_id": token}));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
          // Map<String,dynamic> data = jsonDecode(response.body);
          // print(data);
          // TripDetails tmp = TripDetails.fromJson(data);
          // return Future.value(tmp);
        }
      }
    }catch(err){
      print(err);
      throw("can't connect Match");
    }
  }

  Future<void> _signInCheck() async {
    var isSignedIn = await googleSignIn.isSignedIn();
    debugPrint('isSignedIn = $isSignedIn');
    Future.delayed(Duration(seconds: 1), () async {
      if(isSignedIn){
        GoogleSignInAccount G_user = await googleSignIn.signIn();
        print(G_user.id);
        User Current_user =  await User().getCurrentuser(G_user.id);
        await Get_token(Current_user.uid);
        Current_user =  await User().getCurrentuser(G_user.id);
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomeNavigation(currentUser: Current_user, googleSignIn: googleSignIn)));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => LoginPage(googleSignIn: googleSignIn)));
      }
    });
  }

}


