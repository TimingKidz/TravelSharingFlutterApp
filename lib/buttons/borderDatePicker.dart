import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BorderDatePicker extends StatefulWidget {
  final String labelText;
  final Function onDatePick;

  BorderDatePicker({
    this.labelText,
    this.onDatePick
  });

  @override
  BorderDatePickerState createState() => BorderDatePickerState();

}

class BorderDatePickerState extends State<BorderDatePicker> {
  DateTime updatedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      padding: EdgeInsets.all(12.0),
      borderSide: BorderSide(color: Colors.grey.shade500, style: BorderStyle.solid, width: 2.0),
      highlightedBorderColor: Colors.orange,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)
      ),
      onPressed: () async {
        DateTime datePick = await callDatePicker();
        setState(() {
          if(datePick != null) updatedDate = datePick;
          widget.onDatePick(updatedDate);
        });
      },
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.labelText, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(top: 13.0, bottom: 6.0),
                child: dateShow(),
              )
          ),
        ],
      ),
    );
  }

  Text dateShow() {
    String textShow;
    debugPrint('Day Difference: ${DateTime.now().difference(updatedDate).inDays.floor().toString()}');
    if(DateTime.now().difference(updatedDate).inDays.floor() == 0){
      textShow = 'Today';
    }else if(DateTime.now().difference(updatedDate).inDays.floor() == 1) {
      textShow = 'Yesterday';
    }else{
      textShow = '${updatedDate.day}/${updatedDate.month}/${updatedDate.year}';
    }
    return Text(
        textShow,
        style: TextStyle(fontSize: 16.0)
    );
  }

  Future<DateTime> callDatePicker() async {
    var order = await getDate();
    return order;
  }

  Future<DateTime> getDate() {
    return showDatePicker(
      context: context,
      initialDate: updatedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(primarySwatch: Colors.orange),
          child: child,
        );
      },
    );
  }
}