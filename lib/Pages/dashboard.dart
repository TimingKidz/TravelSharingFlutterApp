import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/MatchList.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/ReqList.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/buttons/DashboardCardTile.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';

class Dashboard extends StatefulWidget {
  final Function setSate;
  final bool isNeed2Update;
  const Dashboard({Key key, this.isNeed2Update , this.setSate}) : super(key: key);
  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  Location location = Location();
  LocationData Locations;
  List<Travel_Info> _joinList  = null;
  List<Travel_Info> _invitedList = null;
  final SlidableController slidableController = SlidableController();
  // GlobalKey actionKey = GlobalKey();
  // double height;
  // bool isJoinPage = true;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }


  @override
  void initState() {
    super.initState();
    //_pageConfig();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _getHeight());
    _pageConfig(widget.isNeed2Update);
  }


  // void _getHeight(){
  //   RenderBox renderBox = actionKey.currentContext.findRenderObject();
  //   height = renderBox.size.height;
  //   print("HEIGHT:" + height.toString());
  //   setState(() {});
  // }

  _updateCardStatus(String tripid){
    _invitedList.forEach((x){
      if (x.uid == tripid){
        x.routes.status = true;
      }
    });
    _joinList.forEach((x){
      if (x.uid == tripid){
        x.routes.status = true;
      }
    });
    setState((){});
  }

  _deletejoinCard(String tripid){
    int index = -1;
    _joinList.forEach((x){
      if (x.uid == tripid){
       index = _joinList.indexOf(x);
      }
    });
    print(index);
    if (index != -1)  _joinList.removeAt(index);
    setState((){});
  }
  _deleteinviteCard(String tripid){
    int index = -1;
    _invitedList.forEach((x){
      if (x.uid == tripid){
        index = _invitedList.indexOf(x);
      }
    });
    print(index);
    if (index != -1)  _invitedList.removeAt(index);
    setState((){});
  }

