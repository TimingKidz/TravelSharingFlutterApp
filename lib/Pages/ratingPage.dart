import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travel_sharing/main.dart';

class RatingPage extends StatefulWidget {
  RatingPageState createState() => RatingPageState();
}

class RatingPageState extends State<RatingPage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "ให้คะแนนคนขับรถ",
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 16.0),
          Center(
            child: RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
          ),
          SizedBox(height: 128.0),
          RaisedButton(
            highlightElevation: 0.0,
            padding: EdgeInsets.all(16.0),
            color: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text('ส่ง', style: TextStyle(color: Colors.white,)),
            onPressed: () {

            },
          )
        ],
      ),
    );
  }

}