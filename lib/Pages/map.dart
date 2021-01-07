import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as l;
import 'package:location/location.dart' ;
import "package:google_maps_webservice/places.dart" as p;
import 'package:travel_sharing/Class/NearbyPlace.dart';
import 'package:travel_sharing/Pages/LocationSearchBar.dart';
import 'package:travel_sharing/Pages/InfoFill.dart';
import 'package:travel_sharing/localization.dart';
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
  bool isSelected = false;
  Set<Polyline> lines = Set();
  Set<Polyline> finalLines = Set();
  int pointNo = 0;
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

  void selectedMethod(dynamic result){
    if(result != null) {
      if ( result is Map<String,dynamic>) _Searchbar(result);
      if ( result is bool ) {
        if (result) {
          isChooseOnMap = true;
        }else {
          Src_OR_Dst(current_Location, "Current Location");
          _mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: current_Location, zoom: 18)));
        }
      }
    }
    setState(() { });
    print(isChooseOnMap);
  }

//------------------------------------ UI---------------------------------------
  @override
  Widget build(BuildContext context) {
    if(current_Location == null){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target:current_Location,
              zoom: 15,
            ),
            markers:  Set<Marker>.of(_markers.values),
            polylines: isSelected ? lines : Set(),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
//              onCameraIdle: OnMove_End ,
            onCameraMove: center ,
          ),
          if(isChooseOnMap)
            Positioned.fill(
              child: Center(
                child: Icon(Icons.place, size: 32.0, color: Colors.red),
              ),
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
                          if (!isSelected)
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
                                             selectedMethod(result);
                                            });
                                          },
                                          textInputAction: TextInputAction.go,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 15),
                                              hintText: AppLocalizations.instance.text("SrcPoint")
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
                                             selectedMethod(result);
                                            });
                                          },
                                          textInputAction: TextInputAction.go,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 15),
                                              hintText: AppLocalizations.instance.text("DstPoint")
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.0),
                              ],
                            ),
                          ),
                          if(isSelected)
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ClipOval(
                                    child: Material(
                                      child: InkWell(
                                        child: SizedBox(width: 64, height: 64, child: isChooseOnMap ? Icon(Icons.close):Icon(Icons.add)),
                                        onTap: () {
                                          isChooseOnMap = !isChooseOnMap;
                                          setState(() { });
                                          },
                                      ),
                                    ),
                                  ),
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
                  if( isChooseOnMap )
                    FloatingActionButton.extended(
                      label: Text('Choose'),
                      onPressed: () async {
                        if(isSelected){
                          createRoute(Marker_Location);
                          _drawLine();
                          isChooseOnMap = false;
                        }else{
                          await OnMove_End();
                          isChooseOnMap = false;
                          setState(() { });
                        }
                      },
                      heroTag: null,
                    ),
                  if( Map_Latlng["src"] != null && Map_Latlng["dst"] != null && !isChooseOnMap && !isSelected)
                    FloatingActionButton.extended(
                      label: Text('Preview'),
                      onPressed: (){
                        isChooseOnMap = false;
                        _drawLine();
                      },
                      heroTag: null,
                    ),
                  if( isSelected && !isChooseOnMap )
                    FloatingActionButton.extended(
                      label: Text('finish'),
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

  _drawLine(){
    Polyline line = Polyline(
      patterns: [PatternItem.dot],
      points: List<LatLng>.of(Map_Latlng.values),
      geodesic: true,
      polylineId: PolylineId("mejor ruta"),
      color: Colors.blue,
      width: 4,
    );
    lines.clear();
    lines.add(line);
    isSelected = true;
    setState(() { });
  }
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
    Marker_Location = current_Location;
//    _createMarkers(current_Location);
    setState(() { });
    isSet_Marker = true;
  }

  _Fin() async {
    isChooseOnMap = false;
    List<LatLng> routes = [Map_Latlng["src"],Map_Latlng["dst"]];
    String Placename_src = Map_Placename["src"];
    String Placename_dst = Map_Placename["dst"];

    var origin = PointLatLng(Map_Latlng["src"].latitude, Map_Latlng["src"].longitude);
    var destination = PointLatLng(Map_Latlng["dst"].latitude, Map_Latlng["dst"].longitude);

    List<LatLng> tmp = List();
    PolylinePoints polylinePoints = PolylinePoints();

    List<PolylineWayPoint> waypoint = List();
    for (int j = 0 ; j<pointNo ; j++){
      waypoint.add(PolylineWayPoint(location:"${Map_Latlng[j.toString()].latitude.toString()},${Map_Latlng[j.toString()].longitude.toString()}"));
    }

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(api_key, origin,destination,wayPoints: waypoint);
    result.points.forEach((step) {
      tmp.add(LatLng(step.latitude, step.longitude));
    });
    finalLines.clear();
    finalLines.add(Polyline(
      patterns: [PatternItem.dot],
      points: tmp,
      geodesic: true,
      polylineId: PolylineId("mejor ruta"),
      color: Colors.blue,
      width: 4,
    ));



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
        builder: (context) => InfoFill(routes: tmp, bounds:bounds,Markers : Set<Marker>.of(_markers.values),lines :finalLines,src:Placename_src,dst: Placename_dst ,Role: Role))).then((value) => setState(() { }));
  }

  OnMove_End() async {
    print(i++);
    if (isChooseOnMap){
      if( isSet_Marker && Marker_Location != null){
        NearbyPlace place = null;
        String name = "";
        double min = double.maxFinite;
        List<NearbyPlace> tmp = await NearbyPlace().getNearbyPlace(Marker_Location.latitude, Marker_Location.longitude);
        tmp.forEach((element) {
          l.LatLng NearPlace_Loc = new l.LatLng(element.location.latitude,element.location.longitude);
          l.LatLng Marker_Loc = new l.LatLng(Marker_Location.latitude, Marker_Location.longitude);
          double dis = distance(NearPlace_Loc,Marker_Loc);
          if(dis <= min){
            min = dis;
            place = min > 30 ? null:element;
            name = element.name;
          }
        });
        if(place!=null) {
          Marker_Location = place.location;
        }
        Src_OR_Dst(Marker_Location,name);
      }
    }

  }

  center(CameraPosition pos) {
    Marker_Location = pos.target;
//    if ( isChooseOnMap ){ _createMarkers(Marker_Location); }
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

  createRoute(LatLng x){
    Map_Latlng[pointNo.toString()] = x ;
    MarkerId markerId = MarkerId(pointNo.toString());
    Marker marker =  Marker(
        markerId: markerId,
        position:  x,
        infoWindow: InfoWindow(title: pointNo.toString())
    );
    pointNo ++;
//    _markers[markerId] = marker;
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
//  _createMarkers(LatLng x) {
//    MarkerId markerId = MarkerId("src");
//    Marker marker = Marker(
//      markerId: markerId,
//      position: x,
//      draggable: false,
//    );
//    _centerMarkers[markerId] = marker;
//  }

  // set Map controller
  void _onMapCreated(GoogleMapController controller){
    _mapController = controller;
  }
}