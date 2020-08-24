import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as l;
import 'package:location/location.dart' ;
import "package:google_maps_webservice/places.dart" as p;
import 'package:flutter_polyline_points/flutter_polyline_points.dart' ;
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Pages/test.dart';

class mapview extends StatefulWidget {
  final Map<String,dynamic> from;
  final Map<String,dynamic> to;

  const mapview({Key key, this.from, this.to}) : super(key: key);

  @override
  _mapview createState() => _mapview();
}

class _mapview extends State<mapview> {
  static final String api_key = "AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q";
  final places = new p.GoogleMapsPlaces(apiKey: api_key);
  final l.Distance distance = new l.Distance();
  p.GoogleMapsPlaces _places = p.GoogleMapsPlaces(apiKey: api_key);
  GoogleMapController _mapController;
  List<LatLng> routes = List();
  Set<Polyline> lines = Set();
  List<LatLng> temp = List();
  Map<LatLng,String> Name_list = Map();
  LatLng fromPoint = null;
  LatLng toPoint = null;
  Set<Marker> Markers = Set();
  LocationData currentLocation ;
  Location location = Location();
  bool isSet_Marker = false;
  LatLng current_Location ;
  LatLngBounds bounds ;
  p.PlacesSearchResult tmp = null;
  LatLng src = null;
  LatLng dst = null;
  static int Role = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createMarkers();
    // callback currentLocation for first time

  }

  // find direction to destination
  findDirections(bool isFind_Direction ) async {


    // create line of routes on map
    var line = Polyline(
      points: widget.to['detail'].routes,
      geodesic: true,
      polylineId: PolylineId("mejor ruta"),
      color: Colors.blue,
      width: 4,
    );

    setState(() {
      lines.clear();
      lines.add(line);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create your route.'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(16.294922,100.928026),
              zoom: 5,
            ),
            markers: Markers,
            polylines: lines,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
//            onCameraMove: center,
          ),


        ],
      ),
    );
  }











  _createMarkers() {
    Markers.clear();
    Markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: widget.from['detail'].routes.first,
        infoWindow: InfoWindow(title: "Roca 123"),

      ),
    );
    Markers.add(
      Marker(
        markerId: MarkerId("2"),
        position: widget.from['detail'].routes.last,
        infoWindow: InfoWindow(title: "Roca 123"),
      ),
    );
    setState(() {});
  }




  void _onMapCreated(GoogleMapController controller) async{
    _mapController = controller;
    await _centerView(true);
  }

  _centerView(bool isFind_Direction ) async {
      await _mapController.getVisibleRegion();
      await findDirections(isFind_Direction);

      Routes temp = widget.from['detail'];
      var left = min(temp.routes.first.latitude, temp.routes.last.latitude);
      var right = max(temp.routes.first.latitude, temp.routes.last.latitude);
      var top = max(temp.routes.first.longitude, temp.routes.last.longitude);
      var bottom = min(temp.routes.first.longitude, temp.routes.last.longitude);

      lines.first.points.forEach((point) {
        left = min(left, point.latitude);
        right = max(right, point.latitude);
        top = max(top, point.longitude);
        bottom = min(bottom, point.longitude);
      });
      bounds = LatLngBounds(
        southwest: LatLng(left, bottom),
        northeast: LatLng(right, top),
      );
      var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
      _mapController.animateCamera(cameraUpdate);

  }
}
