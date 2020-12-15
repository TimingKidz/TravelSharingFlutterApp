import 'package:http/http.dart' as Http;
import 'package:travel_sharing/Class/RouteJson.dart';
import 'dart:convert';
import 'package:travel_sharing/main.dart';

class Feed{
  List<Routes> Allroutes;
  int Offset;
  bool isMore;

  Feed({this.Allroutes, this.Offset });

  Feed.fromJson(Map<String, dynamic> json) {
    Allroutes = List();
    json['data'].forEach((x) {
      Allroutes.add(Routes.fromJson(x));
    });
    Offset = json['offset'];
    isMore = json['isMore'];
  }

  Future<Feed> getFeed(int offset) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/feeds";
      Http.Response response = await Http.post(url, headers: await HTTP().header(), body: jsonEncode({ "offset" : offset }));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          return Future.value(Feed.fromJson(jsonDecode(response.body)));
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Match_List");
    }
  }
}
