import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as Http;
import 'package:travel_sharing/main.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

class HTTP{
//  final String API_IP = "https://68.183.226.229";
  final String API_IP = "http://10.80.27.151:3000";
  Map<String,String>  header ;
  Map<String,String>  mediaHeader ;

  Future<Map<String,String>> getNewHeader() async {
    String tmp = await firebaseAuth.user.getIdToken();
    header = {'Content-Type': 'application/json; charset=UTF-8','auth' : tmp};
    mediaHeader = {"Content-type": "multipart/form-data", "auth" : tmp };
  }

  Future<Http.Response> reqHttp(String path,Map<String,dynamic> data) async {
    try{
      var url = this.API_IP + path;
      print(url);
        Http.Response response = await Http.post(url, headers: this.header, body: jsonEncode(data));
        print(response.statusCode.toString());
        if(response.statusCode == 401 ){
          print("refresh tokennnnnnnnnnnnnnnnnnnnnnn");
          await getNewHeader();
          Http.Response response = await Http.post(url, headers: this.header, body: jsonEncode(data));
            return Future.value(response);
        }else{
          return Future.value(response);
        }
    }catch(error){
      print(error);
      throw("can't connect Match_List");
    }
  }

  Future<Http.StreamedResponse> reqHttpMedia(img.Image image,String dir,String filename)async{
    try{
        Http.MultipartRequest request = Http.MultipartRequest(
          'POST', Uri.parse("${API_IP}/api/user/${filename}"),
        );
        request.files.add(
          Http.MultipartFile.fromBytes(
            'file',
            img.encodeJpg(image),
            filename: filename,
            contentType: MediaType('image','jpeg'),
          ),
        );
        request.headers.addAll(mediaHeader);
        request.fields.addAll({ "dir" : dir });
        Http.StreamedResponse response = await request.send();
        if(response.statusCode == 401 ){
          print("refresh tokennnnnnnnnnnnnnnnnnnnnnn");
          await getNewHeader();
          request = Http.MultipartRequest(
            'POST', Uri.parse("${API_IP}/api/user/${filename}"),
          );
          request.files.add(
            Http.MultipartFile.fromBytes(
              'file',
              img.encodeJpg(image),
              filename: filename,
              contentType: MediaType('image','jpeg'),
            ),
          );
          request.headers.addAll(mediaHeader);
          request.fields.addAll({ "dir" : dir });
          Http.StreamedResponse response = await request.send();
          return Future.value(response);
        }else{
        return Future.value(response);
      }
    }catch(error){
      print(error);
      throw("can't connect Match_List");
    }
  }

}