import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/MatchList.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/ReqList.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/buttons/cardTileWithTap.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

import 'package:http/http.dart' as Http;
import 'package:travel_sharing/main.dart';

import '../firebase_messaging.dart';
/// This Widget is the main application widget.
///
///
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print('44444');
  print(message);
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    print(data);
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print(message);
  }

  // Or do other work.
}

class Travel_Info{
  Routes routes;
  String id;
  String uid;

  Travel_Info({this.routes, this.id});

  Travel_Info.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json['detail']);
    id = json['detail']['id'];
    uid = json['_id'];
  }

  Future<List<Travel_Info>> getRoutes(String id,int role) async {
    try{
      Map<int,String> path = {0:'invite',1:'join'};
      var url = "${HTTP().API_IP}/api/routes/getRoutes";
      print("getroutesssssss");
      Http.Response response = await Http.post(url, headers: HTTP().header, body: jsonEncode({'id':id,'role':role}));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          Map<String, dynamic> data = jsonDecode(response.body);
          print(data);
          List<Travel_Info> travel_info_list = List();
          data['event'][path[role]].forEach((x) {
            Travel_Info tmp = Travel_Info.fromJson(x);
            travel_info_list.add(tmp);
          });
          return Future.value(travel_info_list);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect");
    }
  }
}




class Dashboard extends StatefulWidget {

  final User currentUser;
  Dashboard({this.currentUser}) ;
  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  Location location = Location();
  LocationData Locations;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

//  final _joinList = <String>['A', 'B', 'C', 'D'];
//  final _invitedList = <String>['E', 'F', 'G', 'H'];
  List<Travel_Info> _joinList  = List();
  List<Travel_Info> _invitedList = List();
  bool isFirstPage = true;

  Future<void> getData() async {
    try{
    User user = widget.currentUser;
    print("45555");
    print(user.id);
      _invitedList =  await Travel_Info().getRoutes(user.uid,0) ?? [];
      _joinList =  await Travel_Info().getRoutes(user.uid,1) ?? [];
      _invitedList.sort((a,b) => b.routes.date.compareTo(a.routes.date));
      _joinList.sort((a,b) => b.routes.date.compareTo(a.routes.date));
      debugPrint('$_joinList');
      setState(() {});
    }catch(error){
      print("$error lll");
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    print("aaaaaa");

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage Dashboard : $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          print(message['notification']);
        },
        onLaunch: (Map<String, dynamic> message) async{
          print(message);
        },
      onBackgroundMessage: myBackgroundMessageHandler,



    );
  }



  Widget _widgetOptions(){
    if((_joinList.isEmpty && isFirstPage) || (_invitedList.isEmpty && !isFirstPage)){
      return Center(
        child: Text('No List'),
      );
    }else{
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: isFirstPage ? _joinList.length : _invitedList.length,
      itemBuilder: (context, i) {
        return _buildRow(isFirstPage ? _joinList[i] : _invitedList[i]);
      }
    );
  }

  Widget _buildRow(Travel_Info data) {
    print(data);
    return CardTileWithTap(
      isFirstPage: isFirstPage,
      data: data.routes,
      onCardPressed: () => _onCardPressed(data),
    );
  }

  _onCardPressed(Travel_Info data){
    if( isFirstPage ){
      if( data.routes.isMatch ){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: data.routes.match.first, currentUser: widget.currentUser)));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MatchList(data: data)));
      }
    }else{
      if( data.routes.isMatch){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: data.uid, currentUser: widget.currentUser)));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ReqList(data: data,currentUser : widget.currentUser)));
      }
    }
  }



  _newroute() async{
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreateRoute(currentUser:widget.currentUser))).then((value) {
        getData();
      });
  }

  _newroute1() async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CreateRoute_Join(currentUser: widget.currentUser))).then((value) {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: isFirstPage ? Theme.of(context).colorScheme.orange : Theme.of(context).colorScheme.orange,
        automaticallyImplyLeading: false,
        title: const Text('แดชบอร์ด'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: isFirstPage ? _newroute1 : _newroute,
        backgroundColor: isFirstPage ? Theme.of(context).colorScheme.redOrange : Theme.of(context).colorScheme.redOrange,
        heroTag: null,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)
                  )
              ),
              child: Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0, top: 8.0),
//              color: Theme.of(context).primaryColor,
                decoration: BoxDecoration(
                    color: isFirstPage ? Theme.of(context).colorScheme.orange : Theme.of(context).colorScheme.orange,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0)
                    )
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        highlightElevation: 0.0,
                        padding: EdgeInsets.all(16.0),
                        color: isFirstPage ? Colors.white : Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text('ไปด้วย', style: TextStyle(color: isFirstPage ? Colors.black : Colors.white)),
                        onPressed: () {
                          setState(() {
                            isFirstPage = true;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: RaisedButton(
                        highlightElevation: 0.0,
                        padding: EdgeInsets.all(16.0),
                        color: isFirstPage ? Theme.of(context).accentColor : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text('ชวน', style: TextStyle(color: isFirstPage ? Colors.white : Colors.black)),
                        onPressed: () {
                          setState(() {
                            isFirstPage = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _widgetOptions(),
            )
          ],
        ),
      ),
    );
  }

}
