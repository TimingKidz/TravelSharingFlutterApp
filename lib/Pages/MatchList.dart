import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/dashboard.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/buttons/cardTileWithTap.dart';
import 'package:travel_sharing/buttons/cardTileWithTapMatch.dart';
/// This Widget is the main application widget.

import 'package:http/http.dart' as Http;
import 'package:travel_sharing/main.dart';
/// This Widget is the main application widget.
///
///


class Match_Info {
  Routes routes;
  String id;
  String uid;
  String name;

  Match_Info({this.routes, this.id ,this.uid,this.name});

  Match_Info.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json['detail']);
    id = json['detail']['id'];
    uid = json['_id'];
    name = json['name'];
  }

  Future< List<Match_Info>> getNearRoutes(Routes My_Routes) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/getNearRoutes";
      Http.Response response = await Http.post(url, headers: HTTP().header, body: jsonEncode( My_Routes.toJson()));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
          List<dynamic> data = jsonDecode(response.body);
          List< Match_Info > Match_Info_List = List();
          data.forEach((x) {
            Match_Info tmp = Match_Info.fromJson(x);
            Match_Info_List.add(tmp);
          });
          return Future.value(Match_Info_List);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Match");
    }
  }

}

class MatchList extends StatefulWidget {
  final Travel_Info data;
  static final GlobalKey<_MatchListstate> dashboardKey = GlobalKey<_MatchListstate>();

  MatchList({Key key, this.data}) : super(key: dashboardKey);
  @override
  _MatchListstate createState() => _MatchListstate();
}

class _MatchListstate extends State<MatchList> {
  Location location = Location();
  LocationData Locations;
  List<Match_Info> _MatchList = List();
  bool isFirstPage = true;
  List<String> isreq = List();

  // get Match list of current routes
  Future<void> getData() async {
    try{
      _MatchList =  await Match_Info().getNearRoutes(widget.data.routes) ?? [];
      isreq = await User().getisReq(widget.data.id, widget.data.uid) ?? [];
      setState(() {});
    }catch(error){
      print(error+" From : MatchList getData()");
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Widget _widgetOptions(){
    if(_MatchList.isEmpty){
      return Center(
        child: Text('No List'),
      );
    }else{
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
        itemCount: _MatchList.length,
        itemBuilder: (context, i) {
          return _buildRow(_MatchList[i]);
        });
  }

  Widget _buildRow( Match_Info data) {
    if(isreq.contains(data.uid)){
      return CardTileWithTapMatch(
        data: data,
        isreq: true,
        onCardPressed:() => _onCardPressed(data),
        onButtonPressed: () => _onButtonPressed(data),
      );
    }else{
      return CardTileWithTapMatch(
        data: data,
        isreq: false,
        onCardPressed:() => _onCardPressed(data),
        onButtonPressed: () => _onButtonPressed(data),
      );
    }

  }

  _onCardPressed(Match_Info data) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => mapview(from:widget.data.routes,to:data.routes)));
  }

  _onButtonPressed(Match_Info data) {
    Routes().Request(data,widget.data);
    getData();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ส่งคำขอให้คนที่คุณจะไปด้วย'),
        elevation: 2.0,
      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.dashboard),
//        onPressed: (){
//          Navigator.of(context).pop();
//        },
//        heroTag: null,
//      ),

      body: Center(
        child: Column(
          children: <Widget>[

            Expanded(
              child: _widgetOptions(),
            ),

          ],
        ),
      ),
    );
  }

}
