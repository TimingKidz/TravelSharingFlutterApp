import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/UI/ProfileInfo.dart';
import 'package:travel_sharing/buttons/VehicleCardTileMin.dart';
import 'package:travel_sharing/main.dart';

class RouteMapCard extends StatefulWidget {
  final String url;
  final Travel_Info data;

  const RouteMapCard({Key key, this.url ,this.data}) : super(key: key);
  @override
  _RouteMapCardState createState() => _RouteMapCardState();
}

class _RouteMapCardState extends State<RouteMapCard> {

  @override
  Widget build(BuildContext context) {
    print(widget.data.routes.vehicle.toJson());
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.45 - 30),
            height: double.infinity,
            child: Ink.image(
              fit: BoxFit.cover,
              image: Image.network(widget.url).image,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: Material(
                      elevation: 2,
                      color: Colors.white,
                      shape: CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.clear),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: Material(
                      elevation: 2,
                      color: Colors.white,
                      shape: CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MapView(paiDuay: widget.data.routes, chuan: widget.data.routes)));
                        },
                        child: Icon(Icons.map),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))
                  ),
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('ปลายทาง', style: TextStyle(fontSize: 10.0)),
                                        SizedBox(height: 5.0),
                                        Text(widget.data.routes.dst, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 16.0),
                                        Text('ต้นทาง', style: TextStyle(fontSize: 10.0)),
                                        SizedBox(height: 5.0),
                                        Text(widget.data.routes.src, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Vehicle Icon, Date and Time
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Vehicle().getTypeIcon(widget.data.routes.vehicle.type,32),
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
                                  ],
                                ),
                              ],
                            ),
                            if(widget.data.routes.role == "0")
                              VehicleCardTileMin(data: widget.data.routes.vehicle),
                            if(widget.data.routes.imgpath != null)
                              Column(
                                children: [
                                  SizedBox(height: 8.0),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    width: MediaQuery.of(context).size.width - 32 - 32,
                                    height: MediaQuery.of(context).size.width - 32 - 32,
                                    child: widget.data.routes.imgpath != null ? Image.network("${httpClass.API_IP}${widget.data.routes.imgpath}") : Icon(Icons.broken_image, color: Colors.white),
                                  ),
                                ],
                              ),
                            if(widget.data.routes.description?.isNotEmpty ?? false)
                              Column(
                                children: [
                                  SizedBox(height: 8.0),
                                  Container(
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).canvasColor,
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                    width: MediaQuery.of(context).size.width - 32 - 8,
                                    child: Text(
                                        widget.data.routes.description
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
