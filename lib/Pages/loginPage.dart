import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/UI/NotificationBarSettings.dart';
import 'package:travel_sharing/main.dart';
import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:socket_io_client/socket_io_client.dart' as IO;


class LoginPage extends StatefulWidget {
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      googleUser = account;
    });
    googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(child: buildBody())
    );
  }

  Widget buildBody () {
    navigationBarColorPrimary(context);
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("assets/icons/TACtivity.png"), width: MediaQuery.of(context).size.width * 0.8),
          SizedBox(height: 120.0),
          if(isLoading)
            CircularProgressIndicator(),
          if(!isLoading)
          Container(
            width: 300.0,
            child: RaisedButton(
              highlightElevation: 0.0,
              padding: EdgeInsets.all(16.0),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
//              side: BorderSide(color: Colors.grey.shade200, width: 4.0)
              ),
              child: Row(
                children: <Widget>[
                  Image(image: AssetImage("assets/icons/google_logo.png"), height: 18.0),
                  SizedBox(width: 24.0),
                  Text('SIGN IN WITH GOOGLE', style: TextStyle(color: Colors.black54, fontSize: 14.0, fontFamily: 'Roboto'))
                ],
              ),
              onPressed: _handleSignIn,
            ),
          )
        ],
      ),
    );
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

  Future<void> _handleSignIn() async {
    try{
      googleUser = await googleSignIn.signIn();
      if(googleUser != null){
        setState(() => isLoading = true);
        GoogleSignInAuthentication Auth = await googleUser.authentication;
        u.GoogleAuthCredential a =  u.GoogleAuthProvider.credential(
          accessToken: Auth.accessToken,
          idToken: Auth.idToken,
        );
        firebaseAuth = await u.FirebaseAuth.instance.signInWithCredential(a);
        await httpClass.getNewHeader();
        currentUser = await User().getCurrentuser(googleUser.id);
        if (currentUser != null){
          if(currentUser.isVerify){
            if(await currentUser.amiOnline()){
              googleUser = await googleSignIn.signOut();
              unPopDialog(
                this.context,
                'Accept',
                Text("You already online with other device."),
                <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () async {
                      Navigator.pushReplacementNamed(context,"/login");
                    },
                  ),
                ],
              );
            }else {
              String tokenID = await firebaseMessaging.getToken();
//          currentUser =  await User().getCurrentuser(googleUser.id);
              await currentUser.updateToken(tokenID);
              if( socket != null ){
                socket.io.options['extraHeaders'] = {'uid': currentUser.uid,'auth' : httpClass.header['auth']};
              }
              initsocket();
              navigationBarColorWhite();
              Navigator.pushReplacementNamed(context,"/homeNavigation");
            }
          }else{
            Navigator.pushReplacementNamed(context,"/VerificationPage");
          }
        }else{
          navigationBarColorWhite();
          Navigator.pushReplacementNamed(context,"/SignUp");
        }
      }
    }catch(error){
      print(error);
    }
  }
}