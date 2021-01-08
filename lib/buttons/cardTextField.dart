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
  final Function onChanged;
  final bool notNull;

  const CardTextField({Key key, this.labelText, this.initValue, this.onChanged, this.type, @required this.notNull, this.inputFormat, this.isPhoneValidator}) : super(key: key);
  CardTextFieldState createState() => CardTextFieldState();
}

class CardTextFieldState extends State<CardTextField> {
  bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text(widget.labelText, style: TextStyle(color: isEmpty ? Colors.red : Colors.black.withOpacity(0.6))),
            ),
            TextFormField(
              validator: (val){
                if(widget.notNull){
                  if(val.isEmpty || ((widget.isPhoneValidator != null ? widget.isPhoneValidator : false) && val.length != 10)){
                    setState(() {
                      isEmpty = true;
                    });
                    return "";
                  }else{
                    setState(() {
                      isEmpty = false;
                    });
                    return null;
                  }
                }
                return null;
              },
              inputFormatters: widget.inputFormat,
              keyboardType: widget.type,
              maxLength: widget.isPhoneValidator != null ? (widget.isPhoneValidator ? 10 : null) : null,
              onChanged: (text){
                widget.onChanged(text);
              },
              initialValue: widget.initValue ?? "",
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: "",
                hintText: "...",
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                errorStyle: TextStyle(height: 0),
//                hintText: 'Source',
              ),
            ),
          ],
        )
    );
  }

}