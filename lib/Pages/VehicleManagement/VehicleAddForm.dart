import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/main.dart';

class VehicleAddForm extends StatefulWidget {
  VehicleAddFormState createState() => VehicleAddFormState();
}

class VehicleAddFormState extends State<VehicleAddForm> {
  Vehicle vehicleData = Vehicle();
  bool isChecked = true;
  List<String> vehicleType = ["Motorcycle", "Cars"];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    vehicleData.isDefault = false;
    vehicleData.type = vehicleType.first;
    _pageConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 70),
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: formList(),
                ),
              ),
            ),
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(0.0),
              color: Theme.of(context).colorScheme.darkBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)
                  )
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            tooltip: "back",
                            iconSize: 26.0,
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          SizedBox(width: 16.0),
                          Text(
                            "Add Vehicle",
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                            // textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        tooltip: "Add vehicle",
                        iconSize: 26.0,
                        color: Colors.white,
                        onPressed: () async {
                          if(_formKey.currentState.validate()){
                            await vehicleData.addVehicle();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
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
    socket.off('onKick');

    socket.on('onKick', (data){
      currentUser.status.navbarTrip = true;
      currentUser.status.navbarNoti = true;
    });


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
      CardDropdown(
        listItems: vehicleType,
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