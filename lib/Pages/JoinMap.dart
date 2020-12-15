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

class CreateRoute_Join extends StatefulWidget {
  const CreateRoute_Join({Key key, }) : super(key: key);
  @override
  _CreateRoutestate_Join createState() => _CreateRoutestate_Join();
}

class _CreateRoutestate_Join extends State<CreateRoute_Join> {
  static int Role = 1;
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
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<String,LatLng> Map_Latlng = <String,LatLng>{};
  Map<String,String> Map_Placename = <String,String>{};

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    // callback currentLocation for first time
//    location.onLocationChanged.listen((LocationData currentLocations) {
//      if (!isSet_Marker) {
//        current_Location = LatLng(currentLocations.latitude, currentLocations.longitude);
//        // animate camera to currentLocation
//        _mapController.animateCamera(CameraUpdate.newCameraPosition(
//            CameraPosition(target: current_Location, zoom: 18,)));
//        _createMarkers(current_Location);
//        isSet_Marker = true;
//      }
//    });
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
//------------------------------------ UI---------------------------------------
  @override
  Widget build(BuildContext context) {
    if (current_Location != null){
      return Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target:current_Location,
                zoom: 15,
              ),
              markers: Set<Marker>.of(_markers.values),
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onCameraIdle: OnMove_End,
              onCameraMove: center,
            ),
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(0.0),
//            shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.only(
//                    bottomLeft: Radius.circular(30.0),
//                    bottomRight: Radius.circular(30.0)
//                )
//            ),
              child: Container(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 16.0),
//                decoration: BoxDecoration(
//                    color: Theme.of(context).colorScheme.orange,
//                    borderRadius: BorderRadius.only(
//                        bottomLeft: Radius.circular(30.0),
//                        bottomRight: Radius.circular(30.0)
//                    )
//                ),
                  color: Theme.of(context).colorScheme.orange,
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
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) => LocationSearch(currentLocation: current_Location, hintText: "จุดเริ่มต้น ...")
                                                  )
                                              ).then((result) {
                                                if(result != null) _Searchbar(result);
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
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) => LocationSearch(currentLocation: current_Location, hintText: "จุดปลายทาง ...")
                                                  )
                                              ).then((result) {
                                                if(result != null) _Searchbar(result);
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
    }else{
      return Scaffold(
        body: Stack(
          children: <Widget>[
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(0.0),
//            shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.only(
//                    bottomLeft: Radius.circular(30.0),
//                    bottomRight: Radius.circular(30.0)
//                )
//            ),
              child: Container(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 16.0),
//                decoration: BoxDecoration(
//                    color: Theme.of(context).colorScheme.orange,
//                    borderRadius: BorderRadius.only(
//                        bottomLeft: Radius.circular(30.0),
//                        bottomRight: Radius.circular(30.0)
//                    )
//                ),
                  color: Theme.of(context).colorScheme.orange,
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
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) => LocationSearch(currentLocation: current_Location, hintText: "จุดเริ่มต้น ...")
                                                  )
                                              ).then((result) {
                                                if(result != null) _Searchbar(result);
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
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) => LocationSearch(currentLocation: current_Location, hintText: "จุดปลายทาง ...")
                                                  )
                                              ).then((result) {
                                                if(result != null) _Searchbar(result);
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

  }
 // ----------------------------------------------------------------------------
  _Fin() {
    List<LatLng> routes = [Map_Latlng["src"],Map_Latlng["dst"]];
    String Placename_src = Map_Placename["src"];
    String Placename_dst = Map_Placename["dst"];
    Set<Marker> Makers = Set();
    // set marker for source
    Markers.add(
        Marker(
          markerId: MarkerId("Src"),
          position: routes.first,
          infoWindow: InfoWindow(title: Placename_src)
        )
    );
    // set marker for destination
    Markers.add(
        Marker(
          markerId: MarkerId("Dst"),
          position: routes.last,
          infoWindow: InfoWindow(title: Placename_dst)
        )
    );

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
        builder: (context) => InfoFill(routes: routes, bounds:bounds,Markers :Markers,lines :null,src:Placename_src,dst: Placename_dst ,Role: Role)));

  }

  OnMove_End() async {
    if( isSet_Marker && Marker_Location != null){
      p.PlacesSearchResult tmp = null;
      int min = 10; // max distance (metre)
      // search for nearby place in 10 metre
      p.PlacesSearchResponse response = await places.searchNearbyWithRadius(new p.Location(Marker_Location.latitude,Marker_Location.longitude), 10);
      response.results.forEach((element) {
        l.LatLng NearPlace_Loc = new l.LatLng(element.geometry.location.lat,element.geometry.location.lng);
        l.LatLng Marker_Loc = new l.LatLng(Marker_Location.latitude, Marker_Location.longitude);
        if(distance(NearPlace_Loc,Marker_Loc) <= min){
          tmp = element;
        }
      });
      if(tmp!=null) {
        // set marker snap to nearby place
        Marker_Location = LatLng(tmp.geometry.location.lat, tmp.geometry.location.lng);
        _createMarkers(Marker_Location);
      }
      // check state function
      Src_OR_Dst(Marker_Location, tmp != null ? tmp.name : "");
    }
  }

  center(CameraPosition pos) {
    Marker_Location = pos.target;
    _createMarkers(Marker_Location);
  }

  Future<void> _Searchbar(Map<String, dynamic> result) async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
//    p.Prediction P = await PlacesAutocomplete.show(
//      context: context,
//      apiKey: api_key,
//      mode: Mode.fullscreen,
//      language: "th",
//      components: [p.Component(p.Component.country, "th")],
//    );
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
    }else{ // select destination state
      Map_Latlng["dst"] = point ;
      Map_Placename["dst"] = name;
      dst_Textcontroller.text = name;
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
      _markers[markerId] = marker;
    });
  }

  // set Map controller
  void _onMapCreated(GoogleMapController controller){
    _mapController = controller;
  }
}