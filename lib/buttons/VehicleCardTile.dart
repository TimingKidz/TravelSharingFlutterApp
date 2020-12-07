import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehicleCardTile extends StatefulWidget {
  VehicleCardTileState createState() => VehicleCardTileState();
}

class VehicleCardTileState extends State<VehicleCardTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: double.infinity,
        child: Text("TTT"),
      ),
    );
  }
}