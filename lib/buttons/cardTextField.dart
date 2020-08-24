import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardTextField extends StatefulWidget {
  final String labelText;
  final String initValue;
  final TextInputType type;
  final Function onChanged;

  const CardTextField({Key key, this.labelText, this.initValue, this.onChanged, this.type}) : super(key: key);
  CardTextFieldState createState() => CardTextFieldState();
}

class CardTextFieldState extends State<CardTextField> {
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text(widget.labelText, style: TextStyle(color: Colors.black.withOpacity(0.6))),
            ),
            TextFormField(
              keyboardType: widget.type,
              onChanged: (text){
                widget.onChanged(text);
              },
              initialValue: widget.initValue ?? "",
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 15),
//                hintText: 'Source',
              ),
            ),
          ],
        )
    );
  }

}