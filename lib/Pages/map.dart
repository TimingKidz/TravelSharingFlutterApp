import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as l;
import 'package:location/location.dart' ;
import "package:google_maps_webservice/places.dart" as p;
import 'package:travel_sharing/Pages/LocationSearchBar.dart';
import 'package:travel_sharing/Pages/InfoFill.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/main.dart';


class CreateRoute extends StatefulWidget {
  const CreateRoute({Key key}) : super(key: key);
  @override
  _CreateRoutestate createState() => _CreateRoutestate();
}

class _CreateRoutestate extends State<CreateRoute> {
  static int Role = 0;
//  final places = new p.GoogleMapsPlaces(apiKey: api_key);
  final l.Distance distance = new l.Distance();
  final TextEditingController src_Textcontroller = new TextEditingController();
  final TextEditingController dst_Textcontroller = new TextEditingController();
  p.GoogleMapsPlaces _places = p.GoogleMapsPlaces(apiKey: api_key);
  GoogleMapController _mapController;
  bool isSet_Marker = false;
  LatLng current_Location;
  LatLng Marker_Location;
  bool is_src = true;
  Map<MarkerId, Marker> _centerMarkers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<String,LatLng> Map_Latlng = <String,LatLng>{};
  Map<String,String> Map_Placename = <String,String>{};
  bool isChooseOnMap = false;
  int i = 0;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
//   _mapController.dispose();
    src_Textcontroller.dispose();
    dst_Textcontroller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    getLocation();
    _pageConfig();
  }

