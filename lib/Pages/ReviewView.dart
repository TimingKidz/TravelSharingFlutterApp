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
  List<EachReview> reviewList = List();

  @override
  void initState() {
    super.initState();
    _pageConfig();
  }

  _pageConfig() async {
    await getData(0);
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onKick');

    socket.on('onKick', (data){
      currentUser.status.navbarTrip = true;
      currentUser.status.navbarNoti = true;
    });
    socket.on('onRequest', (data) {
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewMatch' , (data){
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewAccept', (data){
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewMessage',(data){
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewAccept',(data){
      currentUser.status.navbarTrip = true;
    });
    socket.on('onNewNotification', (data){
      currentUser.status.navbarNoti = true;
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showNotification(message);
        }
    );
  }

  // get request list of current routes
  Future<void> getData(int offset) async {
    try{

      review =  await Review().getReview(widget.user.uid,offset);
      reviewList = reviewList + review.review;
      currentI = review.offset;
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
          if(review != null)
          Padding(
            padding: EdgeInsets.only(top: 100),
            child: review.review.isNotEmpty ? _buildListView() : Center(
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
                              rating:  review != null ? review.totalscore : 5.0,
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
                                Text( review != null ? review.totalscore.toString() : "5.0")
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
