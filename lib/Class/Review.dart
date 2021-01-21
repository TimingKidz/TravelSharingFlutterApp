import 'dart:convert';

import 'package:travel_sharing/main.dart';
import 'package:http/http.dart' as Http;

class ReviewSummary{
  String uid;
  String id;
  double totalscore;
  int amount;

  ReviewSummary({this.totalscore,this.amount});

  ReviewSummary.fromJson(Map<String, dynamic> json) {
    uid = json['_id'];
    id = json['id'];
    totalscore = json['totalscore'].toDouble();
    amount = json['amount'];
  }

}

class Review {
  String uid;
  String id;
  bool isMore;
  int offset;
  double totalscore;
  int amount;
  Map<String,dynamic> tag;
  List<EachReview> review;

  Review({this.isMore,this.offset,this.totalscore, this.tag,this.review,this.amount});

  Review.fromJson(Map<String, dynamic> json) {
    uid = json['data']['_id'];
    id = json['data']['id'];
    totalscore = json['data']['totalscore'].toDouble();
    offset = json['offset'];
    isMore = json['isMore'];
    tag = json['data']['tag'];
    review = List();
    json['data']['review'].forEach((x){
      review.add(EachReview.fromJson(x));
    });
  }

  Future<Review> getReview(String userid,int offset) async {
    try {
      Http.Response response = await httpClass.reqHttp("/api/routes/getReview",{"id":userid,"offset":offset});
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
  String uid;
  double score;
  String sender;
  String name;
  String message;
  List<String> tag ;
  String date;
  String imgpath;

  EachReview({this.score, this.sender, this.name,this.message,this.tag,this.date,this.imgpath});

  EachReview.fromJson(Map<String, dynamic> json) {
    uid = json['_id'];
    score = json['score'].toDouble();
    sender = json['sender'];
    name = json['name'];
    message = json['message'];
    tag = List();
    json['tag'].forEach((x){
      tag.add(x.toString());
    });
    date = json['date'];
    imgpath = json['imgpath'];
  }

  Map<String, dynamic> toJson(String sendToid,String notiId) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['score'] = this.score;
    data['sender'] = this.sender;
    data['name']= this.name ;
    data['message'] = this.message;
    data['tag'] = this.tag ;
    data['imgpath'] = this.imgpath;
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
//          print(jsonDecode(response.body));
          return Future.value(true);
        }
      }
    } catch (error) {
      print(error);
      throw("can't connect sendReview");
    }
  }
}