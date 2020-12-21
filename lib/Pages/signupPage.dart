import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/homeNavigation.dart';
import 'package:travel_sharing/buttons/borderTextField.dart';
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
              padding: EdgeInsets.all(16.0),
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
                      child: Icon(Icons.arrow_forward),
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
      SizedBox(
        width: 96.0,
        height: 96.0,
//                    add photo
//                    child: GoogleUserCircleAvatar(
//                      identity: googleUser,
//                    ),
      ),
      SizedBox(height: 8.0),
      Text(googleUser.id),
      SizedBox(height: 8.0),
      CardTextField(
        notNull: true,
        initValue: googleUser.displayName,
        labelText: "Full Name",
        onChanged: (data) => userData.name = data,
      ),
      SizedBox(height: 8.0),
      CardTextField(
        notNull: true,
        labelText: "Gender",
        onChanged: (data) => userData.gender = data,
      ),
      SizedBox(height: 8.0),
      CardTextField(
        notNull: true,
        labelText: "Faculty",
        onChanged: (data) => userData.faculty = data,
      ),
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
    currentUser = await currentUser.getCurrentuser(googleUser.id);
    initsocket();
    Navigator.pushReplacement(context,MaterialPageRoute(
        builder : (context) => HomeNavigation()));
  }
}

