import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Feed.dart';
import 'package:travel_sharing/Class/RouteJson.dart';



class FeedPage extends StatefulWidget {
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
    getData(0);
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