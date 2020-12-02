import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/User.dart';

// final String heroku = "http://vast-eyrie-74860.herokuapp.com";
final String heroku = "http://10.80.129.94:3000";
final String localhost = "http://192.168.1.14:3000";
final Map<String,String> header = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};

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
      var url = "$heroku/api/routes/SaveRoutes";
      Map<String, dynamic> temp = user.toJson();
      temp['detail'] = this.toJson();
      temp['role'] = role;
      print(jsonEncode(temp));
      Http.Response response = await Http.post(url,headers: header , body: jsonEncode(temp));
      if( response.statusCode == 400 ){
        return Future.value(null);
      }else{
        return Future.value(true);
      }
    }catch(error){
      print(error);
    }
  }


 // get routes that close to your destination place
  Future< List< Map<String,dynamic>>> getNearRoutes() async {
    try{
      var url = "$heroku/api/routes/getNearRoutes";
      Map<String, dynamic> temp = this.toJson();
      print(jsonEncode(temp));
      Http.Response response = await Http.post(url, headers: header, body: jsonEncode(temp));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
          List<dynamic> data = jsonDecode(response.body);
          List< Map<String,dynamic>> list = List();
          data.forEach((x) {
            Map<String,dynamic> tmp = Map();
            tmp['detail'] = Routes.fromJson(x['detail']);
            tmp['id'] = x['id'];
            tmp['_id'] = x['_id'];
            tmp['name'] = x['name'];
            print(tmp);
            list.add(tmp);
          });
          return Future.value(list);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect");
    }
  }

  // send request to select routes ( data is current user routes , data0 is who current user select routes )
  Future<bool> Request(Map<String,dynamic> data,Map<String,dynamic> data0) async {
    try{
      var url = "$heroku/api/routes/request";
      Map<String,dynamic> temp = Map();
      temp['detail'] = data0['detail'].toJson();
      temp['to_id'] = data['_id'];
      temp['toid'] = data['id'];
      temp['form_id'] = data0['_id'];
      temp['formid'] = data0['id'];
      print(jsonEncode(temp));
      Http.Response response = await Http.post(url, headers: header, body: jsonEncode(temp));
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

  // get request list of current routes (data)
  Future<List<Map<String, dynamic>>> getReq(Map<String,dynamic> data) async {
    try{
      var url = "$heroku/api/user/getReqList";
      Map<String, dynamic> temp = Map();
      temp['id'] = data['id'];
      temp['to_id'] = data['_id'];
      print(jsonEncode(temp));
      Http.Response response = await Http.post(url, headers: header, body: jsonEncode(temp));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
          List<dynamic> Data = jsonDecode(response.body);
          List<Map<String, dynamic>> listroutes = List();
          Data.forEach((x) {
            Map<String,dynamic> tmp = Map();
            tmp['detail'] = Routes.fromJson(x['detail']);
            tmp['id'] = x['id'];
            tmp['_id'] = x['_id'];
            tmp['name'] = x['name'];
            tmp['reqid'] = x['reqid'];
            listroutes.add(tmp);
          });
          return Future.value(listroutes);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect");
    }
  }


}