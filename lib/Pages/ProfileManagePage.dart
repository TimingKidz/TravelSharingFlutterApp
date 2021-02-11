import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/DropdownVar.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/cardDatePicker.dart';
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
  final _formKey = GlobalKey<FormState>();

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RatingBarIndicator(
                                rating: currentUser.reviewSummary.amount == 0 ? 0.0: currentUser.reviewSummary.totalscore/currentUser.reviewSummary.amount,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 30.0,
                                direction: Axis.horizontal,
                              ),
                              SizedBox(width: 4.0),
                              Text(currentUser.reviewSummary.amount == 0 ? "0.0": (currentUser.reviewSummary.totalscore/currentUser.reviewSummary.amount).toStringAsPrecision(2), style: TextStyle(fontSize: 16.0, color: Colors.white)),
                              SizedBox(width: 4.0),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(color: Colors.white, width: 0.5)
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.people, size: 14.0, color: Colors.white),
                                    SizedBox(width: 2.0),
                                    Text(currentUser.reviewSummary.amount.toString(), style: TextStyle(fontSize: 14.0, color: Colors.white)),
                                    SizedBox(width: 1.0),
                                  ],
                                ),
                              ),
                            ],
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
            child: Form(
              key: _formKey,
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
            toolbarTitle: AppLocalizations.instance.text("cropimg"),
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: AppLocalizations.instance.text("cropimg"),
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
          infoText: currentUser.mailcmu,
        ),
        CardTextField(
          labelText: AppLocalizations.instance.text("name"),
          initValue: currentUser.name,
          onChanged: (val) => editUser.name = val,
        ),
        CardDatePicker(
          labelText: AppLocalizations.instance.text("birthday"),
          initDateTime: DateTime.parse(currentUser.birthDate).toLocal(),
          isBirthday: true,
          isJustDate: true,
          onDatePick: (time){
            editUser.birthDate = time;
          },
        ),
        CardDropdown(
          initData: currentUser.faculty,
          listItems: DropdownVar().facultyList,
          labelText: AppLocalizations.instance.text("faculty"),
          dropdownTileBuild: (value) {
            return Text(value);
          },
          onChanged: (data) => editUser.faculty = data,
        ),
        CardDropdown(
          initData: currentUser.gender,
          listItems: DropdownVar().genderList,
          labelText: AppLocalizations.instance.text("gender"),
          dropdownTileBuild: (value) {
            return Text(DropdownVar().genderLangMap(value));
          },
          onChanged: (val) => editUser.gender = val,
        ),
        CardTextField(
          labelText: AppLocalizations.instance.text("phone"),
          maxLength: 10,
          isPhoneValidator: true,
          inputFormat: [FilteringTextInputFormatter.digitsOnly],
          initValue: currentUser.phone,
          onChanged: (val) => editUser.phone = val,
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
                if (_formKey.currentState.validate()) {
                  print(editUser.toJson());
                  isEdit = false;
                  await editUser.editUser();
                  getData();
                  selectedImage = null;
                }
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
          infoText: currentUser.mailcmu,
        ),
        CardInformation(
          labelText: AppLocalizations.instance.text("name"),
          infoText: currentUser.name,
        ),
        CardInformation(
          labelText: AppLocalizations.instance.text("birthday"),
          infoText: DateManage().datetimeFormat("date", currentUser.birthDate),
        ),
        CardInformation(
          labelText: AppLocalizations.instance.text("faculty"),
          infoText: currentUser.faculty,
        ),
        CardInformation(
          labelText: AppLocalizations.instance.text("gender"),
          infoText: DropdownVar().genderLangMap(currentUser.gender),
        ),
        CardInformation(
          labelText: AppLocalizations.instance.text("phone"),
          infoText: currentUser.phone,
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