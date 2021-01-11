import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'dart:convert';
import 'package:travel_sharing/main.dart';

class Notifications{
  String Title;
  String Message;
  String sender;
  String tag;
  String date;
  String uid;
  String src;
  String dst;

  Notifications({this.Title, this.Message , this.date ,this.sender,this.tag, this.dst, this.src});

  Notifications.fromJson(Map<String, dynamic> json) {
    uid = json['_id'];
    Title = json['title'];
    Message = json['message'];
    date = json['date'];
    tag = json['tag'];
    sender = json['sender'] ?? " ";
    src = json['src'];
    dst = json['dst'];
  }

  Future<List<Notifications>> getNotification(String id,bool isNeed2Update) async {
    try{
      Http.Response response = await httpClass.reqHttp("/api/routes/getNotification",{ "id" : id , "isNeed2Update" : isNeed2Update});
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          List<dynamic> data = jsonDecode(response.body);
          List<Notifications> Notifications_List = List();
          data.forEach((x) {
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

  Future<bool> deleteNotification(String userid) async {
    try{
      Http.Response response = await httpClass.reqHttp("/api/routes/deleteNotifications",{ "notiId" : this.uid , "id" : userid});
      if(response.statusCode == 400 ){
        return Future.value(false);
      }else{
        if(response.statusCode == 404){
          return Future.value(false);
        }else{
          return Future.value(true);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Match_List");
    }
  }
}
