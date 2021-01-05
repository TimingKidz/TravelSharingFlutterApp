import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travel_sharing/Class/Review.dart';
import 'package:travel_sharing/main.dart';

class ReviewCard extends StatefulWidget {
  final EachReview data;

  const ReviewCard({Key key, this.data}) : super(key: key);
  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Container(
        padding: EdgeInsets.all(8.0),
        width: double.infinity,
        child: Column(
          children: [
            // User info who review you
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: ClipOval(
                    child: widget.data.imgpath != null ? Image.network("${httpClass.API_IP}${widget.data.imgpath}") : Container(),
                  ),
                ),
                SizedBox(width: 8.0),
                Text(widget.data.name)
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RatingBarIndicator(
                  rating: widget.data.score,
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 18.0,
                  direction: Axis.horizontal,
                ),
                SizedBox(width: 4.0),
                Text(widget.data.score.toString())
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                for(String each in widget.data.tag)
                  ratingType(each),
                SizedBox(width: 8.0),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget ratingType(String type){
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
            type
        ),
      ),
    );
  }
}
