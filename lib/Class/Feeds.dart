import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/Feed.dart';
import 'dart:convert';
import 'package:travel_sharing/main.dart';

class Feeds{
  List<Feed> feeds;
  int Offset;
  bool isMore;

  Feeds({this.feeds, this.Offset,this.isMore });

  Feeds.fromJson(Map<String, dynamic> json) {
   feeds = List();
    json['data'].forEach((x) {
      feeds.add(Feed.fromJson(x));
    });
    Offset = json['offset'];
    isMore = json['isMore'];
  }

  Future<Feeds> getFeed(int offset, List<String> filter,String userid) async {
    try{
      Http.Response response = await httpClass.reqHttp("/api/routes/feeds", { "offset" : offset , "filter" :  filter,"id": userid });
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          return Future.value(Feeds.fromJson(jsonDecode(response.body)));
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Match_List");
    }
  }
}
