
import 'dart:convert';

import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/main.dart';

class Travel_Info{
  Routes routes;
  String id;
  String uid;
  String status;

  Travel_Info({this.routes, this.id, this.uid});

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
          print("ssssssssssssssssssssssssss");
          List<Travel_Info> travel_info_list = List();
          data['data']['event'][path[role]].forEach((x) {
            Travel_Info tmp = Travel_Info.fromJson(x);
            tmp.status = data['status'][tmp.uid];
            travel_info_list.add(tmp);
            print(tmp.status);
          });
          return Future.value(travel_info_list);
        }
      }
  }

  Future<bool> deleteTravel() async {
    try{
      Http.Response response = await httpClass.reqHttp("/api/routes/DeleteRoute",{"tripid": this.uid, "id": this.id});
      if(response.statusCode == 400){
        return Future.value(false);
      }else{
        print("Delete Travel Route : ${response.body}");
        return Future.value(true);
      }
    }catch (err){
      throw("can't connect" + err);
    }
  }
}