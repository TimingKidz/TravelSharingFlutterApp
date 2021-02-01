import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';

class Feed{
  Routes routes;
  User user;

  Feed({this.routes, this.user});

  Feed.fromJson(Map<String, dynamic> json) {
    routes = Routes.fromJson(json);
    user = User.fromJson(json['id']);
  }

}
