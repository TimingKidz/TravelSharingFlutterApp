import 'dart:convert';

import 'package:travel_sharing/main.dart';
import 'package:http/http.dart' as Http;


class Review {
  double totalscore;
  Map<String,dynamic> tag;
  List<EachReview> review;


  Review({this.totalscore, this.tag,this.review});

  Review.fromJson(Map<String, dynamic> json) {
    totalscore = json['score'];
    tag = json['tag'];
    review = List();
    json['review'].forEach((x){
      review.add(EachReview.fromJson(x));
    });

  }

  Future<Review> getReview(String userid) async {
    try {
      Http.Response response = await httpClass.reqHttp("/api/routes/getReview",{"id":userid});
      if (response.statusCode == 400) {
        return Future.value(null);
      } else {
        if (response.statusCode == 404) {
          return Future.value(null);
        } else {
          print(jsonDecode(response.body));
          return Future.value(Review.fromJson(jsonDecode(response.body)));
        }
      }
    } catch (error) {
      print(error);
      throw("can't connect sendReview");
    }
  }

}


class EachReview {
  double score;
  String sender;
  String name;
  String message;
  List<String> tag ;
  String date;

  EachReview({this.score, this.sender, this.name,this.message,this.tag,this.date});

  EachReview.fromJson(Map<String, dynamic> json) {
    score = json['score'];
    sender = json['sender'];
    name = json['name'];
    message = json['message'];
    tag = json['tag'];
    date = json['date'];
  }

  Map<String, dynamic> toJson(String sendToid,String notiId) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['score'] = this.score;
    data['sender'] = this.sender;
    data['name']= this.name ;
    data['message'] = this.message;
    data['tag'] = this.tag ;
    data['id'] = sendToid;
    data['notiId'] = notiId;
    return data;
  }

  Future<bool> sendReview(String sendToid,String notiId) async {
    try {
      Http.Response response = await httpClass.reqHttp("/api/routes/sendReview",this.toJson(sendToid,notiId));
      if (response.statusCode == 400) {
        return Future.value(false);
      } else {
        if (response.statusCode == 404) {
          return Future.value(false);
        } else {
          print(jsonDecode(response.body));
          return Future.value(true);
        }
      }
    } catch (error) {
      print(error);
      throw("can't connect sendReview");
    }
  }
}