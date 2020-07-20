import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:travel_sharing/Pages/dashboard.dart';
import 'package:travel_sharing/Pages/home.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class Test extends StatefulWidget {
  final List<LatLng> routes;
  final bounds;
  final Set<Polyline> lines;
  final Set<Marker> Markers;

  const Test({Key key, this.routes, this.bounds, this.lines, this.Markers}) : super(key: key);


  _Test createState() => _Test();
}

class _Test extends State<Test> {
  GoogleMapController _mapController;
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

                        target: LatLng(0,0),
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
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          FloatingActionButton(
                            child: Icon(Icons.arrow_forward),
                            onPressed: _Nextpage,
                            heroTag: null,
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
  void _onMapCreated(GoogleMapController controller){
    _mapController = controller;
    setState(() {

    });
    var cameraUpdate = CameraUpdate.newLatLngBounds(widget.bounds, 50);
    _mapController.animateCamera(cameraUpdate);

  }

  _Nextpage(){
    Navigator.push(context,MaterialPageRoute(
        builder : (context) => Dashboard()));
  }
}

