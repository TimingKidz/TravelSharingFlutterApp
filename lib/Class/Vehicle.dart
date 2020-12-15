import 'dart:convert';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';

class Vehicle {
  String brand;
  String license;
  String model;
  String color;
  String type;

  Vehicle({this.brand,this.license,this.model,this.color,this.type});

//  Vehicle.fromJson(Map<String, dynamic> json) {
//    name = json['name'];
//    email = json['email'];
//    id = json['id'];
//  }
//
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = new Map<String, dynamic>();
//    data['name'] = this.name;
//    data['email'] = this.email;
//    data['id']= this.id;
//    return data;
//  }



}