import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Feed.dart';
import 'package:travel_sharing/Class/Feeds.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/buttons/FeedCardTile.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/buttons/DashboardCardTile.dart';
import 'package:travel_sharing/custom_color_scheme.dart';


class FeedPage extends StatefulWidget {
  final Function setSate;

  const FeedPage({Key key, this.setSate}) : super(key: key);

  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  Feeds feed;
  GlobalKey actionKey = GlobalKey();
  double height;
  int currentI = 0;
  List<Feed> list = List();

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
    print(currentUser.imgpath);
    // WidgetsBinding.instance.addPostFrameCallback((_) => _getHeight());
  }

  // void _getHeight(){
  //   RenderBox renderBox = actionKey.currentContext.findRenderObject();
  //   height = renderBox.size.height;
  //   print(height);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.09),
              child: list.isNotEmpty
                  ? RefreshIndicator(
                onRefresh: () => getData(0),
                child: _buildListView(),
              )
                  : Center(child: Text("Nothing in feed yet."),
              ),
            ),
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(0.0),
              color: Theme.of(context).colorScheme.darkBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)
                  )
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 24.0, top: 4.0, bottom: 16.0, right: 4.0),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.instance.text("FeedTitle"),
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                        // textAlign: TextAlign.center,
                      ),
                      IconButton(
                        icon: Icon(Icons.filter_list),
                        tooltip: "Filter",
                        iconSize: 26.0,
                        color: Colors.white,
                        onPressed: () {

                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }

  _pageConfig(){
    getData(0);
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onKick');

    socket.on('onKick', (data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });

    socket.on('onRequest', (data) {
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewMatch' , (data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewAccept', (data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewMessage',(data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewAccept',(data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewNotification', (data) {
      print(currentUser.status.navbarNoti);
      currentUser.status.navbarNoti = true;
      print(currentUser.status.navbarNoti);
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
      feed = await Feeds().getFeed(offset);
      print(feed.Offset);
      list = list + feed.feeds;
      currentI = feed.Offset;
      setState(() { });
    }catch(error){
      print(error );
    }
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: feed.isMore ? currentI + 1: currentI,
        itemBuilder: (context, i) {
          print(i);
          if(i >= currentI ){
            getData(feed.Offset);
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
              return _buildRow(list[i]);
          }
        }
    );
  }

  Widget _buildRow(Feed data) {
    return FeedCardTile(
      data: data,
    );
  }

}