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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isEdit ? "Your Email" : "Student Verification", style: Theme.of(context).textTheme.headline4),
            SizedBox(height: 24),
            if(isEdit)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (text){
                      email = text;
                    },
                  ),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Wrong email?"),
          TextButton(
            onPressed: (){
              setState(() {
                isEdit = true;
              });
            },
            style: TextButton.styleFrom(
                primary: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                ),
                padding: EdgeInsets.all(0.0)
            ),
            child: Text("EDIT"),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Didn't receive the code?"),
          TextButton(
            onPressed: (){

            },
            style: TextButton.styleFrom(
                primary: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                ),
                padding: EdgeInsets.all(0.0)
            ),
            child: Text("RESEND"),
          )
        ],
      ),
    ];
  }
}
