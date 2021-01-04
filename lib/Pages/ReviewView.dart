import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travel_sharing/UI/ReviewCard.dart';

class ReviewView extends StatefulWidget {
  @override
  _ReviewViewState createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 100),
            child: true ? _buildListView() : Center(
              child: Text("No reviews in your account yet."),
            ),
          ),
          Card(
            elevation: 2.0,
            margin: EdgeInsets.all(0.0),
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)
                )
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
              child: SafeArea(
                child: Wrap(
                  children: [
                    Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 8.0,
                            ),
                            RatingBarIndicator(
                              rating: 4.75,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 30.0,
                              direction: Axis.horizontal,
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star),
                                SizedBox(width: 8.0),
                                Text("5.0")
                              ],
                            )
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          iconSize: 26.0,
                          color: Colors.white,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: <Widget>[
                        //     IconButton(
                        //       icon: Icon(Icons.arrow_back),
                        //       iconSize: 26.0,
                        //       color: Colors.white,
                        //       onPressed: () => Navigator.of(context).pop(),
                        //     ),
                        //     IconButton(
                        //       icon: Icon(Icons.edit),
                        //       color: Colors.white,
                        //       onPressed: (){
                        //
                        //       },
                        //     ),
                        //   ],
                        // )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: 1,
        itemBuilder: (context, i) {
          return _buildRow();
        }
    );
  }

  Widget _buildRow() {
    return ReviewCard();
  }
}