  _pageConfig(bool isNeed2Update) async {
    await getData(isNeed2Update);
    socket.off('onAccept');
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onTripEnd');
    socket.off('onKick');

    socket.on('onKick', (data){
      print("onKick");
      _deletejoinCard(data['tripid']);
    });
    socket.on('onTripEnd', (data) {
      _deletejoinCard(data['tripid']);
    });
    socket.on('onRequest', (data) {
      _updateCardStatus(data['tripid']);
    });
    socket.on('onNewMatch' , (data){
      print("onNewMatch");
      _updateCardStatus(data['tripid']);
    });
    socket.on('onNewAccept', (data){
      print("onNewAccept");
      _updateCardStatus(data['tripid']);
    });
    socket.on('onNewMessage',(data){
      print("onNewMessage");
      print(data['tripid']);
      _updateCardStatus(data['tripid']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 2.0,
        child: Icon(Icons.add, color: isJoinPage ? Colors.black : Colors.white),
        onPressed: isJoinPage ? _callJoinMap : _callInviteMap,
        backgroundColor: isJoinPage ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
        heroTag: null,
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: _widgetOptions(),
          ),
          // AppBar
          Card(
            // key: actionKey,
            margin: EdgeInsets.all(0.0),
            color: isJoinPage ? Theme.of(context).colorScheme.darkBlue : Theme.of(context).colorScheme.amber,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)
                ),
            ),
            child: Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          elevation: 0.0,
                          highlightElevation: 0.0,
                          padding: EdgeInsets.all(16.0),
                          color: isJoinPage ? Colors.white : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(
                              color: !isJoinPage ? Colors.white : Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          child: Text(AppLocalizations.instance.text("PaiDuay"), style: TextStyle(color: !isJoinPage ? Colors.white : Colors.black)),
                          onPressed: () {
                            setState(() {
                              isJoinPage = true;
                              if (slidableController.activeState != null) {
                                slidableController.activeState.close();
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: RaisedButton(
                          elevation: 0.0,
                          highlightElevation: 0.0,
                          padding: EdgeInsets.all(16.0),
                          color: isJoinPage ? Colors.transparent : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(
                              color: isJoinPage ? Colors.white : Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          child: Text(AppLocalizations.instance.text("Chuan"), style: TextStyle(color: isJoinPage ? Colors.white : Colors.black)),
                          onPressed: () {
                            setState(() {
                              isJoinPage = false;
                              if (slidableController.activeState != null) {
                                slidableController.activeState.close();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ),
        ],
      )
    );
  }

  Future<void> getData(bool isNeed2Update) async {
    print("get");
    try{
      _invitedList =  await Travel_Info().getRoutes(currentUser.uid,0,isNeed2Update) ?? [];
      _joinList =  await Travel_Info().getRoutes(currentUser.uid,1,isNeed2Update) ?? [];
      _invitedList.sort((a,b) => b.routes.date.compareTo(a.routes.date));
      _joinList.sort((a,b) => b.routes.date.compareTo(a.routes.date));
    }catch(error){
      print("$error lllLLLL");
    }
    setState(() {});
  }

  Widget _widgetOptions(){
    if( _joinList != null && _invitedList != null){
      if((_joinList.isEmpty && isJoinPage) || (_invitedList.isEmpty && !isJoinPage)){
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
    return ListView.separated(
      separatorBuilder: (context, _) {
        return SizedBox(height: 8.0);
      },
      padding: EdgeInsets.fromLTRB(8.0, 88, 8.0, 8.0),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: isJoinPage ? _joinList.length : _invitedList.length,
        itemBuilder: (context, i) {
          return _buildRow(isJoinPage ? _joinList[i] : _invitedList[i]);
        }
    );
  }

  Widget _buildRow(Travel_Info data) {
    print(data);
    return DashboardCardTile(
      data: data,
      controller: slidableController,
      status: data.routes.status,
      onCardPressed: () => _onCardPressed(data),
      onDeletePressed: () async {
        await data.deleteTravel();
        if(data.routes.role == "0"){
          _deleteinviteCard(data.uid);
        }else{
          _deletejoinCard(data.uid);
        }
      },
    );
  }

  _onCardPressed(Travel_Info data) async {
    if( data.routes.role == "1" ){
      if( data.routes.match.isNotEmpty ){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: data.routes.match.first,data: data,))).then((value) async {
          _pageConfig(currentUser.status.navbarTrip);
          currentUser.status.navbarTrip = false;
          await widget.setSate();
        });
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MatchList(data: data))).then((value) async {
            _pageConfig(currentUser.status.navbarTrip);
            currentUser.status.navbarTrip = false;
            await widget.setSate();
        });
      }
    }else{
      if( data.routes.match.isNotEmpty){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: data.uid, data: data))).then((value) async {
          _pageConfig(currentUser.status.navbarTrip);
          currentUser.status.navbarTrip = false;
          await widget.setSate();
        });
      }else{
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ReqList(data: data,isFromMatchinfo: false,))).then((value) async {
          if(value){
            loadingDialog(context,"Please wait...");
            await _pageConfig(currentUser.status.navbarTrip);
            currentUser.status.navbarTrip = false;
            _invitedList.forEach((element) {
              if(element.uid == data.uid){
                Navigator.of(context).pop();
                _onCardPressed(element);
              }
            });
          }else{
            await _pageConfig(currentUser.status.navbarTrip);
            currentUser.status.navbarTrip = false;
            await widget.setSate();
          }
        });
      }
    }
  }

  _callInviteMap() async{
    if(currentUser.vehicle.isEmpty){
      alertDialog(context,
          "No vehicle",
          Text("Please add your vehicle.\nAccount -> Vehicle Management"),
        <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }else{
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreateRoute())).then((value) async {
        _pageConfig(currentUser.status.navbarTrip);
        currentUser.status.navbarTrip = false;
        await widget.setSate();
      });
    }
  }

  _callJoinMap() async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CreateRoute_Join())).then((value) async {
      _pageConfig(currentUser.status.navbarTrip);
      currentUser.status.navbarTrip = false;
      await widget.setSate();
    });
  }
}
