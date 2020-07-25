import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as Http;

class DogService {
  static randomDog() {
    var url = "https://dog.ceo/api/breeds/image/random";
    Http.get(url).then((response) {
      print("Response status: ${response.body}");
    });
  }
}

class Routes {
  List<LatLng> routes;
  String src;
  String dst;
  String amount;
  String date;

  Routes({this.routes, this.src,this.dst,this.amount,this.date});

  Routes.fromJson(Map<String, dynamic> json) {
    routes = json['routes'];
    src = json['src'];
    dst = json['dst'];
    amount = json['amount'];
    date = json['date'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['src'] = this.src;
    data['dst'] = this.dst;
    data['routes']= this.routes;
    data['amount']=this.amount;
    data['date']=this.date;
    return data;
  }


}