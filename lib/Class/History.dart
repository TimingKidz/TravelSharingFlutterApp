//import 'dart:convert';
//
//import '../main.dart';
//import 'RouteJson.dart';
//import 'package:http/http.dart' as Http;
//
//class History{
//  Routes routes;
//  String id;
//  String uid;
//
//  History({this.routes, this.id});
//
//  History.fromJson(Map<String, dynamic> json) {
//    routes = Routes.fromJson(json['detail']);
//    id = json['detail']['id'];
//    uid = json['_id'];
//  }
//
//  Future<List<History>> getHistories(String userID) async {
//   // try {
//     Http.Response response = await httpClass.reqHttp("/api/routes/getHistory", {'id': userID});
//     if (response.statusCode == 400) {
//       return Future.value(null);
//     } else {
//       if (response.statusCode == 404) {
//         return Future.value(null);
//       } else {
//         Map<String, dynamic> data = jsonDecode(response.body);
//         List<History> historyList = List();
////         print(data);
//         data['History'].forEach((x) {
////           print(x);
////           History tmp = History.fromJson(x);
////           historyList.add(tmp);
////           print(tmp.routes.src);
//         });
//         return Future.value(historyList);
//       }
//     }
//   // }catch(err){
//   //   throw("can't connect" + err);
//   // }
//  }
//}