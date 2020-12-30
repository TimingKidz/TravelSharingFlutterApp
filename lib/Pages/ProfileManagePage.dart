import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/buttons/cardInformation.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';

import '../main.dart';

class ProfileManagePage extends StatefulWidget {
  ProfileManagePageState createState() => ProfileManagePageState();
}

class ProfileManagePageState extends State<ProfileManagePage> {
  User editUser;
  bool isEdit = false;
  File selectedImage;
  String url = "${httpClass.API_IP}${currentUser.imgpath}";

  @override
  void initState() {
    super.initState();
    _pageConfig();
    setEditDataDefault();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Card(
            elevation: 2.0,
            margin: EdgeInsets.all(0.0),
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)
                )
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 16.0,
                          ),
                          // CircleAvatar(
                          //   radius: 64.0,
                          // ),
                          isEdit
                          ? CircleAvatar(
                                radius: 64,
//                                 backgroundColor: Colors.transparent,
                                child: InkWell(
                                  onTap: (){
                                    getImage();
                                  },
                                  child: ClipOval(
                                      child: selectedImage != null ? Image.file(selectedImage): currentUser.imgpath != null ? Image.network(url) : Container()
                                  ),
                                )
                            )
                          :  CircleAvatar(
                              radius: 64,
                              // backgroundColor: Colors.transparent,
                              child: ClipOval(
                                  child: currentUser.imgpath != null ? Image.network(url) : Container()
                              ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          RatingBarIndicator(
                            rating: 4.75,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 30.0,
                            direction: Axis.horizontal,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          iconSize: 26.0,
                          color: Colors.white,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: (){
                            setState(() {
                              isEdit = true;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                )
              ),
            ),
          ),
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: infoField(),
            ),
          )
        ],
      ),
    );
  }

  _pageConfig(){
    socket.off('onNewNotification');
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showNotification(message);
        }
    );
  }

  Future getImage() async {
    print("5555555");
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

  void setEditDataDefault(){
    editUser = new User(
      uid: currentUser.uid,
      name: currentUser.name,
      faculty: currentUser.faculty,
      gender: currentUser.gender
    );
  }

  List<Widget> infoField() {
    if(isEdit){
      return [
        CardInformation(
          labelText: "Email",
          infoText: currentUser.email,
        ),
        CardTextField(
          labelText: "Name",
          initValue: currentUser.name,
          onChanged: (val) => editUser.name = val,
        ),
        CardTextField(
          labelText: "Faculty",
          initValue: currentUser.faculty,
          onChanged: (val) => editUser.faculty = val,
        ),
        CardTextField(
          labelText: "Gender",
          initValue: currentUser.gender,
          onChanged: (val) => editUser.gender = val,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("cancel"),
              onPressed: (){
                setState(() {

                  setEditDataDefault();
                  isEdit = false;
                  selectedImage = null;
                });
              },
            ),
            FlatButton(
              child: Text("ok"),
              onPressed: () async {

                print(editUser.toJson());
                isEdit = false;
                await editUser.editUser();
                getData();
                selectedImage = null;
              },
            )
          ],
        ),
      ];
    }else{
      return [
        CardInformation(
          labelText: "Email",
          infoText: currentUser.email,
        ),
        CardInformation(
          labelText: "Name",
          infoText: currentUser.name,
        ),
        CardInformation(
          labelText: "Faculty",
          infoText: currentUser.faculty,
        ),
        CardInformation(
          labelText: "Gender",
          infoText: currentUser.gender,
        ),
      ];
    }
  }

  Future<void> getData() async {
    if( selectedImage != null){
      print("upload");
      await currentUser.uploadProfile(selectedImage);
      NetworkImage provider = NetworkImage(url);
      await provider.evict();
    }

    print("upload 555");
    currentUser = await currentUser.getCurrentuser(currentUser.id);
    setState(() {});
  }

}