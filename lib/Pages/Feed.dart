import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Feed.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/buttons/cardTileWithTap.dart';
import 'package:travel_sharing/custom_color_scheme.dart';


class FeedPage extends StatefulWidget {
  final Function setSate;

  const FeedPage({Key key, this.setSate}) : super(key: key);

  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  Feed feed;
  int currentI = 0;
  List<Routes> list = List();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
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
                padding: EdgeInsets.only(left: 24.0, top: 16.0, bottom: 30.0, right: 24.0),
                child: SafeArea(
                  child: Text(
                    "Feed",
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white
                    ),
                    // textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              child: list.isNotEmpty ? _buildListView() : Center(
                child: Text("Nothing in feed yet."),
              ),
            )
          ],
        )
    );
  }

  _pageConfig(){
    getData(0);
    socket.off('onNewNotification');
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
      widget.setSate();
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
            print("onMessage: $message");
            showNotification(message);
        }
    );
  }

  getData(int offset) async {
    try{
      feed = await Feed().getFeed(offset);
      print(feed.Offset);
      list = list + feed.Allroutes;
      currentI = feed.Offset;
      setState(() { });
    }catch(error){
      print(error );
    }
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: feed.isMore ? currentI + 1: currentI,
        itemBuilder: (context, i) {
          print(i);
          if(i >= currentI ){
            getData(feed.Offset);
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 24,
                width: 24,
              ),
            );
          }else{
            return _buildRow(list[i]);
          }
        }
    );
  }

  Widget _buildRow(Routes data) {
    return CardTileWithTap(
      data: data,
    );
  }

}