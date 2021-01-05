import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travel_sharing/Class/Review.dart';
import 'package:travel_sharing/UI/NotificationBarSettings.dart';
import 'package:travel_sharing/main.dart';

class RatingPage extends StatefulWidget {
  final String sendToid;
  final String notiId;

  const RatingPage({Key key, this.sendToid, this.notiId}) : super(key: key);
  RatingPageState createState() => RatingPageState();
}

class RatingPageState extends State<RatingPage> {
  List<String> ratingTypeList = List();
  List<String> ratingTypeSelected = List();
  Map<String, bool> isSelected = Map();
  EachReview review = new EachReview(sender: currentUser.uid,name: currentUser.name,imgpath: currentUser.imgpath);
  double rate = 5.0;

  @override
  void initState() {
    ratingTypeList = ["สุภาพ", "เป็นมิตร", "ตรงเวลา"];
    for(String each in ratingTypeList){
      isSelected.addAll({each: false});
    }
    super.initState();
  }

  @override
  void dispose() {
    notificationBarIconLight();
    super.dispose();
  }

  // TODO: Complete Flow to BackEnd
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
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
              initialRating: 5,
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
                rate = rating;
              },
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Theme.of(context).canvasColor
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    for(String each in ratingTypeList)
                      ratingType(each),
                    SizedBox(width: 8.0),
                  ],
                )
              ],
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
            onPressed: ()  async {
              review.tag = ratingTypeSelected;
              review.score = rate;
              await review.sendReview(widget.sendToid,widget.notiId).then((value) {
                if( value ) print("send a Review suceesfull.");
                else print("Fail to send a Review.");
                Navigator.of(context).pop();
              });
            },
          )
        ],
      ),
    );
  }

  Widget ratingType(String type){
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
      ),
      color: isSelected[type] ? Theme.of(context).accentColor : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: (){
          setState(() {
            isSelected[type] = !isSelected[type];
            if(isSelected[type]) ratingTypeSelected.add(type);
            else ratingTypeSelected.remove(type);
            print("Selected = " + ratingTypeSelected.join(", ")); // Print all selected type
          });
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
              type
          ),
        ),
      ),
    );
  }

}