import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Feed.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/main.dart';



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
    if( feed == null){
      return Scaffold();
    }else{
      return Scaffold(
        body: _buildListView(),
      );
    }
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
    return ListView.separated(
        separatorBuilder: (context, i) => Divider(
          color: Colors.grey,
        ),
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
            return _buildRow(list[i].src);
          }
        }
    );
  }

  Widget _buildRow(String data) {
    return Container(
      child: Text(data),
      height: 600,
    );
  }

}