import 'dart:convert';

import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/main.dart';

class Req_Info {
  Routes routes;
  String id;
  String uid;
  String name;
  String reqid;

  Req_Info({this.routes, this.id,this.uid,this.name,this.reqid});

  Req_Info.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json['detail']);
    id = json['id'];
    uid = json['_id'];
    name = json['name'];
    reqid = json['reqid'];
  }

  Future<List<Req_Info>> getReq(Travel_Info data) async {
    try{
      var url = "${HTTP().API_IP}/api/user/getReqList";
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode({'id':data.id,'to_id':data.uid}));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          List<dynamic> Data = jsonDecode(response.body);
          List<Req_Info> Req_Info_List = List();
          Data.forEach((x) {
            Req_Info tmp = Req_Info.fromJson(x);
            Req_Info_List.add(tmp);
          });
          return Future.value(Req_Info_List);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Req");
    }
  }
}