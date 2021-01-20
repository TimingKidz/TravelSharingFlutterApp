import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:travel_sharing/Class/MailVerification.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/UI/NotificationBarSettings.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/main.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>{
  final _formKey = GlobalKey<FormState>();
  String currentText ="";
  bool isEdit = false;
  MailVerification mailVerification = new MailVerification();
  String email = "";
  StreamController<ErrorAnimationType> errorController;
  TextEditingController textEditingController =new TextEditingController();
  bool isLoading = false;
  bool isResend = false;

  @override
  void dispose() {
    // TODO: implement dispose
    notificationBarIconLight();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = currentUser.mailcmu;
    errorController =  StreamController<ErrorAnimationType>();
  }
  @override
  Widget build(BuildContext context) {
    notificationBarIconDark();
    return WillPopScope(
      onWillPop: () async {
        if(isEdit){
          setState(() {
            isEdit = !isEdit;
            email = currentUser.mailcmu;
            textEditingController =new TextEditingController();
            errorController =  StreamController<ErrorAnimationType>();
            mailVerification = new MailVerification();
          });
          return false;
        }else{
            await googleSignIn.disconnect();
            Navigator.pushReplacementNamed(context,"/login");
            return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isEdit ? "Your Email" : "Student Verification", style: Theme.of(context).textTheme.headline4),
                  SizedBox(height: 24),
                  if(isEdit)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Form(
                        key: _formKey,
                        child: CardTextField(
                          notNull: true,
                          maxLines: 1,
                          minLines: 1,
                          isFromVerification: true,
                          isStudentEmail: true,
                          onChanged: (text){
                            email = text;
                          },
                        )
                      ),
                    ),
                  if(!isEdit)
                    for(Widget w in verificationPage())
                      w,
                  SizedBox(height: 40),
                  if(isLoading)
                    CircularProgressIndicator(),
                  if(!isLoading)
                  RaisedButton(
                    elevation: 2,
                    highlightElevation: 2,
                    padding: EdgeInsets.all(16.0),
                    textColor: Colors.white,
                    onPressed: (){
                      isLoading = true;
                      setState(() {});
                      if(isEdit && _formKey.currentState.validate()){
                        _changeMail();
                      } else if(!isEdit){
//                        isLoading = true;
                        _Verify();
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: Colors.green,
                    child: Text(isEdit ? "RESEND OTP" : "VERIFY"),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> verificationPage(){
    return [
      RichText(
        text: TextSpan(
            children: [
              TextSpan(
                  text: "Enter the code sent to ",
                  style: Theme.of(context).textTheme.bodyText2
              ),
              TextSpan(
                  text: email,
                  style: Theme.of(context).textTheme.bodyText1
              ),
            ]
        ),
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Wrong email? "),
          GestureDetector(
            onTap: (){
              setState(() {
                isEdit = true;
              });
            },
            child: Text(
              "EDIT",
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
      SizedBox(height: 96),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 8.0),
        child: PinCodeTextField(
          appContext: context,
          keyboardType: TextInputType.number,
          length: 4,
          obscureText: false,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
            activeColor: Theme.of(context).accentColor,
            inactiveFillColor: Colors.white,
            inactiveColor: Theme.of(context).primaryColor,
            selectedColor: Theme.of(context).primaryColor,
            selectedFillColor: Theme.of(context).primaryColor,
          ),
          animationDuration: Duration(milliseconds: 300),
          enableActiveFill: true,
           controller: textEditingController,
           errorAnimationController: errorController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onCompleted: (v) {
            print("Completed");
          },
//          onChanged: (value) {
//            print(value);
//            setState(() {
//              currentText = value;
//            });
//          },
          beforeTextPaste: (text) {
            print("Allowing to paste $text");
            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
            //but you can show anything you want here, like your pop up saying wrong paste format or etc
            return true;
          },
        ),
      ),
      SizedBox(height: 16.0),
      if(mailVerification.count != null)
      Text("Remaining ${mailVerification.count} " + (mailVerification.count > 1 ? "times":"time")),
      SizedBox(height: 16.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Didn't receive the code? "),
          GestureDetector(
            onTap: isResend ? null : (){
              setState(() {isResend = true;});
              _resend();
            },
            child: Text(
              "RESEND",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
    ];
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
    socket.on("tooManyOnline",(value) async {
      socket = socket.disconnect();
      socket.destroy();
      socket.dispose();
      googleUser = await googleSignIn.disconnect();
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
    });
  }

  _resend() async {
    MailVerification().resend(currentUser).then((value){
      if(value){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("New OTP has been send.")));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not resend. Please try again.")));
      }
      isResend = false;
    });
  }

  _changeMail() async {
    MailVerification().changeMail(email, currentUser).then((value){
      if(value == "Succesful"){
        currentUser.mailcmu = email;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("New OTP has been send to your new mail.")));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
      }
      isLoading = false;
      Navigator.of(context).maybePop();
    });
  }
  
  _Verify() async {
      if(textEditingController.text != ""){
        MailVerification().verify(textEditingController.text,currentUser).then((value) async {
          if(value != null){
            print('${value.message}  ${value.count}');
            mailVerification = value;
            if(value.message == "succesful" ){
              currentUser = await User().getCurrentuser(googleUser.id);
              if(currentUser != null){
                if(await currentUser.amiOnline()){
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
                }else{
                  await httpClass.getNewHeader();
                  if( socket != null ){
                    socket.io.options['extraHeaders'] = {'uid': currentUser.uid,'auth' : httpClass.header['auth']};
                  }
                  initsocket();
                  Navigator.pushReplacementNamed(context,"/homeNavigation");
                }
              }else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not login.")));
                Navigator.pushReplacementNamed(context,"/login");
              }
            }else if(value.message == "resend"){
              errorController.add(ErrorAnimationType.shake);
              textEditingController.clear();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The verification code has been resend.")));
            }else if(value.message == "wrong" ) {
              errorController.add(ErrorAnimationType.shake);
              textEditingController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Wrong verification code. !!")));
            }else if( value.message == "expired" ){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Code has been expired. Press resend to send new OTP!!")));
            }else{
              errorController.add(ErrorAnimationType.shake);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The verification code has been expired.")));
            }
          }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not send verification code.")));
          }
        });
      }else{
        errorController.add(ErrorAnimationType.shake);
      }
      setState(() {  isLoading = false; });
  }
}
