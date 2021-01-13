import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class CardTextField extends StatefulWidget {
  final String labelText;
  final String initValue;
  final TextInputType type;
  final List<TextInputFormatter> inputFormat;
  final bool isPhoneValidator;
  final bool isEmailValidator;
  final bool isFromVerification;
  final bool isStudentEmail;
  final Function onChanged;
  final int minLines;
  final int maxLines;
  final bool notNull;

  const CardTextField({Key key, this.labelText, this.initValue, @required this.onChanged, this.type, this.notNull, this.inputFormat, this.isPhoneValidator, this.minLines, this.maxLines, this.isEmailValidator, this.isFromVerification, this.isStudentEmail}) : super(key: key);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if(widget.labelText != null)
              Padding(
                padding: EdgeInsets.only(left: 16.0, top: 12.0),
                child: Text(widget.labelText, style: TextStyle(color: isEmpty ? Colors.red : Colors.black.withOpacity(0.6))),
              ),
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
                    maxLength: widget.isPhoneValidator != null ? (widget.isPhoneValidator ? 10 : null) : null,
                    minLines: widget.minLines,
                    maxLines: widget.maxLines,
                    onChanged: (text){
                      widget.onChanged((widget.isStudentEmail ?? false) ? "$text@cmu.ac.th" : text);
                    },
                    initialValue: widget.initValue ?? "",
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                      // hintText: "...",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      errorStyle: TextStyle(height: 0),
//                hintText: 'Source',
                    ),
                  ),
                ),
                if(widget.isStudentEmail ?? false)
                  Text("@cmu.ac.th", style: TextStyle(fontSize: 18.0)),
                if(widget.isStudentEmail ?? false)
                  SizedBox(width: 16.0)
              ],
            ),
          ],
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