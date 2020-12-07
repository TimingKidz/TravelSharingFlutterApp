import 'dart:convert';

import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/main.dart';


class TripDetails{
  Routes routes;
  User hostUser;
  List<Routes> subRoutes;
  List<User> subUser;

  TripDetails({this.routes,this.hostUser, this.subRoutes, this.subUser});

  TripDetails.fromJson(Map<String, dynamic> json){
    routes =  Routes.fromJson(json);
    hostUser = User.fromJson(json['id']);
    subRoutes = List();
    subUser = List();
    json['match'].forEach((x) {
      subRoutes.add(Routes.fromJson(x));
      subUser.add(User.fromJson(x['id']));
    });
  }

  Future<TripDetails> getDetails(String uid) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/Tripinformation";
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode({"_id":uid}));
      if(response.statusCode == 400){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
          return Future.value(TripDetails.fromJson(jsonDecode(response.body)));
        }
      }
    }catch(err){
      print(err);
      throw("can't connect Match");
    }
  }
}
