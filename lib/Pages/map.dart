import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as l;
import 'package:location/location.dart' ;
import "package:google_maps_webservice/places.dart" as p;
import 'package:google_maps_webservice/directions.dart' as d;
import 'package:flutter_polyline_points/flutter_polyline_points.dart' ;
import 'package:travel_sharing/Pages/dashboard.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:travel_sharing/Pages/test.dart';
import 'package:travel_sharing/customAppbar.dart';

class CreateRoute extends StatefulWidget {
//  final LocationData gps;
//  CreateRoute({this.gps}) ;

  @override
  _CreateRoutestate createState() => _CreateRoutestate();
}

class _CreateRoutestate extends State<CreateRoute> {
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
  static int Role = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      location.onLocationChanged.listen((LocationData currentLocations) {
      if(!isSet_Marker) {
        current_Location =
            LatLng(currentLocations.latitude, currentLocations.longitude);
        _mapController.animateCamera( CameraUpdate.newCameraPosition(CameraPosition(target: current_Location, zoom: 15,)));
        _createMarkers(current_Location);
        isSet_Marker = true;
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
  print(current_Location);
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
          Positioned(
            top: 10,
            right: 15,
            left: 15,
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  IconButton(
                    splashColor: Colors.grey,
                    icon: Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.text,
                      onTap: _Searchbar,
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Search..."),
                    ),
                  ),
                ],
              ),
            ),
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
                  heroTag: null,
                ),
                FloatingActionButton.extended(
                    label: Text('Finish'),
                    onPressed: _Fin,
                  heroTag: null,
                ),
                FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: _nextplace,
                  heroTag: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );


  }



  Future<void> _Searchbar() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (currentFocus.nextFocus()) {
      currentFocus.unfocus();
    }
    // show input autocomplete with selected mode
    // then get the Prediction selected
    p.Prediction P = await PlacesAutocomplete.show(
      context: context,
      apiKey: api_key,
      mode: Mode.overlay,
      language: "th",
      components: [p.Component(p.Component.country, "th")],
    );

    p.PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(P.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    toPoint = LatLng(lat,lng);
    Name_list.putIfAbsent(toPoint, () => detail.result.name);
    print(Name_list);
    _createMarkers(toPoint);
    _nextplace();
  }

  _Fin() async{
    print(Name_list);
    Markers.clear();
    Markers.add(
        Marker(
          markerId: MarkerId("Src"),
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

    String Placename_dst = Name_list[dst] ;
    String Placename_src = Name_list[src] ;
    print(dst);
    print(Placename_dst);
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => Test(routes: routes, bounds:bounds,Markers :Markers,lines :lines,src:Placename_src,dst: Placename_dst ,Role :Role)));





  }

  _stepBack() async {
    if(!temp.isEmpty){
      int index = routes.indexOf(temp.last);
      routes.removeRange(index+1, routes.length);
      fromPoint = temp.removeLast();
      await _centerView(false);
    }else {
      routes.clear();
      lines.clear();
      src = null;
      fromPoint = null;
    }

  }


  _nextplace() async{
    print("before to : $toPoint from : $fromPoint src : $src dst : $dst");
      if( toPoint == null ){
        toPoint =  current_Location;
      }
      if(src == null) {
        src = toPoint;
      }
      dst = toPoint;
      await _centerView(true);
      if(tmp != null){
        Name_list.putIfAbsent(toPoint, () => tmp.name);
      }
      fromPoint = toPoint;
      print("after to : $toPoint from : $fromPoint src : $src dst : $dst");
  }



   _createMarkers(LatLng x) {
//    Markers.clear();
    Markers.add(
      Marker(
        markerId: MarkerId("toPoint"),
        position: x,
        draggable: true,
        onDragEnd: _onDragEnd,
        infoWindow: InfoWindow(title: "Roca 123"),
      ),
    );
    setState(() {});
  }

//  void getCurrentLocation() async {
//    LocationData Locations;
//    try {
//      Locations = await location.getLocation();
//    } on PlatformException catch (e) {
//      if (e.code == 'PERMISSION_DENIED') {
//        Locations = null;
//      }
//    }
//    setState(() {
//      current_Location = LatLng(Locations.latitude,Locations.longitude);
//    });
//  }

  void _onDragEnd(LatLng new_point) async{
    tmp = null;
    p.PlacesSearchResponse response = await places.searchNearbyWithRadius(new p.Location(new_point.latitude,new_point.longitude), 10);
    int min = 10;
    response.results.forEach((element) {
      l.LatLng to = new l.LatLng(element.geometry.location.lat,element.geometry.location.lng);
      l.LatLng ori = new l.LatLng(new_point.latitude, new_point.longitude);
      if(distance(to,ori) <= min){
        tmp = element;
        print("${element.name} : ${distance(to,ori)} : $to");
      }
    });
    if(tmp!=null){
      toPoint = LatLng(tmp.geometry.location.lat,tmp.geometry.location.lng);
      _createMarkers(toPoint);
    }else {
      toPoint = new_point;
    }
  }

  void _onMapCreated(GoogleMapController controller) async{
    _mapController = controller;
//    current_Location = LatLng(currentLocation.latitude,currentLocation.longitude);
    await _centerView(true);
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

    bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.animateCamera(cameraUpdate);
  }
}
}
