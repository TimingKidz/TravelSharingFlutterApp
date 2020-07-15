import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' ;
import "package:google_maps_webservice/places.dart" as p;
import 'package:google_maps_webservice/directions.dart' as d;
import 'package:flutter_polyline_points/flutter_polyline_points.dart' ;
import 'package:travel_sharing/Pages/dashboard.dart';


class CreateRoute extends StatefulWidget {
//  final LocationData gps;
//  CreateRoute({this.gps}) ;

  @override
  _CreateRoutestate createState() => _CreateRoutestate();
}

class _CreateRoutestate extends State<CreateRoute> {
  static final String api_key = "AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q";
  final places = new p.GoogleMapsPlaces(apiKey: api_key);
  GoogleMapController _mapController;
  List<LatLng> routes = List();
  Set<Polyline> lines = Set();
  List<LatLng> temp = List();
  LatLng fromPoint = null;
  LatLng toPoint = null;
  Set<Marker> Markers = Set();
  LocationData currentLocation ;
  Location location = Location();
  bool isSet_Marker = false;
  LatLng current_Location ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      location.onLocationChanged.listen((LocationData currentLocations) {
      if(!isSet_Marker) {
        current_Location =
            LatLng(currentLocations.latitude, currentLocations.longitude);
        _createMarkers();
        isSet_Marker = true;
        setState(() {});
      }
      });
  }

  findDirections(bool isFind_Direction ) async {
    var origin = PointLatLng(fromPoint.latitude, fromPoint.longitude);
    var destination = PointLatLng(toPoint.latitude, toPoint.longitude);
    if( isFind_Direction ){
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates("AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q", origin,destination);
      PointLatLng Ll = result.points.first;
      temp.add(LatLng(Ll.latitude,Ll.longitude));
      result.points.forEach((step) {
        routes.add(LatLng(step.latitude, step.longitude));
      });
    }
    var line = Polyline(
      points: routes,
      geodesic: true,
      polylineId: PolylineId("mejor ruta"),
      color: Colors.blue,
      width: 4,
    );
    setState(() {
      lines.add(line);
    });


  }

  @override
  Widget build(BuildContext context) {
//    getCurrentLocation();
  if(current_Location != null){
    return Scaffold(
      appBar: AppBar(
        title: Text('Create your route.'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(0,0),
              zoom: 15,
            ),
            markers: Markers,
            polylines: lines,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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
                  onPressed: _stepBack,
                ),
                FloatingActionButton.extended(
                    label: Text('Finish'),
                    onPressed: _Fin
                ),
                FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: _nextplace
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  }

  _Fin() async{
    p.PlacesSearchResponse response = await places.searchNearbyWithRadius(new p.Location(routes.last.latitude,routes.last.longitude),200);
    print("444444");
    print(response.results.first.name);
    print(jsonEncode(routes));
    setState(() {
      Markers.clear();
      Markers.add(
          Marker(
            markerId: MarkerId("St"),
            position: routes.last,
            infoWindow: InfoWindow(title: "Roca 123"),
          )
      );
      Markers.add(
          Marker(
            markerId: MarkerId("Dst"),
            position: routes.first,
            infoWindow: InfoWindow(title: "Roca 123"),
          )
      );
    });
  }

  _stepBack() async {
    if(!temp.isEmpty){
      int index = routes.indexOf(temp.last);
      routes.removeRange(index+1, routes.length);
      fromPoint = temp.removeLast();
      await _centerView(false);
    }
  }

  _nextplace() async{
    if( toPoint == null ){
      toPoint =  current_Location;
    }
    await _centerView(true);
    fromPoint = toPoint;
  }

  Set<Marker> _createMarkers() {
    var tmp = Set<Marker>();
    Markers.add(
      Marker(
        markerId: MarkerId("toPoint"),
        position: current_Location,
        draggable: true,
        onDragEnd: _onDragEnd,
        infoWindow: InfoWindow(title: "Roca 123"),
      ),
    );
    return tmp;
  }

  void getCurrentLocation() async {
    LocationData Locations;
    try {
      Locations = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        Locations = null;
      }
    }
    setState(() {
      current_Location = LatLng(Locations.latitude,Locations.longitude);
    });


  }

  void _onDragEnd(LatLng new_point) {
    toPoint = new_point;

  }

  void _onMapCreated(GoogleMapController controller){
    _mapController = controller;
    getCurrentLocation();
    current_Location = LatLng(currentLocation.latitude,currentLocation.longitude);
    _centerView(true);
  }

  _centerView(bool isFind_Direction ) async {
    if (fromPoint != null) {
    await _mapController.getVisibleRegion();
    await findDirections(isFind_Direction);

    var left = min(fromPoint.latitude, toPoint.latitude);
    var right = max(fromPoint.latitude, toPoint.latitude);
    var top = max(fromPoint.longitude, toPoint.longitude);
    var bottom = min(fromPoint.longitude, toPoint.longitude);

    lines.first.points.forEach((point) {
      left = min(left, point.latitude);
      right = max(right, point.latitude);
      top = max(top, point.longitude);
      bottom = min(bottom, point.longitude);
    });

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.animateCamera(cameraUpdate);
  }
}
}
