import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'DirectionsProvider.dart';
import "package:google_maps_webservice/places.dart" as p;


class CreateRoute extends StatefulWidget {


  @override
  _CreateRoutestate createState() => _CreateRoutestate();
}

class _CreateRoutestate extends State<CreateRoute> {
  final places = new p.GoogleMapsPlaces(apiKey:"AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q");
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



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location.onLocationChanged.listen((LocationData currentLocations) {
      setState(() {
        currentLocation = currentLocations;
        if(!isSet_Marker){
          _createMarkers();
          isSet_Marker = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create your route.'),
      ),
      body: Stack(
        children: <Widget>[Consumer<DirectionProvider>(
          builder: (BuildContext context, DirectionProvider api, Widget child) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation.latitude, currentLocation.longitude),
                zoom: 15,
              ),
              markers: Markers,
              polylines: api.Lines,
              onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            );
          },
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
      await _centerView(1);
    }
  }

  _nextplace() async{
    if( toPoint == null ){
      toPoint =  LatLng(currentLocation.latitude, currentLocation.longitude);
    }
    await _centerView(0);
    fromPoint = toPoint;
  }

  Set<Marker> _createMarkers() {
    var tmp = Set<Marker>();
    Markers.add(
      Marker(
        markerId: MarkerId("toPoint"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
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
      currentLocation = Locations;
    });
  }

  void _onDragEnd(LatLng a) {
    toPoint = a;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    _centerView(0);
  }

  _centerView(int x) async {
    if (fromPoint != null) {
    var api = Provider.of<DirectionProvider>(context, listen: false);

    await _mapController.getVisibleRegion();

    print("buscando direcciones");
    await api.findDirections(fromPoint, toPoint, routes,temp,x);
    routes = api.Routes;
    temp = api.Temp;

    var left = min(fromPoint.latitude, toPoint.latitude);
    var right = max(fromPoint.latitude, toPoint.latitude);
    var top = max(fromPoint.longitude, toPoint.longitude);
    var bottom = min(fromPoint.longitude, toPoint.longitude);

    api.Lines.first.points.forEach((point) {
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
