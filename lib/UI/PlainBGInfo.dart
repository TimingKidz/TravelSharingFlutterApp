import 'package:flutter/material.dart';

class PlainBGInfo extends StatelessWidget {
  final String label;
  final String info;

  const PlainBGInfo({Key key, this.label, this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Theme.of(context).canvasColor,
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: TextStyle(
                color: Colors.black.withOpacity(0.6)
            )),
            SizedBox(height: 14.0),
            Text(info, style: TextStyle(fontSize: 16.0))
          ],
        ),
      ),
    );
  }
}
