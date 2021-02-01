import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/main.dart';

class MapStaticRequest{

  String getMapUrl(Routes user,Routes other){
    String url ="http://maps.googleapis.com/maps/api/staticmap?size=512x1980&key=$api_key";
    String path = "&path=color:0xFFB400|weight:7|";
    String marker =  "";
    String end = "&sensor=false";
    List<String> markericon = ["icon:https://i.ibb.co/RNhMDcD/person-min.png","icon:https://i.ibb.co/b6QjxL5/dst-paiduay-min.png"];
    for(int i = 0 ; i< user.routes.length ;i++){
      path += "${user.routes[i].latitude},${user.routes[i].longitude}";
      if ( i != user.routes.length - 1){
        path += "|";
      }
    }
    if(other != null)
    for(int i = 0 ; i< other.routes.length ;i++){
      marker += "&markers=${markericon[i]}|${other.routes[i].latitude},${other.routes[i].longitude}";
      if ( i != other.routes.length - 1){
        marker += "|";
      }
    }
    print(url+path+marker+end);
    return url+path+marker+end;
  }

  String join_getMapUrl(Routes user){
    List<String> markericon = ["icon:https://i.ibb.co/RNhMDcD/person-min.png","icon:https://i.ibb.co/b6QjxL5/dst-paiduay-min.png"];
    String url ="http://maps.googleapis.com/maps/api/staticmap?size=512x1980&key=$api_key";
    String marker =  "";
    String end = "&sensor=false";
    if(user != null)
      for(int i = 0 ; i< user.routes.length ;i++){
        marker += "&markers=${markericon[i]}|${user.routes[i].latitude},${user.routes[i].longitude}";
        if ( i != user.routes.length - 1){
          marker += "|";
        }
      }
    print(url+marker+end);
    return url+marker+end;
  }

  String invite_getMapUrl(Routes user){
    List<String> markericon = ["icon:https://i.ibb.co/sCh6hMW/car-min.png","icon:https://i.ibb.co/7Snt16C/dst-chuan-min.png"];
    String url ="http://maps.googleapis.com/maps/api/staticmap?size=512x1980&key=$api_key";
    String path = "&path=color:0xFFB400|weight:7|";
    String marker =  "";
    String end = "&sensor=false";
    for(int i = 0 ; i< user.routes.length ;i++){
      path += "${user.routes[i].latitude},${user.routes[i].longitude}";
      if ( i != user.routes.length - 1){
        path += "|";
      }
    }
    List<LatLng> other = [user.routes.first,user.routes.last];
    if(other != null)
      for(int i = 0 ; i< other.length ;i++){
        marker += "&markers=${markericon[i]}|${other[i].latitude},${other[i].longitude}";
        if ( i != other.length - 1){
          marker += "|";
        }
      }
    print(url+path+marker+end);
    return url+path+marker+end;
  }

}