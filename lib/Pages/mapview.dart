import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as l;
import 'package:location/location.dart' ;
import "package:google_maps_webservice/places.dart" as p;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/UI/NotificationBarSettings.dart';
import 'package:travel_sharing/main.dart';

class MapView extends StatefulWidget {
  final Routes paiDuay;
  final Routes chuan;
  const MapView({Key key, this.paiDuay, this.chuan}) : super(key: key);
  @override
  _MapView createState() => _MapView();
}

class _MapView extends State<MapView> {
  final places = new p.GoogleMapsPlaces(apiKey: api_key);
  final l.Distance distance = new l.Distance();
  GoogleMapController _mapController;
  List<LatLng> routes = List();
  Set<Polyline> lines = Set();
  List<LatLng> temp = List();
  Map<LatLng,String> Name_list = Map();
  LatLng fromPoint;
  LatLng toPoint;
  Set<Marker> Markers = Set();
  LocationData currentLocation ;
  Location location = Location();
  bool isSet_Marker = false;
  LatLng current_Location;
  LatLngBounds bounds;
  p.PlacesSearchResult tmp;
  LatLng src;
  LatLng dst;
//  static int Role = 0;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    notificationBarIconLight();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  // find direction to destination
  findDirections(bool isFind_Direction ) async {
    // create line of routes on map
    var line = Polyline(
      points: widget.chuan.routes,
      geodesic: true,
      polylineId: PolylineId("mejor ruta"),
      color: Theme.of(context).accentColor.withOpacity(0.5),
      width: 4,
    );
    setState(() {
      lines.clear();
      lines.add(line);
    });
  }

  @override
  Widget build(BuildContext context) {
    notificationBarIconDark();
    return Scaffold(
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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          )
        ],
      ),
    );
  }

  _createMarkers() async {
    Markers.clear();
    Markers.add(
      Marker(
        markerId: MarkerId("src"),
        position: widget.paiDuay.routes.first,
        infoWindow: InfoWindow(title: widget.paiDuay.src),
        icon: widget.paiDuay.role == "0" ?  await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/icons/car.png') :
          await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/icons/person.png')
      ),
    );
    Markers.add(
      Marker(
        markerId: MarkerId("dst"),
        position: widget.paiDuay.routes.last,
        infoWindow: InfoWindow(title: widget.paiDuay.dst),
          icon: widget.paiDuay.role == "0" ?  await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/icons/dst_chuan.png') :
          await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/icons/dst_paiduay.png')

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
      if(widget.chuan.role == "0"){
        await findDirections(isFind_Direction);
      }

      Routes temp = widget.paiDuay;
      var left = min(temp.routes.first.latitude, temp.routes.last.latitude);
      var right = max(temp.routes.first.latitude, temp.routes.last.latitude);
      var top = max(temp.routes.first.longitude, temp.routes.last.longitude);
      var bottom = min(temp.routes.first.longitude, temp.routes.last.longitude);

      if(widget.chuan.role == "0"){
        lines.first.points.forEach((point) {
          left = min(left, point.latitude);
          right = max(right, point.latitude);
          top = max(top, point.longitude);
          bottom = min(bottom, point.longitude);
        });
      }

      bounds = LatLngBounds(
        southwest: LatLng(left, bottom),
        northeast: LatLng(right, top),
      );
      var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
      _mapController.moveCamera(cameraUpdate);

  }
}
