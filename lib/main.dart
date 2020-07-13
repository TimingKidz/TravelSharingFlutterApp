import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Pages/map.dart';
import 'Pages/DirectionsProvider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {


  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DirectionProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CreateRoute(),
      ),
    );
  }
}


