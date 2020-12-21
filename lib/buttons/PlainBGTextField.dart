import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlainBGTextField extends StatefulWidget {
  final String labelText;
  final String initValue;
  final TextInputType type;
  final Function onChanged;
  final bool notNull;

  const PlainBGTextField({Key key, this.labelText, this.initValue, this.type, this.onChanged, @required this.notNull}) : super(key: key);

  @override
  _PlainBGTextFieldState createState() => _PlainBGTextFieldState();
}

class _PlainBGTextFieldState extends State<PlainBGTextField> {
  bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Theme.of(context).canvasColor,
        decoration: BoxDecoration(
          color: isEmpty ? Colors.red.withOpacity(0.1) : Theme.of(context).canvasColor,
          // border: Border.all(
          //   color: isEmpty ? Colors.red : Theme.of(context).canvasColor,
          //   style: BorderStyle.solid,
          //   width: 1.0
          // ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.labelText, style: TextStyle(color: isEmpty ? Colors.red : Colors.black.withOpacity(0.6))),
            TextFormField(
              validator: (val){
                if(widget.notNull){
                  if(val.isEmpty){
                    setState(() {
                      isEmpty = true;
                    });
                    return '';
                  }else{
                    setState(() {
                      isEmpty = false;
                    });
                    return null;
                  }
                }
                return null;
              },
              keyboardType: widget.type,
              onChanged: (text){
                widget.onChanged(text);
              },
              initialValue: widget.initValue ?? "",
              decoration: InputDecoration(
                border: InputBorder.none,
                errorStyle: TextStyle(height: 0),
//                hintText: 'Source',
              ),
            ),
          ],
        )
    );
  }
}
