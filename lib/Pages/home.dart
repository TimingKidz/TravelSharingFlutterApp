import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/customAppbar.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(13.7650836, 100.5379664),
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          CustomAppbar(
            title: 'create your route',
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: (){}
                ),
                FloatingActionButton.extended(
                    label: Text('Finish'),
                    onPressed: (){}
                ),
                FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: (){}
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}