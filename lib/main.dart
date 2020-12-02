import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:travel_sharing/ChatFile/chatPage.dart';
import 'package:travel_sharing/Pages/CardHorizontal.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/InfoFill.dart';
import 'package:travel_sharing/Pages/signupPage.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/firebase_messaging.dart';
import 'Pages/loginPage.dart';
import 'Pages/map.dart';
import 'Pages/dashboard.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
const String URI = "http://10.80.131.181:4567";

Future<void> main() async {
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

class Splashscreen extends StatefulWidget {
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  List<String> toPrint = ["trying to connect"];
  SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  Map<String, bool> _isProbablyConnected = {};

  @override
  void initState() {
    super.initState();
    _signInCheck();
  }

  Future<SocketIO> initSocket(String identifier) async {
    setState(() => _isProbablyConnected[identifier] = true);
    SocketIO socket = await manager.createInstance(SocketOptions(
        URI,
        query: {
          "id": "Hello"
        },
        transports: [Transports.WEB_SOCKET]
    ));

    socket.onConnect((data) {
      print("Connected");
      print(data);
    });

    socket.onConnectError(pprint);
    socket.connect();
    sockets[identifier] = socket;
    return socket;
  }

  bool isProbablyConnected(String identifier){
    return _isProbablyConnected[identifier]??false;
  }

  pprint(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
      toPrint.add(data);
    });
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
        manager = SocketIOManager();
        SocketIO socket = await initSocket("default");
        socket.emit("roomCreate", ["125"]);
        // Navigator.push(context, MaterialPageRoute(
        //     builder: (context) => ChatPage(socket: socket)));
        // Navigator.push(context, MaterialPageRoute(
        //     builder: (context) => HomeNavigation(googleSignIn: _googleSignIn, socket: socket)));
      }else{
        manager = SocketIOManager();
        SocketIO socket = await initSocket("default");
        socket.emit("roomCreate", ["125"]);
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => LoginPage(googleSignIn: _googleSignIn)));
      }
    });
  }

}


