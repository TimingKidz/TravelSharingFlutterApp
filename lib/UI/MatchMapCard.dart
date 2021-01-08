import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/UI/ProfileInfo.dart';
import 'package:travel_sharing/main.dart';

class MatchMapCard extends StatefulWidget {
  final String url;
  final Match_Info data;
  final Travel_Info userData;
  final bool isreq;
  final Function onButtonPressed;

  const MatchMapCard({Key key,this.url ,this.data, this.isreq, this.onButtonPressed, this.userData}) : super(key: key);
  @override
  _MatchMapCardState createState() => _MatchMapCardState();
}

class _MatchMapCardState extends State<MatchMapCard> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  child: Image.network(
                      widget.url,
                      fit: BoxFit.cover
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 48,
                    child: RawMaterialButton(
                      elevation: 1,
                      highlightElevation: 1,
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => MapView(paiDuay: widget.userData.routes, chuan: widget.data.routes)));
                      },
                      shape: CircleBorder(),
                      fillColor: Colors.white,
                      child: Icon(Icons.map),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.all(16.0),
              width: double.infinity,
              child: Wrap(
                children: <Widget>[
                  Column(
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
                                    Icon(Icons.drive_eta, size: 32.0),
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
                            SizedBox(height: 16.0),
                            InkWell(
                              onTap: (){
                                swipeUpDialog(
                                  context,
                                  ProfileInfo(
                                      data: widget.data.user,
                                      isHost: false
                                  )
                                );
                              },
                              borderRadius: BorderRadius.circular(20.0),
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 20,
                                    child: ClipOval(
                                      child: widget.data.user.imgpath != null ? Image.network("${httpClass.API_IP}${widget.data.user.imgpath}") : Container(),
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.data.user.name, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          RatingBarIndicator(
                                            rating: 4.2,
                                            itemBuilder: (context, index) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 16.0,
                                            direction: Axis.horizontal,
                                          ),
                                          SizedBox(width: 4.0),
                                          Text("4.2", style: TextStyle(fontSize: 10.0)),
                                          SizedBox(width: 4.0),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20.0),
                                                border: Border.all(color: Colors.black, width: 0.5)
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.people, size: 10.0),
                                                SizedBox(width: 2.0),
                                                Text("5K", style: TextStyle(fontSize: 10.0)),
                                                SizedBox(width: 1.0),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          highlightElevation: 0.0,
                          padding: EdgeInsets.all(16.0),
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(widget.isreq ? 'ส่งคำขอแล้ว' : 'ส่งคำขอ', style: TextStyle(color: Colors.white,)),
                          onPressed: widget.isreq ? null : () => widget.onButtonPressed(),
                        ),
                      ),
                    ],
                  )
                ],
              )
          ),
        ],
      ),
    );
  }
}
