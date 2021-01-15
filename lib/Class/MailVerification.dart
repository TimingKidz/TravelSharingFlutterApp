
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'dart:convert';
import 'package:travel_sharing/main.dart';

class MailVerification{
  String message;
  int count;

  MailVerification({this.message,this.count});

  MailVerification.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    count = json['count'];
  }

  Future<MailVerification> verify(String code,User user)async{
    try{
      Http.Response response = await httpClass.reqHttp("/api/user/verify",{"code" : code,"mailcmu" : user.mailcmu,"_id":user.uid });
      if(response.statusCode == 400){
        return Future.value(null);
      }else{
        return Future.value(MailVerification.fromJson(jsonDecode(response.body)));
      }
    }catch (err){
      throw("can't connect" + err);
    }
  }



}


