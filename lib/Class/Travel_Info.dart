
import 'dart:convert';

import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/main.dart';

class Travel_Info{
  Routes routes;
  String id;
  String uid;

  Travel_Info({this.routes, this.id});

  Travel_Info.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json['detail']);
    id = json['detail']['id'];
    uid = json['_id'];
  }

  Future<List<Travel_Info>> getRoutes(String id,int role,bool isNeed2Update) async {
//    try{
      Map<int,String> path = {0:'invite',1:'join'};
      Http.Response response = await httpClass.reqHttp("/api/routes/getRoutes",{'id':id,'role':role,'isNeed2Update' : isNeed2Update});
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else {
        if (response.statusCode == 404) {
          return Future.value(null);
        } else {
          print(role);
          Map<String, dynamic> data = jsonDecode(response.body);
          List<Travel_Info> travel_info_list = List();
          data['event'][path[role]].forEach((x) {
            Travel_Info tmp = Travel_Info.fromJson(x);
            travel_info_list.add(tmp);
            print(tmp.routes.src);
          });
          return Future.value(travel_info_list);
        }
      }
  }
}