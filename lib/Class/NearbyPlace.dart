import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/main.dart';
import 'package:http/http.dart' as Http;

class NearbyPlace{
  LatLng location;
  String name;

  NearbyPlace({this.location, this.name});

  NearbyPlace.fromJson(Map<String, dynamic> json) {
    location = new LatLng(json['geometry']["location"]['lat'],json['geometry']["location"]['lng']);
    name = json['name'];
  }

  Future<List<NearbyPlace>> getNearbyPlace(double lat,double long) async{
//    try{
      String url ="https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${long}&radius=30&key=${api_key}";
      Http.Response response = await Http.get(url);
      if(response.statusCode == 200 ){
        print(jsonDecode(response.body));
        List<NearbyPlace> tmp = List();
        List<dynamic> data = jsonDecode(response.body)['results'];
        data.forEach((x){
          tmp.add(NearbyPlace.fromJson(x));
          print(x['name']);
        });
        return Future.value(tmp);
      }else {
        return Future.value(null);
      }
//    }catch(err){
//      print(err);
//    }

  }

}