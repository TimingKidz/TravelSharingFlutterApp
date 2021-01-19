import 'dart:convert';

import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/main.dart';

class Req_Info {
  Routes routes;
  User user;
  String reqid;
  bool isOffer;

  Req_Info({this.routes,this.user,this.reqid,this.isOffer});

  Req_Info.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json['detail']);
    user = User.fromJson(json['detail']['id']);
    reqid = json['_id'];
  }

  Future<List<Req_Info>> getReq(Travel_Info data,bool isNeed2Update) async {
    try{
      Http.Response response = await httpClass.reqHttp("/api/user/getReqList",{'id':data.id,'to_id':data.uid,"isNeed2Update" : isNeed2Update});
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          Map<String, dynamic> Data = jsonDecode(response.body);
          List<Req_Info> Req_Info_List = List();
          Data["req"].forEach((x) {
            if(x['detail'] != null){
              Req_Info tmp = Req_Info.fromJson(x);
              tmp.isOffer = Data["offer"].contains(tmp.routes.uid);
              Req_Info_List.add(tmp);
            }
          });
          print(Req_Info_List.length);
          return Future.value(Req_Info_List);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Req");
    }
  }
}