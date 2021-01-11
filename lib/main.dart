import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/HTTP.dart';
import 'package:travel_sharing/Class/Status.dart';
import 'package:travel_sharing/Pages/Account.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/LocationSearchBar.dart';
import 'package:travel_sharing/Pages/MatchList.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/NotificationsPage.dart';
import 'package:travel_sharing/Pages/ProfileManagePage.dart';
import 'package:travel_sharing/Pages/ReqList.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/InfoFill.dart';
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/Pages/ratingPage.dart';
import 'package:travel_sharing/Pages/signupPage.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'ChatFile/chatPage.dart';
import 'Class/User.dart';
import 'Pages/Feed.dart';
import 'Pages/Splashscreen.dart';
import 'Pages/loginPage.dart';
import 'Pages/map.dart';
import 'Pages/dashboard.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:travel_sharing/localization.dart';

final String api_key = "AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q";
GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
u.UserCredential firebaseAuth;
GoogleSignInAccount googleUser;
User currentUser;
IO.Socket socket ;
Status status;
HTTP httpClass = new HTTP();
LatLng current_Location;
SharedPreferences prefs;
bool isJoinPage = true;

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(

   // statusBarColor is used to set Status bar color in Android devices.
   statusBarColor: Colors.transparent,

   // To make Status bar icons color white in Android devices.
   statusBarIconBrightness: Brightness.light,

   // statusBarBrightness is used to set Status bar icon color in iOS.
   statusBarBrightness: Brightness.light,
   // Here light means dark color Status bar icons.

   systemNavigationBarColor: Color(0xff2d4059),
   systemNavigationBarIconBrightness: Brightness.dark

 ));
  HttpOverrides.global = new MyHttpOverrides();
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

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
    message['notification']['title'],
    message['notification']['body'], //null
    platformChannelSpecifics,
    payload: 'New Payload',
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English, no country code
          const Locale('th', ''), // Thai, no country code
        ],
        localeResolutionCallback: (locale, supportedLocales){
          String lang = prefs.getString("lang");
          if(lang != null){
            return Locale(lang);
          }
          if (locale == null) {
            locale = Localizations.localeOf(context);
          }
          for(var supportedLocale in supportedLocales){
            if(supportedLocale.languageCode == locale.languageCode)
              return locale;
          }
          return supportedLocales.first;
        },
        title: 'TActivity',
        theme: ThemeData(
          primaryColor: Theme.of(context).colorScheme.darkBlue,
          accentColor: Theme.of(context).colorScheme.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            elevation: 0.0,
          )
        ),
        initialRoute: '/',
        routes: {
          '/' : (context) => Splashscreen(),
          '/login' : (context) => LoginPage(),
          '/homeNavigation' : (context) => HomeNavigation(),
          '/dashboard' : (context) => Dashboard(),
          '/joinMap' : (context) => CreateRoute_Join(),
          '/inviteMap' : (context) => CreateRoute(),
          '/InfoFill' : (context) => InfoFill(),
          '/chatPage' : (context) => ChatPage(),
          '/feedPage' : (context) => FeedPage(),
          '/MatchInfo' : (context) => Matchinformation(),
          '/Account' : (context) => Account(),
          '/inviteMap' : (context) => CreateRoute(),
          '/Map' : (context) => MapView(),
          '/LocationSerch' : (context) => LocationSearch(),
          '/MatchList' : (context) => MatchList(),
          '/NotificationPage' : (context) => NotificationsPage(),
          '/Profile' : (context) => ProfileManagePage(),
          '/ratingPage' : (context) => RatingPage(),
          '/ReqList' : (context) => ReqList(),
          '/SignUp' : (context) => SignUpPage()
        },
      );
  }
}



