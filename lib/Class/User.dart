import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';

final String localhost = "192.168.1.14";
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

  Future<User> getCurrentuser(String id) async{
    try{
      var url = "http://$localhost:3000/api/user/isreg";
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



  Future<bool> Register() async {
    try{
      if(await getCurrentuser(this.id) == null){
        var url = "http://$localhost:3000/api/user/register";
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

  Future<List<Routes>> getRoutes(int role) async {
    try{
        var url = "http://$localhost:3000/api/routes/getRoutes";
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
            List<Routes> listroutes = List();
            data['event']['join'].forEach((x) {
              listroutes.add(Routes.fromJson(x));
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