import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';

//final String heroku = "http://vast-eyrie-74860.herokuapp.com";
final String heroku = "http://10.10.10.60:3000";
final String localhost = "http://192.168.1.14:3000";
final Map<String,String> header = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};

class User {
  String name;
  String email;
  String id;


  User({this.name, this.email,this.id});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['id']= this.id;
    return data;
  }

 // get current user data
  Future<User> getCurrentuser(String id) async{
    try{
      var url = "$heroku/api/user/isreg";
      Http.Response response = await Http.post(url,headers: header , body: jsonEncode(<String,String>{ "id":id }));
      if( response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404 ){
          return Future.value(null);
        } else{
          return Future.value(User.fromJson(jsonDecode(response.body)));
        }
      }
    }catch(error){
      throw("can't connect");
    }
  }


  // register for new user
  Future<bool> Register() async {
    try{
      if(await getCurrentuser(this.id) == null){
        var url = "$heroku/api/user/register";
        Http.Response response = await Http.post(url, headers: header, body: jsonEncode(this.toJson()));
        if(response.statusCode == 400 ){
          return Future.value(false);
        }else{
          print("Register Succesful : ${response.body}");
          return Future.value(true);
        }
      }else{
        return Future.value(true);
      }
    }catch(error){
     throw("can't connect");
    }
  }

  // get all routes in each role of current user
  Future<List<Map<String, dynamic>>> getRoutes(int role) async {
    try{
        Map<int,String> path = {0:'invite',1:'join'};
        var url = "$heroku/api/routes/getRoutes";
        Map<String, dynamic> temp = this.toJson();
        temp['role'] = role;
        Http.Response response = await Http.post(url, headers: header, body: jsonEncode(temp));
        if(response.statusCode == 400 ){
          return Future.value(null);
        }else{
          if(response.statusCode == 404){
            return Future.value(null);
          }else{
            Map<String, dynamic> data = jsonDecode(response.body);
            List<Map<String, dynamic>> listroutes = List();
            data['event'][path[role]].forEach((x) {
              Map<String,dynamic> tmp = Map();
              tmp['detail'] = Routes.fromJson(x['detail']);
              tmp['id'] = x['detail']['id'];
              tmp['_id'] = x['_id'];
              print(tmp['detail'].src);
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