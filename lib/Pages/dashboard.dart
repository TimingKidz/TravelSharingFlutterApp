import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/MatchList.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/ReqList.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/buttons/cardTileWithTap.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/main.dart';


class Dashboard extends StatefulWidget {
  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  Location location = Location();
  LocationData Locations;
  List<Travel_Info> _joinList  = List();
  List<Travel_Info> _invitedList = List();
  bool isFirstPage = true;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
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

  Future<void> getData() async {
    try{
      _invitedList =  await Travel_Info().getRoutes(currentUser.uid,0) ?? [];
      _joinList =  await Travel_Info().getRoutes(currentUser.uid,1) ?? [];
      _invitedList.sort((a,b) => b.routes.date.compareTo(a.routes.date));
      _joinList.sort((a,b) => b.routes.date.compareTo(a.routes.date));
      debugPrint('$_joinList');
      setState(() {});
    }catch(error){
      print("$error lll");
    }
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
      if( data.routes.match.isNotEmpty ){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: data.routes.match.first)));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MatchList(data: data)));
      }
    }else{
      if( data.routes.match.isNotEmpty){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: data.uid)));
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ReqList(data: data)));
      }
    }
  }

  _newroute() async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CreateRoute())).then((value) {
      getData();
    });
  }

  _newroute1() async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CreateRoute_Join())).then((value) {
      getData();
    });
  }

}
