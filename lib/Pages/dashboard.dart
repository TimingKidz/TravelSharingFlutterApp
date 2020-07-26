import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/buttons/cardTileWithTap.dart';
/// This Widget is the main application widget.


class Dashboard extends StatefulWidget {
  static final GlobalKey<_Dashboard> dashboardKey = GlobalKey<_Dashboard>();

  Dashboard() : super(key: dashboardKey);

  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  Location location = Location();
  LocationData Locations;

//  final _joinList = <String>['A', 'B', 'C', 'D'];
//  final _invitedList = <String>['E', 'F', 'G', 'H'];
  List<Routes> _joinList  = List();
  List<Routes> _invitedList = List();
  bool isFirstPage = true;

  Future<bool> getData() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      User user = await User().getCurrentuser(prefs.getString("CurrentUser_id"));
      _invitedList =  await user.getRoutes(0) ?? [];
      _joinList =  await user.getRoutes(1) ?? [];
      return Future.value(true);
    }catch(error){
      print(error);
      return Future.value(false);
    }

  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getData().then((value) {
      setState(() {});
    });

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
        itemCount: isFirstPage ? _joinList.length : _invitedList.length,
        itemBuilder: (context, i) {
          return _buildRow(isFirstPage ? _joinList[i] : _invitedList[i]);
        });
  }

  Widget _buildRow(Routes data) {
    return CardTileWithTap(
      data: data,
    );
  }

  _newroute() async{
//    try {
//      Locations = await location.getLocation();
//      int x = 0;
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreateRoute())).then((value) {
        getData().then((value) {
          setState(() {});
        });
      });
//    } on PlatformException catch (e) {
//      if (e.code == 'PERMISSION_DENIED') {
//        Locations = null;
//      }
//    }

  }

  _newroute1() async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CreateRoute_Join())).then((value) {
      getData().then((value) {
        setState(() {});
      });
    });


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
        child: Icon(Icons.add),
        onPressed: isFirstPage ? _newroute1 : _newroute,
        heroTag: null,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      highlightElevation: 0.0,
                      padding: EdgeInsets.all(16.0),
                      color: isFirstPage ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text('ไปด้วย', style: TextStyle(color: isFirstPage ? Colors.white : Colors.black)),
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
                      color: isFirstPage ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text('ชวน', style: TextStyle(color: isFirstPage ? Colors.black : Colors.white)),
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
            Expanded(
              child: _widgetOptions(),
            )
          ],
        ),
      ),
    );
  }

}
