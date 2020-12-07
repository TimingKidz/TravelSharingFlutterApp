import 'dart:convert';

import 'package:travel_sharing/main.dart';
import 'package:http/http.dart' as Http;

class Message {

  String sender;
  String content;
  String timestamp;

  Message({this.sender, this.content, this.timestamp});

  Message.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    content = json['content'];
    timestamp = json['timestamp'];
  }

  Future<List<Message>> getMessage(String tripid) async {
    try {
      var url = "${HTTP().API_IP}/api/routes/getMessage";
      Http.Response response = await Http.post(
          url, headers: await HTTP().header(),
          body: jsonEncode({"tripid": tripid}));
      if (response.statusCode == 400) {
        return Future.value(null);
      } else {
        if (response.statusCode == 404) {
          return Future.value(null);
        } else {
          print(jsonDecode(response.body));
          Map<String, dynamic> data = jsonDecode(response.body);
          print(data);
          List<Message> Message_List = List();
          data['messages'].forEach((x) {
            Message tmp = Message.fromJson(x);
            Message_List.add(tmp);
          });
          return Future.value(Message_List);
        }
      }
    } catch (error) {
      print(error);
      throw("can't connect Match");
    }
  }

  Future<bool> sendMessage(String tripid,String message,String form_id,String name) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/sendMessage";
      Map<String,dynamic> tmp = {
        "title": name,
        "message" : message,
        "formid" : form_id,
        "tripid" : tripid
      };
      Http.Response response = await Http.post(url, headers: await HTTP().header() ,body: jsonEncode(tmp));
      if(response.statusCode == 400 ){
        return Future.value(false);
      }else{
        if(response.statusCode == 404){
          return Future.value(false);
        }else{
          print(jsonDecode(response.body));
          return Future.value(true);
        }
      }
    }catch(error){
      print(error);
      throw("can't send");
    }
  }
}