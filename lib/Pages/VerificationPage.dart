import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  String currentText;
  bool isEdit = false;
  String email = "thutgtz@gmail.com";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(isEdit){
          setState(() {
            isEdit = !isEdit;
          });
          return false;
        }else{
          return true;
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
                  RaisedButton(
                    elevation: 2,
                    highlightElevation: 2,
                    padding: EdgeInsets.all(16.0),
                    textColor: Colors.white,
                    onPressed: (){
                      if(isEdit && _formKey.currentState.validate()){
                        isEdit = !isEdit;
                      }
                      setState(() {});
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
          // errorAnimationController: errorController,
          onCompleted: (v) {
            print("Completed");
          },
          onChanged: (value) {
            print(value);
            setState(() {
              currentText = value;
            });
          },
          beforeTextPaste: (text) {
            print("Allowing to paste $text");
            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
            //but you can show anything you want here, like your pop up saying wrong paste format or etc
            return true;
          },
        ),
      ),
      SizedBox(height: 16.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Didn't receive the code? "),
          GestureDetector(
            onTap: (){
              setState(() {
                isEdit = true;
              });
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
}
