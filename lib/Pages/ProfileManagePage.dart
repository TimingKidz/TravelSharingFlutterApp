import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/buttons/cardInformation.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/localization.dart';

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
                              ? Material(
                            shape: CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.grey,
                            child: InkWell(
                                onTap: (){
                                  getImage();
                                },
                                child: ClipOval(
                                  child: selectedImage != null
                                      ? Ink.image(
                                    image: Image.file(selectedImage).image,
                                    width: 128.0,
                                    height: 128.0,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                      width: 128.0,
                                      height: 128.0,
                                      child: currentUser.imgpath != null
                                          ? Ink.image(image: Image.network(url).image)
                                          : Icon(Icons.add_a_photo, color: Colors.white)
                                  ),
                                )
                            ),
                          )
                              :  CircleAvatar(
                            radius: 64,
                            backgroundColor: Colors.grey,
                            child: ClipOval(
                              child: currentUser.imgpath != null
                                  ? Image.network(url)
                                  : Container(
                                width: 128.0,
                                height: 128.0,
                                child: Icon(Icons.person, color: Colors.white, size: 64),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          RatingBarIndicator(
                            rating: currentUser.reviewSummary.totalscore,
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
            child: ListView.separated(
              separatorBuilder: (context, _){
                return SizedBox(height: 8.0);
              },
              padding: EdgeInsets.all(8.0),
              physics: BouncingScrollPhysics(),
              itemCount: infoField().length,
              itemBuilder: (context, i){
                return infoField()[i];
              },
            ),
          )
        ],
      ),
    );
  }



  PickedFile image;

  Future getImage() async {
    image = await ImagePicker().getImage(source: ImageSource.gallery);
    if(image != null)
      await _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          rectX: 1,
          rectY: 1
        ));
    if (croppedFile != null) {
      selectedImage = croppedFile;
      setState(() {});
    }
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
          labelText: AppLocalizations.instance.text("email"),
          infoText: currentUser.email,
        ),
        CardTextField(
          labelText: AppLocalizations.instance.text("name"),
          initValue: currentUser.name,
          onChanged: (val) => editUser.name = val,
        ),
        CardTextField(
          labelText: AppLocalizations.instance.text("faculty"),
          initValue: currentUser.faculty,
          onChanged: (val) => editUser.faculty = val,
        ),
        CardTextField(
          labelText: AppLocalizations.instance.text("gender"),
          initValue: currentUser.gender,
          onChanged: (val) => editUser.gender = val,
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 64.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              color: Colors.green,
              child: Text(AppLocalizations.instance.text("ok"), style: TextStyle(color: Colors.white)),
              onPressed: () async {
                print(editUser.toJson());
                isEdit = false;
                await editUser.editUser();
                getData();
                selectedImage = null;
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
              borderRadius: BorderRadius.circular(20.0),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  child: Text(AppLocalizations.instance.text("cancel")),
                ),
                onTap: () {
                  setState(() {
                    setEditDataDefault();
                    isEdit = false;
                    selectedImage = null;
                  });
                },
              ),
            ),
          ],
        ),
      ];
    }else{
      return [
        CardInformation(
          labelText: AppLocalizations.instance.text("email"),
          infoText: currentUser.email,
        ),
        CardInformation(
          labelText: AppLocalizations.instance.text("name"),
          infoText: currentUser.name,
        ),
        CardInformation(
          labelText: "วันเกิด",
          infoText: DateManage().datetimeFormat("date", currentUser.birthDate),
        ),
        CardInformation(
          labelText: AppLocalizations.instance.text("faculty"),
          infoText: currentUser.faculty,
        ),
        CardInformation(
          labelText: AppLocalizations.instance.text("gender"),
          infoText: currentUser.gender,
        ),
        CardInformation(
          labelText: "เบอร์โทร",
          infoText: "0903310276",
        ),
      ];
    }
  }

  Future<void> getData() async {
    if( selectedImage != null){
      print("upload");
      await currentUser.uploadProfile(selectedImage);
      if(currentUser.imgpath != null){
        NetworkImage provider = NetworkImage(url);
        await provider.evict();
      }
    }
    print("upload 555");
    currentUser = await currentUser.getCurrentuser(currentUser.id);
    url = "${httpClass.API_IP}${currentUser.imgpath}";
    setState(() {});
  }

}