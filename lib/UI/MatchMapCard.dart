import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/Match_Info.dart';

class MatchMapCard extends StatefulWidget {
  final Match_Info data;
  final bool isreq;
  final Function onButtonPressed;

  const MatchMapCard({Key key, this.data, this.isreq, this.onButtonPressed}) : super(key: key);
  @override
  _MatchMapCardState createState() => _MatchMapCardState();
}

class _MatchMapCardState extends State<MatchMapCard> {
  GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              // target: LatLng(widget.routes.last.latitude,widget.routes.last.longitude),
              zoom: 14,
            ),
            // markers: widget.Markers,
            // polylines: widget.lines,
            scrollGesturesEnabled: false,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            zoomGesturesEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                child: Wrap(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('ปลายทาง', style: TextStyle(fontSize: 10.0)),
                              SizedBox(height: 5.0),
                              Text(widget.data.routes.dst, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                              SizedBox(height: 16.0),
                              Text('ต้นทาง', style: TextStyle(fontSize: 10.0)),
                              SizedBox(height: 5.0),
                              Text(widget.data.routes.src, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                              SizedBox(height: 16.0),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.account_circle, size: 32.0),
                                  SizedBox(width: 8.0),
                                  Text(widget.data.user.name, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: RaisedButton(
                            highlightElevation: 0.0,
                            padding: EdgeInsets.all(16.0),
                            color: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(widget.isreq ? 'ส่งคำขอแล้ว' : 'ส่งคำขอ', style: TextStyle(color: Colors.white,)),
                            onPressed: widget.isreq ? null : () => widget.onButtonPressed(),
                          ),
                        ),
                      ],
                    )
                  ],
                )
            ),
          ),
        )
      ],
    );
  }

  // set camera to cover all routes in map
  void _onMapCreated(GoogleMapController controller) async{
    // var cameraUpdate = CameraUpdate.newLatLngBounds(widget.bounds, 50);
    // await controller.animateCamera(cameraUpdate);
    _mapController = controller;
  }
}
