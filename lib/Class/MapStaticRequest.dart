import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/main.dart';

class MapStaticRequest{

  String getMapUrl(Routes user,Routes other){
    String url ="http://maps.googleapis.com/maps/api/staticmap?size=512x1980&key=${api_key}";
    String path = "&path=";
    String marker =  "&markers=|";
    String end = "&sensor=false";
    for(int i = 0 ; i< user.routes.length ;i++){
      path += "${user.routes[i].latitude},${user.routes[i].longitude}";
      if ( i != user.routes.length - 1){
        path += "|";
      }
    };
    for(int i = 0 ; i< other.routes.length ;i++){
      marker += "${other.routes[i].latitude},${other.routes[i].longitude}";
      if ( i != other.routes.length - 1){
        marker += "|";
      }
    };
    print(url+path+marker+end);
    return url+path+marker+end;
  }

}