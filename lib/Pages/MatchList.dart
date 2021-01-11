import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/MapStaticRequest.dart';
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/UI/MatchMapCard.dart';
import 'package:travel_sharing/UI/NotificationBarSettings.dart';
import 'package:travel_sharing/main.dart';
import 'package:flutter/services.dart';


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
  List<Match_Info> _MatchList = null;
  bool isFirstPage = true;
  List<String> isreq = null;
  int _index = 1;
//  Travel_Info Data;
  Map<String,bool> isPress = Map();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
//    socket.off('onAccept');
    notificationBarIconLight();
    super.dispose();
  }
//
//  @override
//  void didChangeDependencies() {
//    // TODO: implement didChangeDependencies
//    super.didChangeDependencies();
//    final arg = ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
//    Data = arg["data"];
//
//  }


  @override
  void initState(){
    super.initState();
    _pageConfig(widget.data.routes.status);
  }

  _pageConfig(bool isNeed2Update){
    getData(isNeed2Update);
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onTripEnd');
    socket.off('onKick');
    socket.off('onAccept');

    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    socket.on('onNewMatch', (data) {
      if(widget.data.uid == data['tripid']){
        getData(true);
      }
    });

    socket.on('onAccept', (data) {
      print(data);
      if( widget.data.uid == data['tripid'] ){
        unPopDialog(
          this.context,
          'Accept',
          Text("Your requset has been Accepted."),
          <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () async {
                Navigator.popUntil(context, ModalRoute.withName('/homeNavigation'));
              },
            ),
          ],
        );
      }
    });

    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if( (message['data']['tag'] != widget.data.uid && message['data']['tag'] == '/MatchList') ||  message['data']['tag'] != '/MatchList' ){
            print("onMessage: $message");
            showNotification(message);
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    notificationBarIconDark();
    return  Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                    height: double.infinity, // card height
                    child: _widgetOptions()
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              if( _MatchList != null )
              if(_MatchList.isNotEmpty )
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 32.0),
                    child: Text("$_index/${_MatchList.length}"),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

  // get Match list of current routes
  Future<void> getData(bool isNeed2Update) async {
    try{
      _MatchList =  await Match_Info().getMatchList(widget.data.routes,isNeed2Update) ?? [];
      if( isreq == null) {
        isreq = await User().getisReq(widget.data.id, widget.data.uid) ?? [];
       _MatchList.forEach((element) {
          isPress[element.routes.uid] = false;
       });
      }
      setState(() {});
    }catch(error){
      print(error);
    }
  }

  Widget _widgetOptions(){
    if( _MatchList != null){
      if(_MatchList.isEmpty){
        return Center(
          child: Text('No List'),
        );
      }else{
        return _buildListView();
      }
    }
    return Padding(
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
    );


  }

  Widget _buildListView() {
    return PageView.builder(
      itemCount: _MatchList.length,
      controller: PageController(viewportFraction: 0.85),
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      onPageChanged: (int index) => setState(() => _index = index + 1),
      itemBuilder: (_, i) {
        return Card(
          margin: EdgeInsets.only(top: 64.0, bottom: 64.0, right: 8.0, left: 8.0),
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
      url : MapStaticRequest().getMapUrl(data.routes, widget.data.routes),
      data: data,
      userData: widget.data,
      isreq: isreq.contains(data.routes.uid),
      isPress: isPress[data.routes.uid],
      onButtonPressed: () async => _onButtonPressed(data),
    );
  }

  Future<bool> _onButtonPressed(Match_Info data) async {
    isPress[data.routes.uid] = true;
    setState((){ });
    Routes().Request(data,widget.data).then((value){
      if(value){
        isreq.add(data.routes.uid);
        isPress[data.routes.uid] = false;
      }else{
        print("error");
      }
      setState(() { });
    });
  }

}
