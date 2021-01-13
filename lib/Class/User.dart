import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/Status.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/main.dart';
import 'package:image/image.dart' as img;
import 'package:travel_sharing/Class/Review.dart';

class User {
  String name;
  String username;
  String email;
  String id;
  String uid;
  String faculty;
  String gender;
  List<Vehicle> vehicle;
  String token;
  Status status;
  String imgpath;
  String birthDate;
  ReviewSummary reviewSummary;


  User({this.name,this.username,this.birthDate, this.email,this.id,this.uid,this.faculty,this.gender,this.vehicle,this.token,this.status,this.imgpath,this.reviewSummary});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    username = json['username'];
    email = json['email'];
    id = json['id'];
    uid = json['_id'];
    faculty = json['faculty'];
    gender = json['gender'];
    vehicle = List();
    if(json['vehicle'] != null){
      json['vehicle'].forEach((data) {
        if (!(data is String))
          vehicle.add(Vehicle.fromJson(data));
      });
    }
    token = json['token'];
    if( json['status'] != null){
      status = Status.fromJson(json['status']);
    }
    imgpath = json['imgpath'];
    reviewSummary = ReviewSummary.fromJson(json['Review']);
    birthDate = json['birthDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['username'] =this.username;
    data['email'] = this.email;
    data['id']= this.id;
    data['_id'] = this.uid;
    data['faculty'] = this.faculty;
    data['gender'] = this.gender;
    data['vehicle'] = this.vehicle;
    data['token'] = this.token;
    data['birthDate'] = this.birthDate;
    return data;
  }

 // get current user data
  Future<User> getCurrentuser(String id) async{
    try{
      Http.Response response = await httpClass.reqHttp("/api/user/isreg",{ "id":id });
      if(response.statusCode == 400){
        return Future.value(null);
      }else{
        if(response.statusCode == 404 ){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
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
//      if(await getCurrentuser(this.id) == null){
        Http.Response response = await httpClass.reqHttp("/api/user/register",this.toJson());
        if(response.statusCode == 400 ){
          return Future.value(false);
        }else{
          print("Register Succesful : ${response.body}");
          return Future.value(true);
        }
//      }else{
//        return Future.value(true);
//      }
    }catch(error){
     throw("can't connect"+error);
    }
  }

  Future<List<String>> getisReq(String id ,String _id) async {
//    try{
      Http.Response response = await httpClass.reqHttp("/api/routes/getisReq",{'id': id ,'_id' : _id});
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
//    }catch(error){
//      print(error);
//      throw("can't connect");
//    }
  }

  Future<bool> AcceptReq(String Reqid,String Currentid,String Current_id) async {
    try{
      Map<String, dynamic> temp = {
        'Reqid' : Reqid,
        'userid' : Currentid,
        'userRoute_id' : Current_id };
      Http.Response response = await httpClass.reqHttp("/api/routes/AcceptRequest",temp);
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
      Map<String, dynamic> temp = {
        'Reqid' : Reqid,
        'userid' : Currentid,
        'userRoute_id' : Current_id };
      Http.Response response = await httpClass.reqHttp("/api/routes/DeclineRequest",temp);
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
      this.token = tokenID;
      Http.Response response = await httpClass.reqHttp("/api/routes/updateToken",{"id":this.uid, "token_id": tokenID});
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
      Http.Response response = await httpClass.reqHttp("/api/routes/EndTrip",tmp);
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

  Future<bool> editUser() async {
    try{
      Http.Response response = await httpClass.reqHttp("/api/routes/editUser",this.toJson());
      if(response.statusCode == 400){
        return Future.value(false);
      }else{
        print("Edit user : ${response.body}");
        return Future.value(true);
      }
    }catch (err){
      throw("can't connect" + err);
    }
  }

  Future<bool> uploadProfile(File file)async{
    try{
      img.Image image = img.decodeImage(file.readAsBytesSync());
      image = img.copyResize(image,
          width: 512,
          height: 512);
      Http.StreamedResponse response = await httpClass.reqHttpMedia(image,this.uid,"profile","/api/user/profile");
      if(response.statusCode == 400){
        return Future.value(false);
      }else{
        print("upload succesful");
        return Future.value(true);
      }
    }catch (err){
      throw("can't connect" + err);
    }
  }

  Future<bool> uploadImg(File file, String routeID)async{
    try{
      img.Image image = img.decodeImage(file.readAsBytesSync());
      image = img.copyResize(image,
          width: 512,
          height: 512);
      Http.StreamedResponse response = await httpClass.reqHttpMedia(image,this.uid,routeID,"/api/user/img");
      if(response.statusCode == 400){
        return Future.value(false);
      }else{
        print("upload succesful");
        return Future.value(true);
      }
    }catch (err){
      throw("can't connect" + err);
    }
  }
}