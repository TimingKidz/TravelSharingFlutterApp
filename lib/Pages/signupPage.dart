import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/borderTextField.dart';
import 'package:travel_sharing/buttons/cardDatePicker.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/main.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SignUpPage extends StatefulWidget {
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  // User user = new User(name: googleUser.displayName,email: googleUser.email,id: googleUser.id,token: await firebaseMessaging.getToken());
  User userData = new User(name: googleUser.displayName,email: googleUser.email,id: googleUser.id);
  final _formKey = GlobalKey<FormState>();
  List<String> genderList = ["Male", "Female", "LGBTQ"];
  List<String> facultyList = [
    "Mass Communication",
    "Agriculture",
    "Dentistry",
    "Associated Medical Science",
    "Law",
    "Business Administration",
    "Nursing",
    "Medicine",
    "Pharmacy",
    "Humanities",
    "Political Science and Public Administration",
    "Fine Arts",
    "Science",
    "Engineering",
    "Education",
    "Economics",
    "Architecture",
    "Social Sciences",
    "Veterinary Medicine",
    "Public Health",
    "Agro-Industry",
    "College of Art, Media and Technology",
  ];
  File selectedImage;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    userData.gender = genderList.first;
    userData.faculty = facultyList.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Sign Up to Travel Sharing'),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              // padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: fieldList(),
                        ),
                      )
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton(
                      child: Icon(Icons.arrow_forward_ios),
                      onPressed: (){
                        if(_formKey.currentState.validate()) _Nextpage();
                      }
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  List<Widget> fieldList(){
    // TODO: Add missing field in User class
    return [
      SizedBox(height: 8.0),
      CircleAvatar(
        radius: 64,
        // backgroundColor: Colors.transparent,
        child: InkWell(
          onTap: (){
            getImage();
          },
          child: ClipOval(
            child: selectedImage != null ? Image.file(selectedImage): Container()
          ),
        )
      ),
      SizedBox(height: 8.0),
      CardTextField(
        notNull: true,
        initValue: googleUser.displayName,
        labelText: "Full Name",
        onChanged: (data) => userData.name = data,
      ),
      CardTextField(
        notNull: true,
        labelText: "Username",
        onChanged: (data) => print(data),
      ),
      CardDropdown(
        listItems: genderList,
        labelText: "Gender",
        onChanged: (data) => userData.gender = data,
      ),
      CardDatePicker(
        labelText: "Birthday",
        isJustDate: true,
        onDatePick: (date){

        },
      ),
      CardDropdown(
        listItems: facultyList,
        labelText: "Faculty",
        onChanged: (data) => userData.faculty = data,
      ),
      CardTextField(
        notNull: true,
        labelText: "Phone",
        isPhoneValidator: true,
        inputFormat: <TextInputFormatter>[
           FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        type: TextInputType.phone,
        onChanged: (val) => print(val),
      )
    ];
  }

  Future getImage() async {
    PickedFile image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        selectedImage = File(image.path);
        print("selected img");
      } else {
        print('No image selected.');
      }
    });
  }

  initsocket(){
    socket = IO.io(httpClass.API_IP,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableReconnection()
            .disableAutoConnect()
            .setExtraHeaders({'uid': currentUser.uid,'auth' : httpClass.header['auth']})
            .build());
    socket = socket.connect();
    socket.onConnect((_) {
      print('connect');
    });
  }

  _Nextpage() async {
    userData.token = await firebaseMessaging.getToken();
    await userData.Register();
    currentUser = await User().getCurrentuser(googleUser.id);
    if ( selectedImage != null){
      await currentUser.uploadProfile(selectedImage);
    }
//    await currentUser.uploadStudentCard(file);
    currentUser = await User().getCurrentuser(googleUser.id);
    await httpClass.getNewHeader();
    initsocket();
    Navigator.pushReplacement(context,MaterialPageRoute(
        builder : (context) => HomeNavigation()));
  }
}

