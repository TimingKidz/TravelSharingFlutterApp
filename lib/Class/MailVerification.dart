
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

  Future<String> changeMail(String newMail,User user)async{
    try{
      Http.Response response = await httpClass.reqHttp("/api/user/changeMail",{"newmailcmu" : newMail,"oldmailcmu" : user.mailcmu ,"_id": user.uid });
      if(response.statusCode == 400){
        return Future.value("Can not change. Please try again.");
      }else{
        Map<String,dynamic> tmp = jsonDecode(response.body);
        return Future.value(tmp['message']);
      }
    }catch (err){
      throw("can't connect" + err);
    }
  }

  Future<bool> resend(User user)async{
    try{
      Http.Response response = await httpClass.reqHttp("/api/user/resendCode",{"_id": user.uid });
      if(response.statusCode == 400){
        return Future.value(false);
      }else{
        return Future.value(true);
      }
    }catch (err){
      throw("can't connect" + err);
    }
  }




}


