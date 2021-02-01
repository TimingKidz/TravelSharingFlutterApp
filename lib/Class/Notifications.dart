import 'package:http/http.dart' as Http;
import 'dart:convert';
import 'package:travel_sharing/main.dart';

class Notifications{
  String Title;
  String tripid;
  String sender;
  String tag;
  String date;
  String uid;
  String src;
  String dst;
  String lastStamp;
  List<Child> child;

  Notifications({this.Title, this.tripid , this.date ,this.sender,this.tag, this.dst, this.src, this.lastStamp});

  Notifications.fromJson(Map<String, dynamic> json) {
    uid = json['_id'];
    Title = json['title'];
    tripid = json['tripid'];
    date = json['date'];
    tag = json['tag'];
    sender = json['sender'] ?? " ";
    src = json['src'];
    dst = json['dst'];
    child = List();
    json['child'].forEach((x){
        child.add(Child.fromJson(x));
    });
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
          print(data);
          List<Notifications> Notifications_List = List();
          data.forEach((x) {
            Notifications tmp = Notifications.fromJson(x);
            if(tmp.child.isNotEmpty){
              Notifications_List.add(tmp);
            }
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


class Child {
  String type;
  String message;
  int count;
  String timestamp;

  Child(
      {this.type, this.message, this.count, this.timestamp});

  Child.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    message = json['message'];
    count = json['count'];
    timestamp = json['timestamp'];
  }
}