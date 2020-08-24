import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:intl/intl.dart';

class CardDatePicker extends StatefulWidget {
  final String labelText;
  final Function onDatePick;

  CardDatePicker({
    this.labelText,
    this.onDatePick
  });

  @override
  CardDatePickerState createState() => CardDatePickerState();

}

class CardDatePickerState extends State<CardDatePicker> {
  DateTime updatedDate = DateTime.now();
  var dateText = TextEditingController();
  var timeText = TextEditingController();

  @override
  void initState() {
    dateText.text = dateShow();
    timeText.text = '${DateFormat('HH:mm').format(updatedDate)}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // DatePickerUI
        Expanded(
          child: Card(
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
                    controller: dateText,
                    readOnly: true,
                    onTap: () async {
                      DateTime datePick = await callDatePicker();
                      setState(() {
                        if(datePick != null) updatedDate = datePick;
                        dateText.text = dateShow();
                        widget.onDatePick(updatedDate.toIso8601String());
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 15),
//                hintText: 'Source',
                    ),
                  ),
                ],
              )
          ),
        ),

        //TimePickerUI
        Expanded(
          child: Card(
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
                    child: Text('เวลา', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                  ),
                  TextFormField(
                    controller: timeText,
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay timePick = await callTimePicker();
                      setState(() {
                        if(timePick != null) {
                          var updateTime = DateTime(
                            updatedDate.year, updatedDate.month, updatedDate.day, timePick.hour, timePick.minute
                          );
                          updatedDate = updateTime;
                        }
                        timeText.text = '${DateFormat('HH:mm น.').format(updatedDate)}';
                        widget.onDatePick(updatedDate.toIso8601String());
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 15),
//                hintText: 'Source',
                    ),
                  ),
                ],
              )
          ),
        )
      ],
    );
  }

  String dateShow() {
    var now = DateTime.now();
    var nowDate = DateTime(now.year, now.month, now.day);
    String textShow;
    if(nowDate.difference(updatedDate).inDays.floor() == 0){
//      textShow = 'Today';
      textShow = 'วันนี้';
    }else if(nowDate.difference(updatedDate).inDays.floor() == -1) {
//      textShow = 'Tomorrow';
      textShow = 'พรุ่งนี้';
    }else{
      textShow = '${DateFormat('d MMM yyyy').format(updatedDate)}';
    }
    return textShow;
  }

  Future<DateTime> callDatePicker() async {
    var order = await getDate();
    return order;
  }

  Future<DateTime> getDate() {
    return showDatePicker(
      context: context,
      initialDate: updatedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(primarySwatch: Theme.of(context).colorScheme.primary),
          child: child,
        );
      },
    );
  }

  Future<TimeOfDay> callTimePicker() async {
    var order = await getTime();
    return order;
  }

  Future<TimeOfDay> getTime() {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(updatedDate),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(primarySwatch: Theme.of(context).colorScheme.primary),
          child: child,
        );
      },
    );
  }
}