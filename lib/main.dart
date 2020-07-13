import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:travel_sharing/ChatFile/chatPage.dart';
import 'package:travel_sharing/Pages/home.dart';
import 'Pages/loginPage.dart';

Future<List<Album>> fetchAlbum() async {
  final response =
  await http.get('http://10.0.2.2:3000/api/user');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Iterable list = json.decode(response.body);
    return list.map((model) => Album.fromJson(model)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String id;
  final String name;
  final int age;

  Album({this.id, this.name, this.age});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['_id'],
      name: json['name'],
      age: json['age']
    );
  }
}

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(

    // statusBarColor is used to set Status bar color in Android devices.
    statusBarColor: Colors.transparent,

    // To make Status bar icons color white in Android devices.
    statusBarIconBrightness: Brightness.dark,

    // statusBarBrightness is used to set Status bar icon color in iOS.
    statusBarBrightness: Brightness.light,
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          color: Colors.white
        )
      ),
      home: LoginPage(),
//      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<Album>>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Album project = snapshot.data[index];
                  return Column(
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      Text(project.name),
                      SizedBox(height: 16.0),
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
