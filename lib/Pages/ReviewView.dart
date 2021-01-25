import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travel_sharing/Class/Review.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/UI/ReviewCard.dart';
import 'package:travel_sharing/main.dart';

class ReviewView extends StatefulWidget {
  final User user;

  const ReviewView({Key key, this.user}) : super(key: key);
  @override
  _ReviewViewState createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  Review review ;
  int currentI = 0;
  List<EachReview> reviewList = null;

  @override
  void initState() {
    super.initState();
    getData(0);
  }


  // get request list of current routes
  Future<void> getData(int offset) async {
    try{
      review =  await Review().getReview(widget.user.uid,offset);
      reviewList = (reviewList ?? []) + review.review;
      currentI = review.offset;
      print(review.totalscore);
      print(review.amount);
      setState((){});
    }catch(error){
      print(error);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          reviewList != null ?
          reviewList.isNotEmpty ? _buildListView() : Center(
            child: Text("No reviews in your account yet."),
          ) : Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.09),
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 20.0),
                    Text("Loading..."),
                  ],
                )
            ),
          ),
          Card(
            elevation: 2.0,
            margin: EdgeInsets.zero,
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
                        if(review != null)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RatingBarIndicator(
                                  rating: review.amount == 0 ? 0.0 : review.totalscore/review.amount,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 24.0,
                                  direction: Axis.horizontal,
                                ),
                                SizedBox(width: 4.0),
                                Text( review.amount == 0 ? "0.0": (review.totalscore/review.amount).toString(), style: TextStyle(fontSize: 16.0, color: Colors.white)),
                                SizedBox(width: 4.0),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(color: Colors.white, width: 0.5)
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.people, size: 14.0, color: Colors.white),
                                      SizedBox(width: 2.0),
                                      Text(review.amount.toString(), style: TextStyle(fontSize: 14.0, color: Colors.white)),
                                      SizedBox(width: 1.0),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
    return ListView.separated(
      separatorBuilder: (context, _){
        return SizedBox(height: 8.0);
      },
        padding: EdgeInsets.fromLTRB(8.0, 112.0, 8.0, 8.0),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: review.isMore ? currentI+1 : currentI,
        itemBuilder: (context, i) {
          if(i >= currentI ){
            getData(review.offset);
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  height: 24,
                  width: 24,
                ),
              ),
            );
          }else{
            return _buildRow(reviewList[i]);
          }

        }
    );
  }

  Widget _buildRow(EachReview data) {
    return ReviewCard(
      data: data,
    );
  }
}
