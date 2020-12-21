import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/main.dart';

class VehicleAddForm extends StatefulWidget {
  VehicleAddFormState createState() => VehicleAddFormState();
}

class VehicleAddFormState extends State<VehicleAddForm> {
  Vehicle vehicleData = Vehicle();
  bool isChecked = true;

  @override
  void initState() {
    super.initState();
    vehicleData.isDefault = false;
    _pageConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Vehicle"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              await vehicleData.addVehicle();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: formList(),
      ),
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

  List<Widget> formList(){
    return [
      CardTextField(
        labelText: "Type",
        onChanged: (data) => vehicleData.type = data,
      ),
      CardTextField(
        labelText: "License",
        onChanged: (data) => vehicleData.license = data,
      ),
      CardTextField(
        labelText: "Brand",
        onChanged: (data) => vehicleData.brand = data,
      ),
      CardTextField(
        labelText: "Model",
        onChanged: (data) => vehicleData.model = data,
      ),
      CardTextField(
        labelText: "Color",
        onChanged: (data) => vehicleData.color = data,
      ),
      CheckboxListTile(
        title: const Text("Set to default vehicle"),
        value: vehicleData.isDefault,
        onChanged: (val){
          setState(() {
            vehicleData.isDefault = val;
          });
        },
      ),
    ];
  }

}