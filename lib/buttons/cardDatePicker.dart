import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_sharing/Class/DateManage.dart';

class CardDatePicker extends StatefulWidget {
  final String labelText;
  final Function onDatePick;
  final DateTime initDateTime;
  final bool isJustDate;
  final bool isBirthday;

  CardDatePicker({
    this.labelText,
    this.onDatePick,
    this.isJustDate, this.isBirthday, this.initDateTime
  });

  @override
  CardDatePickerState createState() => CardDatePickerState();

}

class CardDatePickerState extends State<CardDatePicker> with TickerProviderStateMixin {
  DateTime updatedDate;
  var dateText = TextEditingController();
  var timeText = TextEditingController();
  bool isBirthday;
  AnimationController _controller;

  @override
  void initState() {
    updatedDate = widget.initDateTime ?? DateTime.now();
    dateText.text = dateShow();
    timeText.text = '${DateFormat('HH:mm').format(updatedDate)}';
    isBirthday = widget.isBirthday == null ? false : widget.isBirthday;
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 75),
      vsync: this,
    )..addStatusListener((AnimationStatus status) {
      setState(() {
        // setState needs to be called to trigger a rebuild because
        // the 'HIDE FAB'/'SHOW FAB' button needs to be updated based
        // the latest value of [_controller.status].
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // DatePickerUI
        Expanded(
          child: Card(
              margin: EdgeInsets.all(0.0),
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
                      _controller.forward();
                      DateTime datePick = await callDatePicker();
                      _controller.reverse();
                      setState(() {
                        if(datePick != null){
                          var pickDate = DateTime(
                              datePick.year, datePick.month, datePick.day, updatedDate.hour, updatedDate.minute
                          );
                          updatedDate = pickDate;
                        }
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
        if(widget.isJustDate != null ? !widget.isJustDate : true)
          SizedBox(width: 8.0),
        if(widget.isJustDate != null ? !widget.isJustDate : true)
          Expanded(
            child: Card(
                margin: EdgeInsets.all(0.0),
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
                        _controller.forward();
                        TimeOfDay timePick = await callTimePicker();
                        _controller.reverse();
                        setState(() {
                          if(timePick != null) {
                            var updateTime = DateTime(
                              updatedDate.year, updatedDate.month, updatedDate.day, timePick.hour, timePick.minute
                            );
                            updatedDate = updateTime;
                          }
                          timeText.text = '${DateFormat('HH:mm').format(updatedDate)}';
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
      textShow = DateManage().datetimeFormat("picker", updatedDate.toString());
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
      firstDate: isBirthday ? DateTime(DateTime.now().year - 30) : DateTime.now(),
      lastDate: isBirthday ? DateTime.now() : DateTime(DateTime.now().year + 1),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(primarySwatch: Theme.of(context).colorScheme.primary),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return FadeScaleTransition(
                animation: _controller,
                child: child,
              );
            },
            child: child,
          ),
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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return FadeScaleTransition(
                animation: _controller,
                child: child,
              );
            },
            child: child,
          ),
        );
      },
    );
  }
}