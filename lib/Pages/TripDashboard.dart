import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TripDashboard extends StatefulWidget {
  TripDashboardState createState() => TripDashboardState();
}

class TripDashboardState extends State<TripDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('คนไปด้วย'),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.amber,
                            child: CircleAvatar(
                              radius: 35,

                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}