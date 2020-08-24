import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/buttons/cardDatePicker.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';

class InfoFill extends StatefulWidget {
  final List<LatLng> routes;
  final LatLngBounds bounds;
  final Set<Polyline> lines;
  final Set<Marker> Markers;
  final String src ;
  final String dst;
  final int Role;

  const InfoFill({Key key, this.routes, this.bounds, this.lines, this.Markers, this.src, this.dst,this.Role}) : super(key: key);

  _InfoFillState createState() => _InfoFillState();
}

class _InfoFillState extends State<InfoFill> {
  final TextEditingController date_Textcontroller = new TextEditingController();
  GoogleMapController _mapController;
  Routes Final_Data = new Routes();

  @override
  void initState() {
    super.initState();
    Final_Data.src = widget.src;
    Final_Data.dst = widget.dst;
    date_Textcontroller.text =  DateTime.now().toIso8601String();
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
          onPressed: _SavetoDB,
          heroTag: null,
        ),
        body: ListView(
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
                polylines: widget.lines,
                zoomControlsEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
            CardTextField(
              initValue: widget.src,
              labelText: 'ต้นทาง',
              onChanged: (text) {
                Final_Data.src = text;
              },
            ),
            CardTextField(
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
              },
            ),
            CardTextField(
              labelText: 'จำนวนคนไปด้วย',
              type: TextInputType.number,
              onChanged: (text) {
                Final_Data.amount = text;
              },
            )
          ],
        )
      );
  }

  // set camera to cover all routes in map
  void _onMapCreated(GoogleMapController controller) async{
    var cameraUpdate = CameraUpdate.newLatLngBounds(widget.bounds, 50);
    await controller.animateCamera(cameraUpdate);
    _mapController = controller;
  }

  _SavetoDB()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();  // get id of current user from local
    User user = await User().getCurrentuser(prefs.getString("CurrentUser_id")); // get user data of current user from DB
    // prepare Route data for save to DB
    Final_Data = new Routes(id: user.id, routes : widget.routes, src : Final_Data.src, dst : Final_Data.dst, amount : Final_Data.amount, date :Final_Data.date, isMatch: false,match: List());
    Final_Data.SaveRoute_toDB(widget.Role,user).then((x){
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }); // save to DB
    // go to dashboard

  }
}

