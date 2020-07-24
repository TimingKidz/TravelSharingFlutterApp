import 'package:http/http.dart' as Http;

class DogService {
  static randomDog() {
    var url = "https://dog.ceo/api/breeds/image/random";
    Http.get(url).then((response) {
      print("Response status: ${response.body}");
    });
  }
}

class MessageDogsDao {
  String status;
  String message;

  MessageDogsDao({this.status, this.message});

  MessageDogsDao.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}