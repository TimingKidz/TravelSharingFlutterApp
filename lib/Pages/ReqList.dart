import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/buttons/cardTileWithTapMatch.dart';
import 'package:travel_sharing/buttons/cardTileWithTapReq.dart';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/main.dart';

import 'dashboard.dart';

// ==================================== CLASS ========================================
class Req_Info {
  Routes routes;
  String id;
  String uid;
  String name;
  String reqid;

  Req_Info({this.routes, this.id,this.uid,this.name,this.reqid});

  Req_Info.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json['detail']);
    id = json['id'];
    uid = json['_id'];
    name = json['name'];
    reqid = json['reqid'];
  }

  Future<List<Req_Info>> getReq(Travel_Info data) async {
    try{
      var url = "${HTTP().API_IP}/api/user/getReqList";
      Http.Response response = await Http.post(url, headers: HTTP().header , body: jsonEncode({'id':data.id,'to_id':data.uid}));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          List<dynamic> Data = jsonDecode(response.body);
          List<Req_Info> Req_Info_List = List();
          Data.forEach((x) {
            Req_Info tmp = Req_Info.fromJson(x);
            Req_Info_List.add(tmp);
          });
          return Future.value(Req_Info_List);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Req");
    }
  }
}
// ==================================== END CLASS ========================================

class ReqList extends StatefulWidget {
  final Travel_Info data; // current routes
  final User currentUser;
  static final GlobalKey<_ReqListstate> dashboardKey = GlobalKey<_ReqListstate>();

  ReqList({Key key, this.data,this.currentUser}) : super(key: dashboardKey);

  @override
  _ReqListstate createState() => _ReqListstate();
}



class _ReqListstate extends State<ReqList> {
  List<Req_Info> _ReqList = List();
  bool isFirstPage = true;

  // get request list of current routes
  Future<void> getData() async {
    try{
      _ReqList =  await Req_Info().getReq(widget.data) ?? [];
      setState(() {});
    }catch(error){
      print(error);
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Widget _widgetOptions(){
    if(_ReqList.isEmpty){
      return Center(
        child: Text('No List'),
      );
    }else{
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
        itemCount: _ReqList.length,
        itemBuilder: (context, i) {
          return _buildRow(_ReqList[i]);
        });
  }

  Widget _buildRow( Req_Info data) {
    return CardTileWithTapReq(
      data: data,
      onCardPressed:() => _onCardPressed(data),
      onAcceptPressed: () => _onAcceptPressed(data),
      onDeclinePressed: () => _onDeclinePressed(data),
    );
  }

  _onCardPressed(Req_Info data) async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => mapview(from:data.routes,to:widget.data.routes)));
  }

  _onAcceptPressed(Req_Info data) async{
    widget.currentUser.AcceptReq(data.reqid,widget.data.id,widget.data.uid);
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => Matchinformation()));
  }

  _onDeclinePressed(Req_Info data) async{
    widget.currentUser.DeclineReq(data.reqid,widget.data.id,widget.data.uid);
    getData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตอบรับคำขอของคนที่จะไปด้วย'),
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
