import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class DashboardCardTile extends StatefulWidget {
  final Routes data;
  final IconData iconData;
  final Function onCardPressed;
  final Function onDeletePressed;
  final bool status;

  DashboardCardTile({
    this.data,
    this.iconData,
    this.onCardPressed,
    this.status, this.onDeletePressed
  });


  @override
  DashboardCardTileState createState() => DashboardCardTileState();
}

class DashboardCardTileState extends State<DashboardCardTile> {
  BorderRadius cardBorder = BorderRadius.circular(20.0);
  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10.0),
      // elevation: 2.0,
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
          onLongPress: () async {
            setState(() {
              isLongPress = !isLongPress;
            });
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
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        DateManage().datetimeFormat("day", widget.data.date),
                                        style: TextStyle(
                                            fontSize: 32.0
                                        ),
                                      ),
                                      Text(
                                        DateManage().datetimeFormat("month", widget.data.date),
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
                                        Text(DateManage().datetimeFormat("time", widget.data.date))
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
                                        : '${widget.data.left} คน',
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
                      ],
                    ),
                    // Notification badge
                    if(widget.status)
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
                    // TODO: Add Animated Container
                    if(isLongPress)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => widget.onDeletePressed(),
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
    // return Card(
    //     color: Colors.white,
    //     margin: EdgeInsets.all(10.0),
    //     elevation: 2.0,
    //     shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(20.0)
    //     ),
    //     child: FlatButton(
    //       padding: EdgeInsets.only(top: 16.0),
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(20.0)
    //       ),
    //       onPressed: () {
    //         widget.onCardPressed();
    //       },
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: <Widget>[
    //           Container(
    //             padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 48.0),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 Text('ปลายทาง', style: TextStyle(fontSize: 10.0)),
    //                 SizedBox(height: 5.0),
    //                 Text(widget.data.dst, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
    //                 SizedBox(height: 16.0),
    //                 Text('ต้นทาง', style: TextStyle(fontSize: 10.0, color: Colors.black54)),
    //                 SizedBox(height: 5.0),
    //                 Text(widget.data.src, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),
    //               ],
    //             ),
    //           ),
    //           Container(
    //               width: double.infinity,
    //               padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
    //               decoration: BoxDecoration(
    //                   color: widget.data.role == "1"
    //                       ? Theme.of(context).primaryColor
    //                       : Theme.of(context).accentColor,
    //                   borderRadius: BorderRadius.only(
    //                       bottomLeft: Radius.circular(20.0),
    //                       bottomRight: Radius.circular(20.0)
    //                   )
    //               ),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: <Widget>[
    //                   Text('${datetimeFormat('date')} | ${datetimeFormat('time')}', style: TextStyle(color: Colors.white)),
    //                   Text(
    //                       widget.data.role == "1"
    //                           ? '${widget.data.amount}'
    //                           : '${widget.data.match.length}/${widget.data.amount}',
    //                       style: TextStyle(color: Colors.white)
    //                   ),
    //                 ],
    //               )
    //           )
    //         ],
    //       ),
    //     )
    // );
  }
}