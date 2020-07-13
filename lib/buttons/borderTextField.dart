import 'package:flutter/material.dart';

class BorderTextField extends StatefulWidget {
  final String labelText;
  final Color focusColor;
  final TextEditingController controller;
  final Icon suffixIcon;
  final Function onSuffixIconPress;
  final TextInputType inputType;
  final int maxLines;
  final bool notNull;

  BorderTextField({
    @required this.labelText,
    @required this.focusColor,
    this.controller,
    this.suffixIcon,
    this.onSuffixIconPress,
    this.inputType,
    this.maxLines,
    @required this.notNull
  });

  @override
  BorderTextFieldState createState() => BorderTextFieldState();
}

class BorderTextFieldState extends State<BorderTextField> {
  bool isFocus = false;
  bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0, right: 0.0, top: 12.0, bottom: 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: isEmpty ? Colors.red : (isFocus ? widget.focusColor : Colors.grey.shade500),
          style: BorderStyle.solid, width: 2.0
        ),
      ),
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.labelText,
                style: TextStyle(
                  color: isEmpty ? Colors.red : (isFocus ? widget.focusColor : Colors.grey.shade500),
                  fontWeight: FontWeight.bold
                )
              )
          ),
          FocusScope(
            child: Focus(
              onFocusChange: (focus) {
                setState(() {
                  isFocus = focus;
                });
              },
              child: TextFormField(
                validator: (value) {
                  if(widget.notNull){
                    if (value.isEmpty) {
                      setState(() {
                        isEmpty = true;
                      });
                      return '';
                    }
                    return null;
                  }
                  return null;
                },
                maxLines: widget.maxLines,
                controller: widget.controller,
                cursorColor: widget.focusColor,
                decoration: decoration(),
                keyboardType: widget.inputType,
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration decoration() {
    if(widget.suffixIcon == null){
      return InputDecoration(
        border: InputBorder.none,
        errorStyle: TextStyle(height: 0),
      );
    }else{
      return InputDecoration(
        border: InputBorder.none,
        suffixIcon: IconButton(
            icon: widget.suffixIcon,
            color: isFocus ? widget.focusColor : Colors.grey.shade500,
            onPressed: widget.onSuffixIconPress
        ),
      );
    }
  }
}