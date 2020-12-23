import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'dart:convert';
import 'package:travel_sharing/main.dart';

class Match_Info {
  Routes routes;
  User user;

  Match_Info({this.routes,this.user});

  Match_Info.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json);
    user = User.fromJson(json['id']);
  }

  Future< List<Match_Info>> getMatchList(Routes My_Routes) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/getMatchList";
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode( {"user": My_Routes.id,"tripid" : My_Routes.uid}));
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
