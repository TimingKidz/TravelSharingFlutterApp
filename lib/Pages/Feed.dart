import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Feed.dart';
import 'package:travel_sharing/Class/Feeds.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/map.dart';
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

class FeedPageState extends State<FeedPage> with TickerProviderStateMixin {
  Feeds feed;
  GlobalKey actionKey = GlobalKey();
  double height;
  int currentI = 0;
  List<Feed> list = null;
  bool isFilter = false;

  List<String> filterTypeList = List();
  List<String> filterTypeSelected = List();
  Map<String, bool> isSelected = Map();

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
    filterTypeList = ["ไปด้วย", "ชวน", "Travel","T&A"];
    for(String each in filterTypeList){
      isSelected.addAll({each: false});
    }
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
            list != null
                ? AnimatedPadding(
              duration: Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * (isFilter ? 0.143 : 0.096)),
              child: list.isNotEmpty
                  ? RefreshIndicator(
                onRefresh: () async {
                  list.clear();
                  getData(0,filterTypeSelected);
                },
                child: _buildListView(),
              )
                  : Center(child: Text("Nothing in feed yet.")),
            )
                : Padding(
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
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 24.0, top: 4.0, bottom: 0.0, right: 4.0),
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
                              splashRadius: 24.0,
                              tooltip: "Filter",
                              iconSize: 26.0,
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  isFilter = !isFilter;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      AnimatedSize(
                        vsync: this,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.fastOutSlowIn,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.fastOutSlowIn,
                          margin: isFilter ? EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0) : EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.5),
                          height: isFilter ? 44 : 0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0)
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  separatorBuilder: (context, i) {
                                    if(i == 1) return Text(" | ", style: TextStyle(fontSize: 28.0, color: Theme.of(context).primaryColor));
                                    return SizedBox(width: 4.0);
                                  },
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(4.0),
                                  itemCount: filterTypeList.length,
                                  itemBuilder: (context, i) {
                                    return filterType(filterTypeList[i]);
                                  },
                                ),
                              ),
                              if(filterTypeSelected.isNotEmpty)
                              SizedBox(
                                height: 32,
                                width: 32,
                                child: Material(
                                  color: Colors.white,
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1.5
                                    )
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        list.clear();
                                        getData(0, filterTypeSelected);
                                      });
                                    },
                                    child: Icon(Icons.check, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0)
                            ],
                          )
                        ),
                      ),
                      // SizedBox(height: 16.0)
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget filterType(String type){
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Material(
        color: isSelected[type] ? Theme.of(context).primaryColor : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5
            )
        ),
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              type,
              style: TextStyle(
                color: !isSelected[type] ? Theme.of(context).primaryColor : Colors.white,
              ),
            ),
          ),
          onTap: (){
            setState(() {
              isSelected[type] = !isSelected[type];
              if(isSelected[type]) filterTypeSelected.add(type);
              else filterTypeSelected.remove(type);
              if(filterTypeSelected.isEmpty){
                list.clear();
                getData(0, filterTypeSelected);
              }
              print("Selected = " + filterTypeSelected.join(", ")); // Print all selected type
            });
          },
        ),
      ),
    );
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
            if(isSelected[type]) filterTypeSelected.add(type);
            else filterTypeSelected.remove(type);
            print("Selected = " + filterTypeSelected.join(", ")); // Print all selected type
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

  _pageConfig(){
    getData(0,filterTypeSelected);
    socket.off('onAccept');
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onTripEnd');
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

  getData(int offset, List<String> filter) async {
    try{
      feed = await Feeds().getFeed(offset,filter,currentUser.uid);
      print(feed);
      list = (list ?? []) + feed.feeds;
//      currentI = feed.Offset;
      setState(() { });
    }catch(error){
      print(error );
    }
  }

  Widget _buildListView() {
    return ListView.separated(
      separatorBuilder: (context, _){
        return SizedBox(height: 8.0);
      },
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: feed.isMore ? list.length + 1: list.length,
        itemBuilder: (context, i) {
//          print(i);
          if(i >= list.length ){
            getData(feed.Offset,filterTypeSelected);
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
            if(!feed.isMore && i+1 == list.length)
              return Column(
                children: [
                  _buildRow(list[i]),
                  SizedBox(height: 8.0)
                ],
              );
            return _buildRow(list[i]);
          }
        }
    );
  }

  Widget _buildRow(Feed data) {
    return FeedCardTile(
      data: data,
      onCardPressed:() => onCardPress(data) ,
    );
  }

  void onCardPress(Feed data){
    if(data.routes.role == "0"){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreateRoute_Join(data: data.routes))).then((value) async {
        list.clear();
        _pageConfig();
        await widget.setSate();
      });
    }else{
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreateRoute(data: data.routes))).then((value) async {
        list.clear();
        _pageConfig();
        await widget.setSate();
      });
    }
  }

}