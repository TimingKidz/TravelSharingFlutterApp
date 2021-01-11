import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/cardDatePicker.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

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
  void dispose() {
    super.dispose();
    // _formKey.currentState.reset(); // Clear form
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
        body: Stack(
          children: <Widget>[
            Form(
              // TODO: Add Tag and select Vehicle
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(8.0, MediaQuery.of(context).size.height * 0.135, 8.0, 8.0),
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.all(0.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.routes.last.latitude,widget.routes.last.longitude),
                              zoom: 14,
                            ),
                            markers: widget.Markers,
                            polylines: widget.lines ?? Set(),
                            zoomControlsEnabled: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  CardDropdown(
                    labelText: 'Tag',
                    listItems: ["Travel", "Travel & Activity"],
                    dropdownTileBuild: (value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    },
                    onChanged: (text) {

                    },
                  ),
                  SizedBox(height: 8.0),
                  CardTextField(
                    notNull: true,
                    initValue: widget.src,
                    labelText: 'ต้นทาง',
                    onChanged: (text) {
                      Final_Data.src = text;
                    },
                  ),
                  SizedBox(height: 8.0),
                  CardTextField(
                    notNull: true,
                    initValue: widget.dst,
                    labelText: 'ปลายทาง',
                    onChanged: (text) {
                      Final_Data.dst = text;
                    },
                  ),
                  SizedBox(height: 8.0),
                  CardDatePicker(
                    labelText: 'วันเดินทาง',
                    onDatePick: (date) {
                      Final_Data.date = date;
                      print(date);
                    },
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: CardTextField(
                          notNull: true,
                          labelText: 'จำนวนคนไปด้วย',
                          type: TextInputType.number,
                          onChanged: (text) {
                            Final_Data.amount = text;
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: CardTextField(
                          notNull: true,
                          labelText: 'ราคา',
                          type: TextInputType.number,
                          onChanged: (text) {

                          },
                        ),
                      )
                    ],
                  ),
                  if(widget.Role == 0)
                    SizedBox(height: 8.0),
                  if(widget.Role == 0)
                    CardDropdown(
                      labelText: 'ยานพาหนะที่จะใช้',
                      listItems: currentUser.vehicle,
                      dropdownTileBuild: (value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                              "${value.brand} ${value.model} - ${value.license}"
                          ),
                        );
                      },
                      onChanged: (text) {
                        print(text);
                      },
                    ),
                  SizedBox(height: 72)
                ],
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
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        tooltip: AppLocalizations.instance.text("back"),
                        iconSize: 26.0,
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        AppLocalizations.instance.text("InfoFormTitle"),
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                        // textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              bottom: 16,
              right: 16,
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                  elevation: 2,
                  highlightElevation: 2,
                  icon: Icon(Icons.check),
                  label: Text("Finish"),
                  onPressed: (){
                    if(_formKey.currentState.validate()) _SavetoDB();
                  },
                  heroTag: null,
                ),
              ),
            )
          ],
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
        amount : Final_Data.amount, date :Final_Data.date, isMatch: false,match: List(),role : widget.Role.toString(),
        vehicle: widget.Role == 0 ? Vehicle(vid: currentUser.vehicle.first.vid ,type:  currentUser.vehicle.first.type) : Vehicle(),tag: ["T&A"]);
    Final_Data.SaveRoute_toDB(user).then((x){
      _formKey.currentState.reset(); // Clear form
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
    // go to dashboard

  }
}

