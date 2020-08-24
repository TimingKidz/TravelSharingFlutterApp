import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/buttons/cardTileWithTap.dart';
import 'package:travel_sharing/buttons/cardTileWithTapMatch.dart';
/// This Widget is the main application widget.


class MatchList extends StatefulWidget {
  final Map<String, dynamic> data;
  static final GlobalKey<_MatchListstate> dashboardKey = GlobalKey<_MatchListstate>();

  MatchList({Key key, this.data}) : super(key: dashboardKey);
  @override
  _MatchListstate createState() => _MatchListstate();
}

class _MatchListstate extends State<MatchList> {
  Location location = Location();
  LocationData Locations;
  List< Map<String,dynamic>> _MatchList = List();
  bool isFirstPage = true;
  List<String> isreq = List();

  // get Match list of current routes
  Future<void> getData() async {
    try{
      _MatchList =  await widget.data['detail'].getNearRoutes() ?? [];
      isreq = await User().getisReq(widget.data['id'], widget.data['_id']) ?? [];
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

  Widget _buildRow( Map<String,dynamic> data) {
    if(isreq.contains(data['_id'])){
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

//  _onButtonPressed(Map<String,dynamic> data){
//
//
//  }
  _onCardPressed(Map<String,dynamic> data) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => mapview(from:widget.data,to:data)));
  }

  _onButtonPressed(Map<String,dynamic> data) {
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
