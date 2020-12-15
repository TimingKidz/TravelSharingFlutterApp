import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Vehicle.dart';

class VehicleCardTileMin extends StatefulWidget {
  final Vehicle data;
  final double cardMargin;
  VehicleCardTileMin({@required this.data,this.cardMargin});
  VehicleCardTileMinState createState() => VehicleCardTileMinState();
}

class VehicleCardTileMinState extends State<VehicleCardTileMin> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.all(widget.cardMargin == null ? 0.0 : widget.cardMargin),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.motorcycle),
                    SizedBox(width: 8.0),
                    Text(
                      widget.data.type,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(width: 8.0),
                  ],
                ),
                InkWell(
                  child: Text(
                    "Change Default",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: (){

                  },
                )
              ],
            ),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text('ทะเบียน', style: TextStyle(color: Colors.black.withOpacity(0.7)),),
                    Text(widget.data.license)
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text('ยี่ห้อ', style: TextStyle(color: Colors.black.withOpacity(0.7)),),
                    Text(widget.data.brand)
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text('รุ่น', style: TextStyle(color: Colors.black.withOpacity(0.7)),),
                    Text(widget.data.model)
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text('สี', style: TextStyle(color: Colors.black.withOpacity(0.7)),),
                    Text(widget.data.color)
                  ],
                )
              ],
            ),
          ],
        )
      ),
    );
  }
}