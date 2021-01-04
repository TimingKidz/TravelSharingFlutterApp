import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/Req_Info.dart';

class ReqMapCard extends StatefulWidget {
  final String url;
  final Req_Info data;
  final Function onAcceptPressed;
  final Function onDeclinePressed;

  const ReqMapCard({Key key, this.url,this.data, this.onAcceptPressed, this.onDeclinePressed}) : super(key: key);

  @override
  _ReqMapCardState createState() => _ReqMapCardState();
}

class _ReqMapCardState extends State<ReqMapCard> {
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
                                Icon(Icons.account_circle, size: 32.0),
                                SizedBox(width: 8.0),
                                Text(widget.data.user.name, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              highlightElevation: 0.0,
                              padding: EdgeInsets.all(16.0),
                              color: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text('ปฏิเสธ', style: TextStyle(color: Colors.white)),
                              onPressed: () => widget.onDeclinePressed(),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: RaisedButton(
                              highlightElevation: 0.0,
                              padding: EdgeInsets.all(16.0),
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text('ยอมรับ', style: TextStyle(color: Colors.white)),
                              onPressed: () => widget.onAcceptPressed() ,
                            ),
                          ),
                        ],
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
