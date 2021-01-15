import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardInformation extends StatefulWidget {
  final String labelText;
  final String infoText;

  CardInformation({this.labelText, this.infoText});
  CardInformationState createState() => CardInformationState();
}

class CardInformationState extends State<CardInformation> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
      ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.labelText, style: TextStyle(color: Colors.black.withOpacity(0.6))),
            SizedBox(height: 12.0),
            Text(widget.infoText, style: Theme.of(context).textTheme.subtitle1)
          ],
        ),
      ),
    );
  }

}