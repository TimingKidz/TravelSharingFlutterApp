import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/MapStaticRequest.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/UI/RouteMapCard.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/localization.dart';

class DashboardCardTile extends StatefulWidget {
  final Travel_Info data;
  final IconData iconData;
  final Function onCardPressed;
  final Function onDeletePressed;
  final bool status;
  final SlidableController controller;

  DashboardCardTile({
    this.data,
    this.iconData,
    this.onCardPressed,
    this.status, this.onDeletePressed, this.controller
  });


  @override
  DashboardCardTileState createState() => DashboardCardTileState();
}

class DashboardCardTileState extends State<DashboardCardTile> {
  Map<String, Color> statColors;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    statColors = {
      AppLocalizations.instance.text("statMatch"): Theme.of(context).colorScheme.success,
      AppLocalizations.instance.text("statAccept"): Theme.of(context).colorScheme.success,
      AppLocalizations.instance.text("statWait"): Theme.of(context).colorScheme.warning,
      AppLocalizations.instance.text("statPending"): Theme.of(context).colorScheme.warning,
      AppLocalizations.instance.text("statNoMatch"): Theme.of(context).colorScheme.danger,
      AppLocalizations.instance.text("statFoundMatch"): Theme.of(context).colorScheme.warning,
      "Expired" : Colors.grey
    };
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      controller: widget.controller,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      actions: [
        IconSlideAction(
          caption: AppLocalizations.instance.text("more"),
          color: Colors.black45,
          icon: Icons.more_horiz,
          onTap: () {
            normalDialog(context,
              RouteMapCard(
                data: widget.data,
                url: widget.data.routes.role == "0" ? MapStaticRequest().invite_getMapUrl(widget.data.routes) : MapStaticRequest().join_getMapUrl(widget.data.routes))
            );
          },
        ),
      ],
      secondaryActions: <Widget>[
        if(widget.data.routes.match.isEmpty)
        IconSlideAction(
          caption: AppLocalizations.instance.text("delete"),
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            deleteDialog(context, () => widget.onDeletePressed());
          },
        ),
      ],
      child: FlatButton(
          padding: EdgeInsets.only(top: 0.0),
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
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        DateManage().datetimeFormat("day", widget.data.routes.date),
                                        style: TextStyle(
                                            fontSize: 32.0
                                        ),
                                      ),
                                      Text(
                                        DateManage().datetimeFormat("month", widget.data.routes.date),
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
                                        Text(DateManage().datetimeFormat("time", widget.data.routes.date))
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                      widget.data.routes.role == "1" ? "ไปด้วย" : "ต้องการ"
                                  ),
                                  Text(
                                    widget.data.routes.role == "1"
                                        ? '${widget.data.routes.amount} คน'
                                        : '${widget.data.routes.left} คน',
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
                                      Text(AppLocalizations.instance.text("dst"), style: TextStyle(fontSize: 10.0)),
                                      SizedBox(height: 5.0),
                                      Text(widget.data.routes.dst, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 16.0),
                                      Text(AppLocalizations.instance.text("src"), style: TextStyle(fontSize: 10.0, color: Colors.black54)),
                                      SizedBox(height: 5.0),
                                      Text(widget.data.routes.src, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),
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
                      notificationBadge(),
                     Positioned.fill(
                       child:  Align(
                         alignment: Alignment.bottomRight,
                         child: Material(
                           elevation: 1,
                           borderRadius: BorderRadius.circular(20.0),
                           color: statColors[widget.data.status],
                           child: Container(
                             padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0) ,
                             child: Text(widget.data.status, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                           ),

                         ),
                       ),
                     ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget notificationBadge(){
    return Align(
      alignment: Alignment.topRight,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Icon(Icons.notifications),
          Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.red,
            child: SizedBox(
              width: 12.0,
              height: 12.0,
              child: Center(
                child: Text("!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 6.0)),
              ),
            ),
          )
        ],
      ),
    );
  }
}