import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/main.dart';

class VehicleAddForm extends StatefulWidget {
  VehicleAddFormState createState() => VehicleAddFormState();
}

class VehicleAddFormState extends State<VehicleAddForm> {
  Vehicle vehicleData = Vehicle();
  bool isChecked = true;
  final _formKey = GlobalKey<FormState>();

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
              if(_formKey.currentState.validate()){
                await vehicleData.addVehicle();
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: formList(),
        ),
      )
    );
  }

  _pageConfig(){
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');

    socket.on('onRequest', (data) {
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewMatch' , (data){
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewAccept', (data){
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewMessage',(data){
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewAccept',(data){
      currentUser.status.navbarTrip = true;
    });
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
      // CardTextField(
      //   notNull: true,
      //   labelText: "Type",
      //   onChanged: (data) => vehicleData.type = data,
      // ),
      CardDropdown(
        listItems: <String>[
          "Motorcycle",
          "Cars"
        ],
        labelText: "Type",
        onChanged: (data) => vehicleData.type = data,
      ),
      CardTextField(
        notNull: true,
        labelText: "License",
        onChanged: (data) => vehicleData.license = data,
      ),
      CardTextField(
        notNull: true,
        labelText: "Brand",
        onChanged: (data) => vehicleData.brand = data,
      ),
      CardTextField(
        notNull: true,
        labelText: "Model",
        onChanged: (data) => vehicleData.model = data,
      ),
      CardTextField(
        notNull: true,
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