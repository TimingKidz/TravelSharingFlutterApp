import 'dart:convert';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/main.dart';


class User {
  String name;
  String email;
  String id;
  String uid;
  String img_url;
  String faculty;
  String gender;
  Vehicle vehicle;
  String token;

  User({this.name, this.email,this.id,this.uid,this.img_url,this.faculty,this.gender,this.vehicle,this.token});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    id = json['id'];
    uid = json['_id'];
    img_url = json['img_url'];
    faculty = json['faculty'];
    gender = json['gender'];
    vehicle = json['vehicle'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['id']= this.id;
    data['_id'] = this.uid;
    data['img_url'] = this.img_url;
    data['faculty'] = this.faculty;
    data['gender'] = this.gender;
    data['vehicle'] = this.vehicle;
    data['token'] = this.token;
    return data;
  }

 // get current user data
  Future<User> getCurrentuser(String id) async{
    try{
      var url = "${HTTP().API_IP}/api/user/isreg";
      Http.Response response = await Http.post(url,headers: await HTTP().header() , body: jsonEncode(<String,String>{ "id":id }));
      if(response.statusCode == 400){
        return Future.value(null);
      }else{
        if(response.statusCode == 404 ){
          return Future.value(null);
        }else{
          return Future.value(User.fromJson(jsonDecode(response.body)));
        }
      }
    }catch(error){
      throw("can't connect getuser"+error.toString());
    }
  }

  // register for new user
  Future<bool> Register() async {
    try{
      if(await getCurrentuser(this.id) == null){
        var url = "${HTTP().API_IP}/api/user/register";
        Http.Response response = await Http.post(url, headers: await HTTP().header() , body: jsonEncode(this.toJson()));
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
     throw("can't connect"+error);
    }
  }

  Future<List<String>> getisReq(String id ,String _id) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/getisReq";
      Http.Response response = await Http.post(url, headers: await HTTP().header() , body: jsonEncode({'id': id ,'_id' : _id}));
      if(response.statusCode == 400 ){
          return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          Map<String, dynamic> data = jsonDecode(response.body);
          List<String> temp = List();
          data['event']['join'][0]['isreq'].forEach((x){
            temp.add(x);
          });
          return Future.value(temp);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect");
    }
  }

  Future<bool> AcceptReq(String Reqid,String Currentid,String Current_id) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/AcceptRequest";
      Map<String, dynamic> temp = {
        'Reqid' : Reqid,
        'userid' : Currentid,
        'userRoute_id' : Current_id };
      Http.Response response = await Http.post(url, headers: await HTTP().header() , body: jsonEncode(temp));
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
      throw("can't connect");
    }
  }

  Future<bool> DeclineReq(String Reqid,String Currentid,String Current_id) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/DeclineRequest";
      Map<String, dynamic> temp = {
        'Reqid' : Reqid,
        'userid' : Currentid,
        'userRoute_id' : Current_id };
      Http.Response response = await Http.post(url, headers: await HTTP().header() , body: jsonEncode(temp));
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
      throw("can't connect");
    }
  }

  Future<void> updateToken(String tokenID) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/updateToken";
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode({"id":this.uid, "token_id": tokenID}));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
        }
      }
    }catch(err){
      print(err);
      throw("can't connect Match");
    }
  }

  Future<bool> endTrip(Map<String,dynamic> tmp) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/EndTrip";
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode(tmp));
      if(response.statusCode == 400 ){
        return Future.value(false);
      }else{
        if(response.statusCode == 404){
          return Future.value(false);
        }else{
          return Future.value(true);
        }
      }
    }catch(err){
      print(err);
      throw("can't connect Match");
    }
  }



}