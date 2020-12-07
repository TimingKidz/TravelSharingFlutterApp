
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

  Future<List<Travel_Info>> getRoutes(String id,int role) async {
    try{
      Map<int,String> path = {0:'invite',1:'join'};
      var url = "${HTTP().API_IP}/api/routes/getRoutes";
      Http.Response response = await Http.post(url,headers:await HTTP().header(), body: jsonEncode({'id':id,'role':role}));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          Map<String, dynamic> data = jsonDecode(response.body);
          print(data);
          List<Travel_Info> travel_info_list = List();
          data['event'][path[role]].forEach((x) {
            Travel_Info tmp = Travel_Info.fromJson(x);
            travel_info_list.add(tmp);
          });
          return Future.value(travel_info_list);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect");
    }
  }
}