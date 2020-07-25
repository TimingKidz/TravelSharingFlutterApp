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

class CreateRoute_Join extends StatefulWidget {
//  final LocationData gps;
//  CreateRoute({this.gps}) ;

  @override
  _CreateRoutestate_Join createState() => _CreateRoutestate_Join();
}

class _CreateRoutestate_Join extends State<CreateRoute_Join> {
  static final String api_key = "AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q";
  final places = new p.GoogleMapsPlaces(apiKey: api_key);
  final l.Distance distance = new l.Distance();
  final TextEditingController src_Textcontroller = new TextEditingController();
  final TextEditingController dst_Textcontroller = new TextEditingController();
  p.GoogleMapsPlaces _places = p.GoogleMapsPlaces(apiKey: api_key);
  GoogleMapController _mapController;
  Set<Marker> Markers = Set();
  Location location = Location();
  bool isSet_Marker = false;
  LatLng current_Location;
  LatLng Marker_Location;
  bool is_src = true;
  static int Role = 1;



  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<String,LatLng> Map_Latlng = <String,LatLng>{};
  Map<String,String> Map_Placename = <String,String>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location.onLocationChanged.listen((LocationData currentLocations) {
      if (!isSet_Marker) {
        current_Location =
            LatLng(currentLocations.latitude, currentLocations.longitude);
        _mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: current_Location, zoom: 18,)));
        _createMarkers(current_Location);
        isSet_Marker = true;
      }
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
              target: LatLng(16.294922, 100.928026),
              zoom: 5,
            ),
            markers: Set<Marker>.of(_markers.values),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onCameraIdle: OnMove_End,
            onCameraMove: center,
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
                    child: TextFormField(
                      controller: src_Textcontroller,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.text,
                      onTap: (){
                        is_src = true;
                        _Searchbar();
                      },
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Source..."),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,
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
                    child: TextFormField(
                      controller: dst_Textcontroller,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.text,
                      onTap: (){
                        is_src = false;
                        _Searchbar();
                      },
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Destination...."),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton.extended(
                  label: Text('Finish'),
                  onPressed: _Fin,
                  heroTag: null,
                ),
            ]),
          ),

        ],
      ),
    );
  }

  _Fin() {
    List<LatLng> routes = [Map_Latlng["src"],Map_Latlng["dst"]];
    String Placename_src = Map_Placename["src"];
    String Placename_dst = Map_Placename["dst"];
    Set<Marker> Makers = Set();
    Markers.add(
        Marker(
          markerId: MarkerId("Src"),
          position: routes.first,
          infoWindow: InfoWindow(title: "Roca 123"),
        )
    );
    Markers.add(
        Marker(
          markerId: MarkerId("Dst"),
          position: routes.last,
          infoWindow: InfoWindow(title: "Roca 123"),
        )
    );

    var left = min(routes.first.latitude, routes.last.latitude);
    var right = max(routes.first.latitude, routes.last.latitude);
    var top = max(routes.first.longitude, routes.last.longitude);
    var bottom = min(routes.first.longitude, routes.last.longitude);



    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => Test(routes: routes, bounds:bounds,Markers :Markers,lines :null,src:Placename_src,dst: Placename_dst ,Role: Role)));
  print("Latlng src: ${Map_Latlng["src"]} Dst: ${Map_Latlng["dst"]} Place src: ${Map_Placename["src"]} dst : ${Map_Placename["dst"]}");

  }

  OnMove_End() async {
    print("end");
    p.PlacesSearchResult tmp = null;
    p.PlacesSearchResponse response = await places.searchNearbyWithRadius(new p.Location(Marker_Location.latitude,Marker_Location.longitude), 10);
    int min = 10;
    response.results.forEach((element) {
      l.LatLng to = new l.LatLng(element.geometry.location.lat,element.geometry.location.lng);
      l.LatLng ori = new l.LatLng(Marker_Location.latitude, Marker_Location.longitude);
      if(distance(to,ori) <= min){
        tmp = element;
        print("${element.name} : ${distance(to,ori)} : $to");
      }
    });
    if(tmp!=null) {
      Marker_Location =
          LatLng(tmp.geometry.location.lat, tmp.geometry.location.lng);
      _createMarkers(Marker_Location);
    }
    Src_OR_Dst(Marker_Location, tmp != null ? tmp.name : "");
  }

  center(CameraPosition pos) {
    Marker_Location = pos.target;
    _createMarkers(Marker_Location);
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

    p.PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
        P.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    Src_OR_Dst(LatLng(lat,lng), detail.result.name);
  }

  Src_OR_Dst(LatLng point,String name){
    if(is_src){
      Map_Latlng["src"] = point ;
      Map_Placename["src"] = name;
      src_Textcontroller.text = name;
    }else{
      Map_Latlng["dst"] = point ;
      Map_Placename["dst"] = name;
      dst_Textcontroller.text = name;
    }
    setState(() {

    });
  }

  _createMarkers(LatLng x) {
    MarkerId markerId = MarkerId("src");
    Marker marker = Marker(
      markerId: markerId,
      position: x,
      draggable: false,
    );
    setState(() {
      _markers[markerId] = marker;
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
//    current_Location = LatLng(currentLocation.latitude,currentLocation.longitude);
  }
}