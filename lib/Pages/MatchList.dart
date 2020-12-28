import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/UI/MatchMapCard.dart';
import 'package:travel_sharing/main.dart';


class MatchList extends StatefulWidget {
  final Travel_Info data;
  static final GlobalKey<_MatchListstate> dashboardKey = GlobalKey<_MatchListstate>();

  MatchList({Key key, this.data}) : super(key: dashboardKey);
  @override
  _MatchListstate createState() => _MatchListstate();
}

class _MatchListstate extends State<MatchList> {
  Location location = Location();
  LocationData Locations;
  List<Match_Info> _MatchList = List();
  bool isFirstPage = true;
  List<String> isreq = List();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    socket.off('onAccept');
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _pageConfig();
  }

  _pageConfig(){
    getData();
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onNewNotification');
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    socket.on('onNewMatch', (data) => getData());
    socket.on('onAccept', (data) =>  Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => Matchinformation(uid: data, data: widget.data))));
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if( message['data']['page'] != '/MatchList' ){
            print("onMessage: $message");
            showNotification(message);
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: SafeArea(
          child: Center(
            child: SizedBox(
                height: double.infinity, // card height
                child: _widgetOptions()
            ),
          ),
        )
    );
  }

  // get Match list of current routes
  Future<void> getData() async {
    try{
      _MatchList =  await Match_Info().getMatchList(widget.data.routes) ?? [];
      isreq = await User().getisReq(widget.data.id, widget.data.uid) ?? [];
      setState(() {});
    }catch(error){
      print(error+" From : MatchList getData()");
    }
  }

  Widget _widgetOptions(){
    if(_MatchList.isEmpty){
      return Center(
        child: Text('No List'),
      );
    }else{
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return PageView.builder(
      itemCount: _MatchList.length,
      controller: PageController(viewportFraction: 0.85),
      physics: BouncingScrollPhysics(),
      // onPageChanged: (int index) => setState(() => _index = index),
      itemBuilder: (_, i) {
        return Card(
          margin: EdgeInsets.only(top: 64.0, bottom: 64.0, right: 8.0, left: 8.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: cardDetails(_MatchList[i]),
        );
      },
    );
  }

  Widget cardDetails(Match_Info data){
    // int next = i - 1 < 0 ? i : i-1;
    // if(i == _index || next == _index){
    return MatchMapCard(
      data: data,
      isreq: isreq.contains(data.routes.uid),
      onButtonPressed: () => _onButtonPressed(data),
    );
    // }else{
    //   return Center(
    //     child: Text("Hello"),
    //   );
    // }
  }

  _onCardPressed(Match_Info data) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => mapview(from:widget.data.routes,to:data.routes)));
  }

  _onButtonPressed(Match_Info data) async {
    Routes().Request(data,widget.data);
    await getData();
  }

}
