import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'dart:convert';
import 'package:travel_sharing/main.dart';

class Match_Info {
  Routes routes;
  String id;
  String uid;
  String name;

  Match_Info({this.routes, this.id ,this.uid,this.name});

  Match_Info.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json['detail']);
    id = json['detail']['id'];
    uid = json['_id'];
    name = json['name'];
  }

  Future< List<Match_Info>> getNearRoutes(Routes My_Routes) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/getNearRoutes";
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode( My_Routes.toJson()));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
          List<dynamic> data = jsonDecode(response.body);
          List< Match_Info > Match_Info_List = List();
          data.forEach((x) {
            Match_Info tmp = Match_Info.fromJson(x);
            Match_Info_List.add(tmp);
          });
          return Future.value(Match_Info_List);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Match_List");
    }
  }
}
