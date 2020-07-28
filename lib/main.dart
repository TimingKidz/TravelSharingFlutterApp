import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:travel_sharing/ChatFile/chatPage.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/signupPage.dart';
import 'package:travel_sharing/Pages/splashscreen.dart';
import 'package:travel_sharing/Pages/test.dart';
import 'Pages/loginPage.dart';
import 'Pages/map.dart';
import 'Pages/dashboard.dart';

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
          '/login' : (context) => LoginPage(),
          '/homeNavigation' : (context) => HomeNavigation(),
          '/dashboard' : (context) => Dashboard(),
          '/joinMap' : (context) => CreateRoute_Join(),
          '/inviteMap' : (context) => CreateRoute(),
          '/tripInfo' : (context) => Test()
        },
      );
  }
}


