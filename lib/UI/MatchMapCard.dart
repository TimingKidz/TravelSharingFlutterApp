import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/main.dart';

class MatchMapCard extends StatefulWidget {
  final String url;
  final Match_Info data;
  final bool isreq;
  final Function onButtonPressed;

  const MatchMapCard({Key key,this.url ,this.data, this.isreq, this.onButtonPressed}) : super(key: key);
  @override
  _MatchMapCardState createState() => _MatchMapCardState();
}

// TODO: Show correct map point
class _MatchMapCardState extends State<MatchMapCard> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Image.network(
              widget.url,
              fit: BoxFit.cover,

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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('ปลายทาง', style: TextStyle(fontSize: 10.0)),
                            SizedBox(height: 5.0),
                            Text(widget.data.routes.dst, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16.0),
                            Text('ต้นทาง', style: TextStyle(fontSize: 10.0)),
                            SizedBox(height: 5.0),
                            Text(widget.data.routes.src, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16.0),
                            Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 20,
                                  child: ClipOval(
                                    child: Image.network(
                                      "${httpClass.API_IP}${widget.data.user.imgpath}",
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Text(widget.data.user.name, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                              ],
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
