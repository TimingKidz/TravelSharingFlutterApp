import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_sharing/Pages/home.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
/// This Widget is the main application widget.


class Dashboard extends StatefulWidget {


  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  Location location = Location();
  LocationData Locations;
  int _selectedIndex = 0;
  Widget _widgetOptions(){
    if(_selectedIndex == 0){
      return Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: _newroute1,
            ),

          ],
        ),
      );
    }else{
      return Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: _newroute,
            ),
          ],
        ),
      );
    }
  }



  _newroute() async{
//    try {
//      Locations = await location.getLocation();
//      int x = 0;
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreateRoute()));
//    } on PlatformException catch (e) {
//      if (e.code == 'PERMISSION_DENIED') {
//        Locations = null;
//      }
//    }

  }

  _newroute1() async{
//    try {
//      Locations = await location.getLocation();
//      int x = 0;
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => Home()));
//    } on PlatformException catch (e) {
//      if (e.code == 'PERMISSION_DENIED') {
//        Locations = null;
//      }
//    }

  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: _widgetOptions(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('ไปด้วย'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            title: Text('ชวน'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

}
