import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
/// This Widget is the main application widget.


class Dashboard extends StatefulWidget {
  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  Location location = Location();
  LocationData Locations;

//  final _joinList = <String>['A', 'B', 'C', 'D'];
//  final _invitedList = <String>['E', 'F', 'G', 'H'];
  List<Map<String, dynamic>> _joinList  = List();
  List<Map<String, dynamic>> _invitedList = List();
  bool isFirstPage = true;

  Future<void> getData() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      User user = await User().getCurrentuser(prefs.getString("CurrentUser_id"));
      _invitedList =  await user.getRoutes(0) ?? [];
      _joinList =  await user.getRoutes(1) ?? [];
      _invitedList.sort((a,b) => b['detail'].date.compareTo(a['detail'].date));
      _joinList.sort((a,b) => b['detail'].date.compareTo(a['detail'].date));
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
        });
  }

  Widget _buildRow(Map<String, dynamic> data) {
    print(data);
    return CardTileWithTap(
      isFirstPage: isFirstPage,
      data: data['detail'],
      onCardPressed: () => _onCardPressed(data),
    );
  }

  _onCardPressed(Map<String, dynamic> data){
    if( isFirstPage ){
      if( data['detail'].isMatch ){
// information
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation()));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MatchList(data: data)));

      }
    }else{
      if( data['detail'].isMatch){
// information
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation()));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ReqList(data: data)));

      }
    }

  }



  _newroute() async{
//    try {
//      Locations = await location.getLocation();
//      int x = 0;
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreateRoute())).then((value) {
        getData();
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
      getData();
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: isFirstPage ? Theme.of(context).colorScheme.orange : Theme.of(context).colorScheme.cardFlag,
        automaticallyImplyLeading: false,
        title: const Text('แดชบอร์ด'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: isFirstPage ? _newroute1 : _newroute,
        backgroundColor: isFirstPage ? Theme.of(context).colorScheme.redOrange : Theme.of(context).colorScheme.info,
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
                    color: isFirstPage ? Theme.of(context).colorScheme.orange : Theme.of(context).colorScheme.cardFlag,
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
                        color: isFirstPage ? Colors.white : Theme.of(context).colorScheme.info,
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
