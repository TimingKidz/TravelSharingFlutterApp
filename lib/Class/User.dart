import 'dart:convert';
import 'package:http/http.dart' as Http;

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

  Future<User> getCurrentuser() async{
    var url = "http://$localhost:3000/api/user/isreg";
    Http.Response response = await Http.post(url,headers: header , body: jsonEncode(this.toJson()));
    if( response.statusCode == 400 ){
      return Future.value(null);
    }else{
      if(response.statusCode == 404 ){
        return Future.value(null);
      } else{
        return Future.value(User.fromJson(jsonDecode(response.body)));
      }
    }

  }

  Future<bool> Register() async {
    if(await getCurrentuser() == null){
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

  }

}