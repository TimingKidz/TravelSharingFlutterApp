import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/User.dart';

import '../main.dart';



class Routes {
  String id;
  List<LatLng> routes;
  String src;
  String dst;
  String amount;
  String date;
  bool isMatch;
  List<String> match;

  Routes({this.id,this.routes, this.src,this.dst,this.amount,this.date,this.isMatch,this.match});

  Routes.fromJson(Map<String, dynamic> json) {
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
        temp.add(x);
      });
      match = temp;
    }else{
      match = List();
    }
    src = json['src'];
    dst = json['dst'];
    amount = json['amount'];
    date = json['date'];
    id = json['id'];
    isMatch = json['isMatch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['src'] = this.src;
    data['dst'] = this.dst;
    data['routes']= this.routes;
    data['amount']=this.amount;
    data['date']=this.date;
    data['id'] = this.id;
    data['match'] = this.match;
    return data;
  }

  // save routes information to DB
  Future<bool> SaveRoute_toDB(int role,User user) async{
    try{
      var url = "${HTTP().API_IP}/api/routes/SaveRoutes";
      Map<String, dynamic> temp = user.toJson();
      temp['detail'] = this.toJson();
      temp['role'] = role;
      print(jsonEncode(temp));
      Http.Response response = await Http.post(url, headers : await HTTP().header() , body: jsonEncode(temp));
      if( response.statusCode == 400 ){
        return Future.value(null);
      }else{
        return Future.value(true);
      }
    }catch(error){
      print(error);
    }
  }

  // send request to selected routes ( data is current user routes , data0 is who current user select routes )
  Future<bool> Request(Match_Info data , Travel_Info data0)async {
    try{
      var url = "${HTTP().API_IP}/api/routes/request";
      Map<String,dynamic> temp = {
        'detail' : data0.routes.toJson(),
        'to_id' : data.uid,
        'toid' : data.id,
        'form_id' : data0.uid,
        'formid' : data0.id };
      jsonEncode(temp);
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode(temp));
      if(response.statusCode == 400 ){
        return Future.value(false);
      }else{
        print("Req Succesful : ${response.body}");
        return Future.value(true);
      }
    }catch(error){
      throw("can't connect");
    }
  }

}