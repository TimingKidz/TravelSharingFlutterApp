import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/Feed.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/UI/ProfileInfo.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/main.dart';

class FeedCardTile extends StatefulWidget {
  final Feed data;
  final IconData iconData;
  final Function onCardPressed;

  FeedCardTile({
    this.data,
    this.iconData,
    this.onCardPressed
  });

  @override
  FeedCardTileState createState() => FeedCardTileState();
}

class FeedCardTileState extends State<FeedCardTile> {
  BorderRadius cardBorder = BorderRadius.circular(20.0);
  Map<String,IconData> type = {
    "Car" : Icons.drive_eta,
    "Motorcycle" : Icons.motorcycle,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
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
                                  Icon(  type[widget.data.routes.vehicle.type] ?? (int.parse(widget.data.routes.amount) > 1 ? Icons.people : Icons.person), size: 32.0,),

                                  SizedBox(height: 8.0),
                                  Container(
                                    padding: EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(
                                            10.0)
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          DateManage().datetimeFormat("day", widget.data.routes.date) + " " + DateManage().datetimeFormat("month", widget.data.routes.date),
                                          style: TextStyle(
                                              fontSize: 10.0
                                          ),
                                        ),
                                        Text(DateManage().datetimeFormat("time", widget.data.routes.date))
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                      widget.data.routes.role == "1"
                                          ? "ไปด้วย"
                                          : "ต้องการ"
                                  ),
                                  Text(
                                    widget.data.routes.role == "1"
                                        ? '${widget.data.routes.amount} คน'
                                        : '${int.parse(
                                        widget.data.routes.amount) -
                                        widget.data.routes.match.length} คน',
                                  )
                                ],
                              ),
                              SizedBox(width: 16.0),
                              // Source and Destination
                              Flexible(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Text('ปลายทาง',
                                          style: TextStyle(fontSize: 10.0)),
                                      SizedBox(height: 5.0),
                                      Text(widget.data.routes.dst,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 20.0,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 16.0),
                                      Text('ต้นทาง', style: TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.black54)),
                                      SizedBox(height: 5.0),
                                      Text(widget.data.routes.src,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54)),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 0.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 44.0),
                          alignment: Alignment.centerRight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // color: widget.data.role == "1" ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
                            color: Theme
                                .of(context)
                                .canvasColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          // child: widget.data.role == "1"
                          //     ? Text("ไปด้วย")
                          //     : Text("ชวน"),
                          child: Text(widget.data.user.name),
                        ),
                      ],
                    ),
                    // Type badge
                    Align(
                      alignment: Alignment.topRight,
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(20.0),
                        color: Theme
                            .of(context)
                            .accentColor,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(widget.data.routes.tag.first, style: TextStyle(fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Material(
                          shape: CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          color: Colors.grey,
                          child: InkWell(
                            onTap: () {
                              swipeUpDialog(context, ProfileInfo(data: widget.data.user));
                            },
                            child: widget.data.user.imgpath != null
                                ? Ink.image(
                              image: Image.network("${httpClass.API_IP}${widget.data.user.imgpath}").image,
                              fit: BoxFit.cover,
                              width: 48.0,
                              height: 48.0,
                            )
                                : Container(
                                width: 48.0,
                                height: 48.0,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                          )
                        )
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}