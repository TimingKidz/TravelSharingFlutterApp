import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

import '../main.dart';

class CardTileWithTap extends StatefulWidget {
  final Routes data;
  final IconData iconData;
  final Function onCardPressed;
  final bool isFeed;

  CardTileWithTap({
    this.data,
    this.iconData,
    this.onCardPressed,
    @required this.isFeed
  });


  @override
  CardTileWithTapState createState() => CardTileWithTapState();
}

class CardTileWithTapState extends State<CardTileWithTap> {
  BorderRadius cardBorder = BorderRadius.circular(20.0);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
          borderRadius: cardBorder
      ),
      child: FlatButton(
        padding: EdgeInsets.only(top: 0.0),
        shape: RoundedRectangleBorder(
            borderRadius: cardBorder
        ),
        onPressed: () {
          widget.onCardPressed();
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            // Date, Time, and People
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                widget.isFeed
                                //   ? CircleAvatar(
                                // radius: 24.0,
                                // child: Icon(Icons.person),
                                // )
                                    ? Icon(Icons.drive_eta, size: 32.0,)
                                    : Column(
                                  children: <Widget>[
                                    Text(
                                      datetimeFormat("day"),
                                      style: TextStyle(
                                          fontSize: 32.0
                                      ),
                                    ),
                                    Text(
                                      datetimeFormat("month"),
                                      style: TextStyle(
                                          fontSize: 22.0
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                Container(
                                  padding: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10.0)
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      if(widget.isFeed)
                                        Text(
                                          datetimeFormat("day") + " " + datetimeFormat("month"),
                                          style: TextStyle(
                                              fontSize: 10.0
                                          ),
                                        ),
                                      Text(datetimeFormat("time"))
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                    widget.data.role == "1" ? "ไปด้วย" : "ต้องการ"
                                ),
                                Text(
                                  widget.data.role == "1"
                                      ? '${widget.data.amount} คน'
                                      : '${int.parse(widget.data.amount) - widget.data.match.length} คน',
                                )
                              ],
                            ),
                            SizedBox(width: 16.0),
                            // Source and Destination
                            Flexible(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('ปลายทาง', style: TextStyle(fontSize: 10.0)),
                                    SizedBox(height: 5.0),
                                    Text(widget.data.dst, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 16.0),
                                    Text('ต้นทาง', style: TextStyle(fontSize: 10.0, color: Colors.black54)),
                                    SizedBox(height: 5.0),
                                    Text(widget.data.src, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      if(widget.isFeed)
                        Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 0.0),
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 44.0),
                          alignment: Alignment.centerRight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // color: widget.data.role == "1" ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          // child: widget.data.role == "1"
                          //     ? Text("ไปด้วย")
                          //     : Text("ชวน"),
                          child: Text("Thanakrit Tatsamakorn"),
                        ),
                    ],
                  ),
                  // Notification badge
                  if(!widget.isFeed)
                    Align(
                      alignment: Alignment.topRight,
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.red,
                        child: SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: Center(
                            child: Text("!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  // Type badge
                  if(widget.isFeed)
                    Align(
                      alignment: Alignment.topRight,
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(20.0),
                        color: Theme.of(context).accentColor,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("T&A", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  if(widget.isFeed)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.face),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ],
        )
      ),
    );
    return Card(
        color: Colors.white,
        margin: EdgeInsets.all(10.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: FlatButton(
          padding: EdgeInsets.only(top: 16.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          onPressed: () {
            widget.onCardPressed();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('ปลายทาง', style: TextStyle(fontSize: 10.0)),
                    SizedBox(height: 5.0),
                    Text(widget.data.dst, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.0),
                    Text('ต้นทาง', style: TextStyle(fontSize: 10.0, color: Colors.black54)),
                    SizedBox(height: 5.0),
                    Text(widget.data.src, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  decoration: BoxDecoration(
                      color: widget.data.role == "1"
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0)
                      )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('${datetimeFormat('date')} | ${datetimeFormat('time')}', style: TextStyle(color: Colors.white)),
                      Text(
                          widget.data.role == "1"
                              ? '${widget.data.amount}'
                              : '${widget.data.match.length}/${widget.data.amount}',
                          style: TextStyle(color: Colors.white)
                      ),
                    ],
                  )
              )
            ],
          ),
        )
    );
  }

//  String warrantyText() {
//    String textShown = '${widget.data[DatabaseHelper.columnWarrantyPeriod]} months warranty';
//
//    if(widget.data[DatabaseHelper.columnWarrantyPeriod] == '')
//      textShown = 'without warranty';
//    else if(widget.data[DatabaseHelper.columnWarrantyPeriod] % 12 == 0)
//      textShown = 'with ${(widget.data[DatabaseHelper.columnWarrantyPeriod]/12).toInt()} years warranty';
//
//    return textShown;
//  }

//  Widget condition(){
//    Color color;
//    if(widget.data[DatabaseHelper.columnStatus] == 'IN-USE'){
//      color = Colors.green;
//    }else if(widget.data[DatabaseHelper.columnStatus] == 'SOLD'){
//      color = Colors.amber;
//    }else if(widget.data[DatabaseHelper.columnStatus] == 'LOST'){
//      color = Colors.black38;
//    }else if(widget.data[DatabaseHelper.columnStatus] == 'BROKEN'){
//      color = Colors.red;
//    }else{
//      color = Colors.pinkAccent;
//    }
//
//    return Container(
//      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 8.0, right: 8.0),
//      color: color,
//      child: Text(widget.data[DatabaseHelper.columnStatus], style: TextStyle(color: Colors.white)),
//    );
//  }

  String datetimeFormat(String check) {
    var datetimeFromDB = DateTime.parse(widget.data.date);
    // if(check == 'date'){
    //   return DateFormat('d MMM yyyy').format(datetimeFromDB);
    // }else{
    //   return DateFormat('HH:mm').format(datetimeFromDB);
    // }
    if(check == "day"){
      return DateFormat('d').format(datetimeFromDB);
    }else if(check == "month"){
      return DateFormat('MMM').format(datetimeFromDB);
    }else if(check == "year"){
      return DateFormat('yyyy').format(datetimeFromDB);
    }else if(check == "time"){
      return DateFormat('HH:mm').format(datetimeFromDB);
    }else{
      return "Wrong input parameter.";
    }
  }
}