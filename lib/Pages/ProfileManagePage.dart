import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_sign_in/widgets.dart';
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

  @override
  void initState() {
    super.initState();
    setEditDataDefault();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("Your Profile"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){
              setState(() {
                isEdit = true;
              });
            },
          )
        ],
      ),
      body: Container(
        // padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 16.0,
              ),
              // CircleAvatar(
              //   radius: 64.0,
              // ),
              SizedBox(
                width: 128.0,
                height: 128.0,
                child: GoogleUserCircleAvatar(
                  identity: googleUser,
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
              SizedBox(
                height: 16.0,
              ),
              Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: infoField(),
                ),
              )
            ],
          ),
        ),
      )
    );
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
    currentUser = await currentUser.getCurrentuser(currentUser.id);
    setState(() {});
  }

}