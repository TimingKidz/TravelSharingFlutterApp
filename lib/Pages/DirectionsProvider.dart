import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_webservice/directions.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';




class DirectionProvider extends ChangeNotifier {
  GoogleMapsDirections directionsApi =
  GoogleMapsDirections(apiKey: "AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q");



  List<maps.LatLng> _route = List();
  List<maps.LatLng> _temp = List();
  Set<maps.Polyline> _Line = Set();
  List<maps.LatLng> get Routes => _route;
  Set<maps.Polyline> get Lines => _Line;
  List<maps.LatLng> get Temp => _temp;

  findDirections(maps.LatLng from, maps.LatLng to,List<maps.LatLng> routes,List<maps.LatLng> temp,int x) async {



    var origin = PointLatLng(from.latitude, from.longitude);
    var destination = PointLatLng(to.latitude, to.longitude);
    print(" $from / $to");
    if(x == 0){
      Set<maps.Polyline> newRoute = Set();
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates("AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q", origin,destination);
//      List<maps.LatLng> points = [];
      PointLatLng Ll = result.points.first;
      temp.add(maps.LatLng(Ll.latitude,Ll.longitude));

      result.points.forEach((step) {
        routes.add(maps.LatLng(step.latitude, step.longitude));
      });
      _route = routes; _temp = temp;
    }
      print("route :");
      print(routes);
      print("temp :");
      print(temp);
      var line = maps.Polyline(
        points: routes,
        geodesic: true,
        polylineId: maps.PolylineId("mejor ruta"),
        color: Colors.blue,
        width: 4,
      );
      _Line.add(line);
      _route = routes;
      notifyListeners();
    }
  }
