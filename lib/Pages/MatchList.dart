import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
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

  // get Match list of current routes
  Future<void> getData() async {
    try{
      _MatchList =  await widget.data['detail'].getNearRoutes() ?? [];
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
    return CardTileWithTapMatch(
      data: data,
      onCardPressed:() => _onCardPressed(data),
    );
  }

  _onCardPressed(Map<String,dynamic> data) {
    Routes().Request(data,widget.data);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.dashboard),
        onPressed: (){
          Navigator.of(context).pop();
        },
        heroTag: null,
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

}
