import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class Test extends StatefulWidget {
  final List<LatLng> routes;
  final LatLngBounds bounds;
  final Set<Polyline> lines;
  final Set<Marker> Markers;
  final String src ;
  final String dst;
  final int Role;

  const Test({Key key, this.routes, this.bounds, this.lines, this.Markers, this.src, this.dst,this.Role}) : super(key: key);

  _Test createState() => _Test();
}

class _Test extends State<Test> {
  final TextEditingController date_Textcontroller = new TextEditingController();
  GoogleMapController _mapController;
  Routes Final_Data = new Routes();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Final_Data.src = widget.src;
    Final_Data.dst = widget.dst;
    date_Textcontroller.text =  DateTime.now().toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Sign Up to Travel Sharing'),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.48,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),

                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 8,
                    child:
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(widget.routes.last.latitude,widget.routes.last.longitude),
                        zoom: 15,
                      ),
                      markers: widget.Markers,
                      polylines: widget.lines,
                      zoomControlsEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.40,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 8,
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            onChanged: (text){
                              Final_Data.src = text;
                            },
                            initialValue: widget.src ?? "",
                            decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Source',
                          ),
                          ),
                          TextFormField(
                            onChanged: (text){
                              Final_Data.dst = text;
                            },
                            initialValue: widget.dst ?? "",
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Destination',
                            ),
                          ),
                          TextFormField(
                            controller: date_Textcontroller,
                            onSaved: (text){
                              Final_Data.date = text;
                            },
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Date',
                            ),
                          ),
                          TextFormField(
                            onChanged: (text){
                              Final_Data.amount = text;
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Amount',
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              child: Icon(Icons.arrow_forward),
                              onPressed: _SavetoDB,
                              heroTag: null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    Final_Data = new Routes(id: user.id,routes : widget.routes,src : Final_Data.src,dst : Final_Data.dst,amount : Final_Data.amount,date :date_Textcontroller.text,isMatch: false,match: List());
    Final_Data.SaveRoute_toDB(widget.Role,user).then((x){
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }); // save to DB
    // go to dashboard

  }
}

