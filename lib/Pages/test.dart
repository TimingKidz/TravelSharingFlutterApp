import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as Http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File selectedImage;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Upload Example"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.25,
                child: FutureBuilder(
                  future: _getImage(context),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text('Please wait');
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else {
                          return selectedImage != null
                              ? Image.file(selectedImage)
                              : Center(
                            child: Text("Please Get the Image"),
                          );
                        }
                    }
                  },
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[500])),
              ),
            ],
          ),
          SizedBox(height: 20,),
          RaisedButton(
            color: Colors.cyan,
            onPressed: (){
              print("test");
              submitSubscription(selectedImage,"600610740.jpg");
            },
            child: Text("Upload"),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  //get image from camera
  Future getImage() async {
    PickedFile image = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        selectedImage = File(image.path);
      } else {
        print('No image selected.');
      }
    });
    //return image;
  }

  //resize the image
  Future<void> _getImage(BuildContext context) async {
    if (selectedImage != null) {
      var imageFile = selectedImage;


//      _image = image;
    }
  }

  Future<int> submitSubscription(File file,String filename)async{
    ///MultiPart request
    Http.MultipartRequest request = Http.MultipartRequest(
      'POST', Uri.parse("http://192.168.137.1:3000/api/user/profile"),
    );

    Map<String,String> headers={
//      "Authorization":"Bearer $token",
      "Content-type": "multipart/form-data",
      "auth" : "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNjYmM4ZjIyMDJmNjZkMWIxZTEwMTY1OTFhZTIxNTZiZTM5NWM2ZDciLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVGh1dCBDaGF5YXNhdGl0IiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hLS9BT2gxNEdqTVFOdXlEQTV5bjRqSlljMk5EN25LU1N4M0xkZ0xPbm1UaTJKRD1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS90cmF2ZWxzaGFyaW5nLTg2ZmMyIiwiYXVkIjoidHJhdmVsc2hhcmluZy04NmZjMiIsImF1dGhfdGltZSI6MTYwODk4MTk4MywidXNlcl9pZCI6Ilo1Uk9ncVZjbjFOWnBkdGF2cWFldUhNM1dzbTEiLCJzdWIiOiJaNVJPZ3FWY24xTlpwZHRhdnFhZXVITTNXc20xIiwiaWF0IjoxNjA4OTg4ODM4LCJleHAiOjE2MDg5OTI0MzgsImVtYWlsIjoidGh1dGJvb216QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7Imdvb2dsZS5jb20iOlsiMTA1NjY1NTM1MDc3MTExOTc0NjgzIl0sImVtYWlsIjpbInRodXRib29tekBnbWFpbC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJnb29nbGUuY29tIn19.Uywen7F_zlA46ZnbXvMNf2KdhkSmseEb3dqqYqaL5Zzy7bb8_xuFg7Mz_ZQOJsSlXhSKlFQSg2ZcUOU8jewIzznpvpfsdXhYkxQ3jt_EuXPEotXIdKlx7MSnkJBiC5dx3wbwgf2D7FsbFZXbXFyFzzFbQsTMmTR2A3AziaL3WOl-MAn5uqj8Kic8L3QjbesUQRUBesT7GDJPKRlwc3-0U7rsAwpMPlUtecnk9p8F1DyyKW1_hCRBrJc5XgDaPujP0z2hUJzOMtIXD59WtSHy0B9m-W5t57doe2rMF2QZqWFyw4zsfFC3PDC9CVW6voSkeM6Fpud7JHZiWSOkk8dzLw"
    };

    img.Image image = img.decodeImage(file.readAsBytesSync());
    image = img.copyResize(image,
        width: 512,
        height: 512);

    request.files.add(
      Http.MultipartFile.fromBytes(
        'file',
        img.encodeJpg(image),
        filename: filename,
        contentType: MediaType('image','jpeg'),
      ),
    );
    request.headers.addAll(headers);
    request.fields.addAll({
      "dir":"6006107400"
    });
//    print("request: "+request.toString());
    Http.StreamedResponse res = await request.send();
    print("This is response:"+res.statusCode.toString());
    return res.statusCode;
  }
}