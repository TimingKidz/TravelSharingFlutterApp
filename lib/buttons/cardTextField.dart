import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardTextField extends StatefulWidget {
  final String labelText;
  final String initValue;
  final String hint;
  final TextInputType type;
  final List<TextInputFormatter> inputFormat;
  final bool isPhoneValidator;
  final bool isEmailValidator;
  final bool isFromVerification;
  final bool isStudentEmail;
  final Function onChanged;
  final int minLines;
  final int maxLines;
  final int maxLength;
  final bool notNull;

  const CardTextField({Key key, this.labelText, this.initValue, @required this.onChanged, this.type, this.notNull, this.inputFormat, this.isPhoneValidator, this.minLines, this.maxLines, this.isEmailValidator, this.isFromVerification, this.isStudentEmail, this.maxLength, this.hint}) : super(key: key);
  CardTextFieldState createState() => CardTextFieldState();
}

class CardTextFieldState extends State<CardTextField> {
  bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: (widget.isFromVerification ?? false) ? 0.0 : null,
        margin: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: (widget.isFromVerification ?? false)
              ? BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0
          )
              : BorderSide.none
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if(widget.labelText != null)
                Text(widget.labelText, style: TextStyle(color: isEmpty ? Colors.red : Colors.black.withOpacity(0.6))),
              if(widget.labelText != null)
                SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      validator: (val){
                        String result;
                        if(widget.notNull ?? false) result = validateNull(val);
                        if(widget.isPhoneValidator ?? false) result = validatePhone(val);
                        else if(widget.isEmailValidator ?? false) result = validateEmail(val);

                        if(result == null){
                          setState(() {
                            isEmpty = false;
                          });
                          return null;
                        }else{
                          setState(() {
                            isEmpty = true;
                          });
                          return "";
                        }
                      },
                      inputFormatters: widget.inputFormat,
                      keyboardType: widget.type,
                      maxLength: widget.maxLength,
                      minLines: widget.minLines,
                      maxLines: widget.maxLines,
                      onChanged: (text){
                        widget.onChanged((widget.isStudentEmail ?? false) ? "$text@cmu.ac.th" : text);
                      },
                      initialValue: widget.initValue ?? "",
                      decoration: InputDecoration(
                        // border: InputBorder.none,
                        counterText: "",
                        hintText: widget.hint ?? "",
                        contentPadding: EdgeInsets.only(bottom: 4.0),
                        isDense: true,
                        errorStyle: TextStyle(height: 0),
//                hintText: 'Source',
                      ),
                    ),
                  ),
                  if(widget.isStudentEmail ?? false)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("@cmu.ac.th", style: TextStyle(fontSize: 18.0)),
                    ),
                ],
              ),
            ],
          ),
        )
    );
  }

  String validateNull(String value) {
    if(value.isEmpty){
      return "";
    }else{
      return null;
    }
  }

  String validatePhone(String value) {
    if(value.length != 10){
      return "";
    }else{
      return null;
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null)
      return "Invalid email.";
    else
      return null;
  }

}