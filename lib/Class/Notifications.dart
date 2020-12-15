import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'dart:convert';
import 'package:travel_sharing/main.dart';

class Notifications{
  String Title;
  String Message;
  String date;

  Notifications({this.Title, this.Message , this.date });

  Notifications.fromJson(Map<String, dynamic> json) {
    Title = json['title'];
    Message = json['message'];
    date = json['date'];
  }

  Future<List<Notifications>> getNotification(String id) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/getNotification";
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode({ "id" : id }));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          Map<String, dynamic> data = jsonDecode(response.body);
          List<Notifications> Notifications_List = List();
          data['Notifications'].forEach((x) {
            Notifications_List.add(Notifications.fromJson(x));
          });
          return Future.value(Notifications_List);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Match_List");
    }
  }
}
