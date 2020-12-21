import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/Pages/VehicleManagement/VehicleAddForm.dart';
import 'package:travel_sharing/buttons/VehicleCardTileFull.dart';
import 'package:travel_sharing/main.dart';

class VehicleManagePage extends StatefulWidget {
  VehicleManagePageState createState() => VehicleManagePageState();
}

class VehicleManagePageState extends State<VehicleManagePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Management"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
                  Navigator.push(context,MaterialPageRoute(
                  builder : (context) => VehicleAddForm())).then((value){
                _pageConfig();
                setState((){});
              });
            },
          )
        ],
      ),
      body: _buildListView(),
    );
  }

  _pageConfig(){
    socket.off('onNewNotification');
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showNotification(message);
        }
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: currentUser.vehicle.length,
        itemBuilder: (context, i) {
          return _buildRow(currentUser.vehicle[i]);
        }
    );
  }

  Widget _buildRow(Vehicle data) {
    return VehicleCardTileFull(
      data: data,
      cardMargin: 8.0,
      setState: getData,
    );
  }

  Future<void> getData() async {
    currentUser = await currentUser.getCurrentuser(currentUser.id);
    setState(() {});
  }

}