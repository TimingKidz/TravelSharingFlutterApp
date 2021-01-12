import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Class/Vehicle.dart';

import '../main.dart';



class Routes {
  String uid;
  String id;
  List<LatLng> routes;
  String src;
  String dst;
  String amount;
  String date;
  bool isMatch;
  List<String> match;
  String role;
  bool status;
  int left;
  String range;
  String cost;
  Vehicle vehicle;
  List<dynamic> tag;


  Routes({this.uid,this.id,this.routes, this.src,this.dst,this.amount,this.date,this.isMatch,this.match,this.role,this.vehicle,this.tag, this.cost, this.range});

  Routes.fromJson(Map<String, dynamic> json) {
    uid = json['_id'];
    if(json['routes'] != null){
      List<LatLng> temp = List();
      json['routes'].forEach((x){
        temp.add(LatLng(x[0],x[1]));
      });
    routes = temp;
    }
    if(json['match'] != null){
      List<String> temp = List();
      json['match'].forEach((x){
        if(x is String){
          temp.add(x);
        }else{
          temp.add(x['_id']);
        }
      });
      match = temp;
    }else{
      match = List();
    }
    src = json['src'];
    dst = json['dst'];
    amount = json['amount'];
    date = json['date'];
    if ( json['id'] is String){
      id = json['id'];
    }else{
      id = json['id']['_id'];
    }
    isMatch = json['isMatch'];
    role = json['role'];
    status = json['status'];
    print(json["vehicle"]['id']);
    vehicle = json["vehicle"]["id"] is Map<String,dynamic> ? Vehicle.fromJson(json["vehicle"]['id']) : Vehicle() ;
    tag = json['tag'];
    left = json['left'];
    cost = json['cost'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['src'] = this.src;
    data['dst'] = this.dst;
    data['routes'] = this.routes;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['id'] = this.id;
    data['match'] = this.match;
    data['role'] = this.role;
    data['vehicle'] = this.vehicle == null ? null : this.vehicle.toJson();
    data['tag'] = this.tag;
    data['range'] = int.parse(this.range);
    data['cost'] = int.parse(this.cost);
    return data;
  }

  // save routes information to DB
  Future<bool> SaveRoute_toDB(User user) async{
    try{
        Map<String, dynamic> temp = user.toJson();
        temp['detail'] = this.toJson();
        Http.Response response = await httpClass.reqHttp("/api/routes/SaveRoutes",temp);
        print(response.body);
        if( response.statusCode == 400 ){
          return Future.value(false);
        }else{
          return Future.value(true);
        }
    }catch(error){
      print(error);
    }
  }

  // send request to selected routes ( data is current user routes , data0 is who current user select routes )
  Future<bool> Request(Match_Info data , Travel_Info data0)async {
    // try{
      Map<String,dynamic> temp = {
        'detail' : data0.routes.toJson(),
        'to_id' : data.routes.uid,
        'toid' : data.user.uid,
        'form_id' : data0.uid,
        'formid' : data0.id };
      Http.Response response = await httpClass.reqHttp("/api/routes/request",temp);
      if(response.statusCode == 400 ){
        return Future.value(false);
      }else{
        print("Req Succesful : ${response.body}");
        return Future.value(true);
      }
    // }catch(error){
    //   throw("can't connect");
    // }
  }

  Future<List<Travel_Info>> getHistory(String userID) async {
    // try {
    Http.Response response = await httpClass.reqHttp("/api/routes/getHistory", {'id': userID});
    if (response.statusCode == 400) {
      return Future.value(null);
    } else {
      if (response.statusCode == 404) {
        return Future.value(null);
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<Travel_Info> historyList = List();
        print(data);
        data['History'].forEach((x) {
          Routes rtmp = Routes.fromJson(x);
          Travel_Info tmp = new Travel_Info(routes: rtmp, id: rtmp.id, uid: rtmp.uid);
          historyList.add(tmp);
        });
        return Future.value(historyList);
      }
    }
    // }catch(err){
    //   throw("can't connect" + err);
    // }
  }

}