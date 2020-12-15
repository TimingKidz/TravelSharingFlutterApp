import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/VehicleCardTileFull.dart';
import 'file:///C:/Users/timin/AndroidStudioProjects/TravelSharingFlutterApp/lib/Pages/VehicleManagement/VehicleAddForm.dart';
import 'package:travel_sharing/buttons/VehicleCardTileMin.dart';
import 'package:travel_sharing/main.dart';

class VehicleManagePage extends StatefulWidget {
  VehicleManagePageState createState() => VehicleManagePageState();
}

class VehicleManagePageState extends State<VehicleManagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Management"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context,MaterialPageRoute(
                  builder : (context) => VehicleAddForm())).then((value) => getData());
            },
          )
        ],
      ),
      body: _buildListView(),
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