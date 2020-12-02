import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as Http;
import 'package:flutter/cupertino.dart';

final Map<String,String> header = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class FireBase_Messaging extends StatefulWidget {
  @override
  _FireBase_MessagingState createState() => _FireBase_MessagingState();
}

class _FireBase_MessagingState extends State<FireBase_Messaging>{
  final FirebaseMessaging _fc = FirebaseMessaging();
  var initializationSettings;

  @override
  void initState() {
    super.initState();
    configureCallbacks();
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
  }

  void configureCallbacks(){
    _fc.configure(
      onMessage: (message) async {
        print(message);
        showNotification(message);
      },
    );
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          child: Text("BUTTON"),
          onPressed: () async {
            String a = await _fc.getToken();
            // print(a);
            sendToken(a);
            // showNotification();
          },
        ),
      )
    );
  }

  Future<void> sendToken(String id) async{
    print(id);
    try{
      var url = "http://10.80.27.233:3000/api/routes/test";
      Http.Response response = await Http.post(url,headers: header , body: jsonEncode({"id":id }));
      print(jsonEncode({"id":id }));
    }catch(error){
      throw("can't connect");
    }
  }

}