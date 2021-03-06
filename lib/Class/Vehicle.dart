import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;

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

  Widget getTypeIcon(String type,double scale){
    switch(type){
      case "Car": {
        return  Image.asset("assets/icons/Cars.png", scale: scale-9, filterQuality: FilterQuality.medium);
      }
      break;
      case "Motorcycle": {
        return  Image.asset("assets/icons/Motocycle.png", scale: scale, filterQuality: FilterQuality.medium);
      }
      break;
      case "Person": {
        return Icon(Icons.person, size: 32.0);
      }
      break;
      case "People": {
        return Icon(Icons.people, size: 32.0);
      }
      break;
      default: {
        return null;
      }
      break;
    }
  }
}