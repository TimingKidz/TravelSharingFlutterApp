import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/buttons/cardTileWithTapMatch.dart';


class MatchList extends StatefulWidget {
  final Travel_Info data;
  static final GlobalKey<_MatchListstate> dashboardKey = GlobalKey<_MatchListstate>();

  MatchList({Key key, this.data}) : super(key: dashboardKey);
  @override
  _MatchListstate createState() => _MatchListstate();
}

class _MatchListstate extends State<MatchList> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Location location = Location();
  LocationData Locations;
  List<Match_Info> _MatchList = List();
  bool isFirstPage = true;
  List<String> isreq = List();

  @override
  void initState(){
    super.initState();
    getData();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          getData();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ส่งคำขอให้คนที่คุณจะไปด้วย'),
        elevation: 2.0,
      ),
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

  _onButtonPressed(Match_Info data) async {
    Routes().Request(data,widget.data);
    await getData();
  }

}