//------------------------------------ UI---------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          if(current_Location != null)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target:current_Location,
                zoom: 15,
              ),
              markers: isChooseOnMap ?
              Set<Marker>.of(_centerMarkers.values)
                  :  Set<Marker>.of(_markers.values),
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onCameraIdle: OnMove_End ,
              onCameraMove: center ,
            ),
          Card(
            elevation: 2.0,
            margin: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)
                )
            ),
            child: Container(
                padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 14.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0)
                    )
                ),
                // color: Theme.of(context).primaryColor,
                child: Wrap(
                  children: <Widget>[
                    SafeArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.location_searching, color: Colors.white),
                                    Expanded(
                                      child: Card(
                                        margin: EdgeInsets.only(left: 8.0, right: 8.0),
                                        elevation: 2.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0)
                                        ),
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: src_Textcontroller,
                                          cursorColor: Colors.black,
                                          keyboardType: TextInputType.text,
                                          onTap: (){
                                            is_src = true;
                                            isChooseOnMap = false;
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => LocationSearch(currentLocation: current_Location, hintText: "จุดเริ่มต้น ...")
                                                )
                                            ).then((result) {
                                              if(result != null) {
                                                if ( result is Map<String,dynamic>) _Searchbar(result);
                                                if ( result is bool ) {
                                                  print("DDDDDDDDDDDDDDDDDDDD");
                                                  if (result) { isChooseOnMap = true; }
                                                  else {
                                                    Src_OR_Dst(current_Location, "Current Location");
                                                    _mapController.animateCamera(CameraUpdate.newCameraPosition(
                                                        CameraPosition(target: current_Location, zoom: 18)));
                                                  }
                                                  _createMarkers(Marker_Location);
                                                }
                                              }
                                              print(isChooseOnMap);
                                              _createMarkers(Marker_Location);
                                              setState(() { });
                                            });
                                          },
                                          textInputAction: TextInputAction.go,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 15),
                                              hintText: "จุดเริ่มต้น ..."
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.location_on, color: Colors.white),
                                    Expanded(
                                      child: Card(
                                        margin: EdgeInsets.only(left: 8.0, right: 8.0),
                                        elevation: 2.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0)
                                        ),
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: dst_Textcontroller,
                                          cursorColor: Colors.black,
                                          keyboardType: TextInputType.text,
                                          onTap: (){
                                            is_src = false;
                                            isChooseOnMap = false;
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => LocationSearch(currentLocation: current_Location, hintText: "จุดปลายทาง ...")
                                                )
                                            ).then((result) {
                                              if(result != null) {
                                                if ( result is Map<String,dynamic>) _Searchbar(result);
                                                if ( result is bool ) {
                                                  print("DDDDDDDDDDDDDDDDDDDD");
                                                  if (result) {
                                                    isChooseOnMap = true;
//                                                    setState(() { });
                                                  }
                                                  _createMarkers(Marker_Location);
                                                }
                                              }
                                              setState(() { });
                                              print(isChooseOnMap);
                                            });
                                          },
                                          textInputAction: TextInputAction.go,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 15),
                                              hintText: "จุดปลายทาง ..."
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.0),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.bottomCenter,
            child:
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if( Map_Latlng["src"] != null && Map_Latlng["dst"] != null)
                    FloatingActionButton.extended(
                      label: Text('Preview'),
                      onPressed: _Fin,
                      heroTag: null,
                    ),
                ]),
          ),
        ],
      ),
    );
  }
  // ----------------------------------------------------------------------------

  _pageConfig(){
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onTripEnd');
    socket.off('onKick');
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

  getLocation() async{
    LocationData currentLoc = await Location().getLocation();
    current_Location =
        LatLng(currentLoc.latitude, currentLoc.longitude);
    print(current_Location.longitude);
//    _mapController.animateCamera( CameraUpdate.newCameraPosition(CameraPosition(target: current_Location, zoom: 15,)));
    _createMarkers(current_Location);
    isSet_Marker = true;
  }

  _Fin() {
    isChooseOnMap = false;
    List<LatLng> routes = [Map_Latlng["src"],Map_Latlng["dst"]];
    String Placename_src = Map_Placename["src"];
    String Placename_dst = Map_Placename["dst"];

    // find camera bound for 4 angle
    var left = min(routes.first.latitude, routes.last.latitude);
    var right = max(routes.first.latitude, routes.last.latitude);
    var top = max(routes.first.longitude, routes.last.longitude);
    var bottom = min(routes.first.longitude, routes.last.longitude);
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    // go to fill all information in next page before save to DB
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => InfoFill(routes: routes, bounds:bounds,Markers : Set<Marker>.of(_markers.values),lines :null,src:Placename_src,dst: Placename_dst ,Role: Role))).then((value) => setState(() { }));
  }

  OnMove_End() async {
    print(i++);
    if (isChooseOnMap){
      if( isSet_Marker && Marker_Location != null){

        p.PlacesSearchResult tmp = null;
        int min = 10; // max distance (metre)
        // search for nearby place in 10 metre
        p.PlacesSearchResponse response = await _places.searchNearbyWithRadius(new p.Location(Marker_Location.latitude,Marker_Location.longitude), 10);
        print(response.results.first.name);
        response.results.forEach((element) {
          l.LatLng NearPlace_Loc = new l.LatLng(element.geometry.location.lat,element.geometry.location.lng);
          l.LatLng Marker_Loc = new l.LatLng(Marker_Location.latitude, Marker_Location.longitude);
          if(distance(NearPlace_Loc,Marker_Loc) <= min){ tmp = element; }
        });
        if(tmp!=null) { // set marker snap to nearby place
          Marker_Location = LatLng(tmp.geometry.location.lat, tmp.geometry.location.lng);
          _createMarkers(Marker_Location);
        }
        // check state function
        Src_OR_Dst(Marker_Location, tmp != null ? tmp.name : "");
      }
    }

  }

  center(CameraPosition pos) {
    Marker_Location = pos.target;
    if ( isChooseOnMap ){ _createMarkers(Marker_Location); }
  }

  Future<void> _Searchbar(Map<String, dynamic> result) async {
    p.PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(result['place_id']);
    debugPrint(result['place_id']);

    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    Src_OR_Dst(LatLng(lat,lng), detail.result.name);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat,lng), zoom: 18)));
  }

  Src_OR_Dst(LatLng point,String name){
    if(is_src){ // select source state
      Map_Latlng["src"] = point ;
      Map_Placename["src"] = name;
      src_Textcontroller.text = name;
      MarkerId markerId = MarkerId("src");
      Marker marker =  Marker(
          markerId: markerId,
          position:  Map_Latlng["src"],
          infoWindow: InfoWindow(title: Map_Placename["src"])
      );
      _markers[markerId] = marker;
    }else{ // select destination state
      Map_Latlng["dst"] = point ;
      Map_Placename["dst"] = name;
      dst_Textcontroller.text = name;
      MarkerId markerId = MarkerId("dst");
      Marker marker =  Marker(
          markerId: markerId,
          position:  Map_Latlng["dst"],
          infoWindow: InfoWindow(title: Map_Placename["dst"])
      );
      _markers[markerId] = marker;
    }
    setState(() {
    });
  }

// function create marker at x position
  _createMarkers(LatLng x) {
    MarkerId markerId = MarkerId("src");
    Marker marker = Marker(
      markerId: markerId,
      position: x,
      draggable: false,
    );
    setState(() {
      _centerMarkers[markerId] = marker;
    });
  }

  // set Map controller
  void _onMapCreated(GoogleMapController controller){
    _mapController = controller;
  }
}