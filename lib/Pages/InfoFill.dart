import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/buttons/cardDatePicker.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/main.dart';

class InfoFill extends StatefulWidget {
  final List<LatLng> routes;
  final LatLngBounds bounds;
  final Set<Polyline> lines;
  final Set<Marker> Markers;
  final String src ;
  final String dst;
  final int Role;

  const InfoFill({Key key,this.routes, this.bounds, this.lines, this.Markers, this.src, this.dst,this.Role}) : super(key: key);

  _InfoFillState createState() => _InfoFillState();
}

class _InfoFillState extends State<InfoFill> {
  GoogleMapController _mapController;
  Routes Final_Data = new Routes();
  final _formKey = GlobalKey<FormState>();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }



  @override
  void initState() {
    super.initState();
    _pageConfig();
    Final_Data.date =  DateTime.now().toString();
    Final_Data.src = widget.src;
    Final_Data.dst = widget.dst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
//          automaticallyImplyLeading: false,
          title: Text('ข้อมูลการเดินทาง'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: (){
            if(_formKey.currentState.validate()) _SavetoDB();
          },
          heroTag: null,
        ),
        body: Form(
          // TODO: Add Tag and select Vehicle
          key: _formKey,
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.routes.last.latitude,widget.routes.last.longitude),
                    zoom: 14,
                  ),
                  markers: widget.Markers,
                  polylines: widget.lines ?? Set(),
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
              CardTextField(
                notNull: true,
                initValue: widget.src,
                labelText: 'ต้นทาง',
                onChanged: (text) {
                  Final_Data.src = text;
                },
              ),
              CardTextField(
                notNull: true,
                initValue: widget.dst,
                labelText: 'ปลายทาง',
                onChanged: (text) {
                  Final_Data.dst = text;
                },
              ),
              CardDatePicker(
                labelText: 'วันเดินทาง',
                onDatePick: (date) {
                  Final_Data.date = date;
                  print(date);
                },
              ),
              CardTextField(
                notNull: true,
                labelText: 'จำนวนคนไปด้วย',
                type: TextInputType.number,
                onChanged: (text) {
                  Final_Data.amount = text;
                },
              )
            ],
          ),
        )
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

  // set camera to cover all routes in map
  void _onMapCreated(GoogleMapController controller) async{
    _mapController = controller;
    Future.delayed(new Duration(milliseconds: 100), () async {
      await _mapController.animateCamera(CameraUpdate.newLatLngBounds(widget.bounds, 50));
    });

    print("dddddd");

  }

  _SavetoDB()async{
    User user = currentUser ;
    Final_Data = new Routes(id: user.uid, routes : widget.routes, src : Final_Data.src, dst : Final_Data.dst,
        amount : Final_Data.amount, date :Final_Data.date, isMatch: false,match: List(),role : widget.Role.toString());
    Final_Data.SaveRoute_toDB(user).then((x){
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
    // go to dashboard

  }
}

