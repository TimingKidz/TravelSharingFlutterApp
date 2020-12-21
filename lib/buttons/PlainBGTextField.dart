import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlainBGTextField extends StatefulWidget {
  final String labelText;
  final String initValue;
  final TextInputType type;
  final Function onChanged;

  const PlainBGTextField({Key key, this.labelText, this.initValue, this.type, this.onChanged}) : super(key: key);

  @override
  _PlainBGTextFieldState createState() => _PlainBGTextFieldState();
}

class _PlainBGTextFieldState extends State<PlainBGTextField> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Theme.of(context).canvasColor,
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.labelText, style: TextStyle(color: Colors.black.withOpacity(0.6))),
            TextFormField(
              keyboardType: widget.type,
              onChanged: (text){
                widget.onChanged(text);
              },
              initialValue: widget.initValue ?? "",
              decoration: InputDecoration(
                border: InputBorder.none,
//                hintText: 'Source',
              ),
            ),
          ],
        )
      ),
    );
  }
}
