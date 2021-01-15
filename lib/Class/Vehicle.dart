import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';

import '../main.dart';


class Vehicle {
  String vid;
  String brand;
  String license;
  String model;
  String color;
  String type;
  bool isDefault;


  Vehicle({this.vid,this.brand,this.license,this.model,this.color,this.type,this.isDefault});

 Vehicle.fromJson(Map<String, dynamic> json) {
   vid = json['_id'];
   type = json['type'];
   license = json['license'];
   brand = json['brand'];
   model = json['model'];
   color = json['color'];
   isDefault = json['isDefault'];
 }

 Map<String, dynamic> toJson() {
   final Map<String, dynamic> data = new Map<String, dynamic>();
   data['id'] = currentUser.uid;
   data['_id'] = this.vid;
   data['type'] = this.type;
   data['license'] = this.license;
   data['brand']= this.brand;
   data['model']= this.model;
   data['color']= this.color;
   data['isDefault'] = this.isDefault;
   return data;
 }

 Future<bool> addVehicle() async {
   try{
     Http.Response response = await httpClass.reqHttp("/api/vehicle_manage/addVehicle",this.toJson());
     if(response.statusCode == 400){
       return Future.value(false);
     }else{
       print("Add vehicle successful : ${response.body}");
       return Future.value(true);
     }
   }catch(err){
     throw("can't connect" + err);
   }
 }

 Future<bool> editVehicle() async {
   try{
     Http.Response response = await httpClass.reqHttp("/api/vehicle_manage/editVehicle",this.toJson());
     if(response.statusCode == 400){
       return Future.value(false);
     }else{
       print("Edit vehicle : ${response.body}");
       return Future.value(true);
     }
   }catch (err){
     throw("can't connect" + err);
   }
 }

 Future<bool> deleteVehicle() async {
   try{
     Http.Response response = await httpClass.reqHttp("/api/vehicle_manage/deleteVehicle",{"uid": currentUser.uid, "vid": this.vid});
     if(response.statusCode == 400){
       return Future.value(false);
     }else{
       print("Delete vehicle : ${response.body}");
       return Future.value(true);
     }
   }catch(err){
     throw("can't connect" + err);
   }
 }

  Vehicle defaultVehicle(){
    for(Vehicle each in currentUser.vehicle){
      if(each.isDefault){
        return each;
      }
    }
    return null;
  }

  IconData getTypeIcon(String type){
    switch(type){
      case "Car": {
        return Icons.drive_eta;
      }
      break;
      case "Motorcycle": {
        return Icons.motorcycle;
      }
      break;
      case "Person": {
        return Icons.person;
      }
      break;
      case "People": {
        return Icons.people;
      }
      break;
      default: {
        return null;
      }
      break;
    }
  }
}