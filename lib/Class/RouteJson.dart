import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;

final String localhost = "192.168.1.14";
final Map<String,String> header = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};

class Routes {
  String id;
//  int role;
  List<LatLng> routes;
  String src;
  String dst;
  String amount;
  String date;


  Routes({this.id,this.routes, this.src,this.dst,this.amount,this.date});

  Routes.fromJson(Map<String, dynamic> json) {
    List<LatLng> temp = List();
    json['routes'].forEach((x){
      temp.add(LatLng(x[0],x[1]));
    });
    routes = temp;
    src = json['src'];
    dst = json['dst'];
    amount = json['amount'];
    date = json['date'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['src'] = this.src;
    data['dst'] = this.dst;
    data['routes']= this.routes;
    data['amount']=this.amount;
    data['date']=this.date;
    data['id'] = this.id;
    return data;
  }

  Future<bool> SaveRoute_toDB(int role) async{
    try{
      var url = "http://$localhost:3000/api/routes/SaveRoutes";
      Map<String, dynamic> temp = this.toJson();
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


}