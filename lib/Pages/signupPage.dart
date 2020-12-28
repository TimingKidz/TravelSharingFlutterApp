import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';
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

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
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
    return [
      SizedBox(height: 8.0),
      CircleAvatar(
        radius: 64,
        // backgroundColor: Colors.transparent,
        child: InkWell(
          onTap: (){

          },
          child: ClipOval(
            child: Image.network(
              "${HTTP().API_IP}/images/profile.jpg",
            ),
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
      CardDropdown(
        listItems: <String>[
          "Male",
          "Female",
          "LGBTQ"
        ],
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
        listItems: <String>[
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
        ],
        labelText: "Faculty",
        onChanged: (data) => userData.faculty = data,
      ),
      CardTextField(
        notNull: true,
        labelText: "Phone",
        isPhoneValidator: true,
        inputFormat: <TextInputFormatter>[
          // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), //1.20 or newer versions
          WhitelistingTextInputFormatter.digitsOnly
        ],
        type: TextInputType.phone,
        onChanged: (val) => print(val),
      )
    ];
  }

  initsocket(){
    socket = IO.io(HTTP().API_IP,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .setExtraHeaders({'uid': currentUser.uid}) // optional // disable auto-connection
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
    initsocket();
    Navigator.pushReplacement(context,MaterialPageRoute(
        builder : (context) => HomeNavigation()));
  }
}

