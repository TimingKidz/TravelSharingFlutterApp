import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_sharing/Class/DropdownVar.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/Pages/loginPage.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/borderTextField.dart';
import 'package:travel_sharing/buttons/cardDatePicker.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SignUpPage extends StatefulWidget {
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  // User user = new User(name: googleUser.displayName,email: googleUser.email,id: googleUser.id,token: await firebaseMessaging.getToken());
  User userData = new User(name: googleUser.displayName,email: googleUser.email,id: googleUser.id);
  final _formKey = GlobalKey<FormState>();
  File selectedImage;
  bool isPress = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    userData.gender = DropdownVar().genderList.first;
    userData.faculty = DropdownVar().facultyList.first;
    userData.birthDate = DateTime.now().toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await googleSignIn.disconnect();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        Navigator.pushReplacementNamed(context,"/login");
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(8.0, MediaQuery.of(context).size.height * 0.32, 8.0, 8.0),
                physics: BouncingScrollPhysics(),
                children: fieldList(),
              ),
            ),
            // AppBar
            Wrap(
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
                    padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 24.0, right: 4.0),
                    child: SafeArea(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                tooltip: AppLocalizations.instance.text("back"),
                                iconSize: 26.0,
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                              ),
                              SizedBox(width: 16.0),
                              Text(
                                AppLocalizations.instance.text("SignUpTitle"),
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Material(
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
                                      child: Icon(Icons.add_a_photo, color: Colors.white),
                                    )
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              bottom: 16,
              right: 16,
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                    elevation: 2,
                    highlightElevation: 2,
                    icon: isPress ? SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(strokeWidth: 2,valueColor: AlwaysStoppedAnimation(Colors.black),),
                    ):Icon(Icons.check),
                    label: Text(isPress ? "Loading..." :"Finish"),
                    onPressed: isPress ? null : (){
                      if(_formKey.currentState.validate()) {
                        isPress = true;
                        setState(() { });
                        _Nextpage();
                      }
                    }
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> fieldList(){
    // TODO: Add missing field in User class
    return [
      CardTextField(
        notNull: true,
        initValue: googleUser.displayName,
        labelText: "Full Name",
        onChanged: (data) => userData.name = data,
      ),
      SizedBox(height: 8.0),
      CardTextField(
        notNull: true,
        isStudentEmail: true,
        maxLines: 1,
        labelText: "Student Email",
        onChanged: (data) => userData.mailcmu = data,
      ),
      SizedBox(height: 8.0),
      Row(
        children: [
          Expanded(
            child: CardDropdown(
              listItems: DropdownVar().genderList,
              labelText: "Gender",
              dropdownTileBuild: (value) {
                return Text(value);
              },
              onChanged: (data) => userData.gender = data,
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: CardDatePicker(
              labelText: "Birthday",
              isJustDate: true,
              isBirthday: true,
              onDatePick: (date){
                userData.birthDate = date.toString();
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 8.0),
      CardDropdown(
        listItems: DropdownVar().facultyList,
        labelText: "Faculty",
        dropdownTileBuild: (value) {
          return Text(value);
        },
        onChanged: (data) => userData.faculty = data,
      ),
      SizedBox(height: 8.0),
      CardTextField(
        notNull: true,
        labelText: "Phone",
        maxLength: 10,
        isPhoneValidator: true,
        inputFormat: [FilteringTextInputFormatter.digitsOnly],
        type: TextInputType.phone,
        onChanged: (val) => userData.phone = val,
      ),
      SizedBox(height: 72)
    ];
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

  _Nextpage() async {
    userData.mailcmu = userData.mailcmu.toLowerCase();
    userData.token = await firebaseMessaging.getToken();
    print(userData.toJson());
    String isSuccesful = await userData.Register();
    if( isSuccesful == "Succesful" ) {
      currentUser = await User().getCurrentuser(googleUser.id);
      if (selectedImage != null) {
        await currentUser.uploadProfile(selectedImage);
      }
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      Navigator.pushReplacementNamed(context, "/VerificationPage");
    }else{
      isPress = false;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isSuccesful)));
      setState(() { });
    }


  }
}

