import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/ChatFile/chatPage.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/TripDetails.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Pages/ReqList.dart';
import 'package:travel_sharing/UI/ProfileInfo.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';

class Matchinformation extends StatefulWidget {
  final String uid;
  final Travel_Info data;
  final bool isHistory;
  const Matchinformation({Key key,this.uid, this.data, this.isHistory}) : super(key: key);
 _Matchinformation createState() => _Matchinformation();
}

class _Matchinformation extends State<Matchinformation> {
  final TextEditingController date_Textcontroller = new TextEditingController();
  Routes Final_Data = new Routes();
  List<Map<String, dynamic>> passengerList = [];
  TripDetails tripDetails;
  GoogleMapController _mapController;
  Set<Polyline> lines = Set();
  List<LatLng> temp = List();
  Set<Marker> Markers = Set();
  LatLngBounds bounds;
  bool isEndTrip = false;
//  String uid;
//  Travel_Info Data;
  bool isHistory;
  List<Map<String,BitmapDescriptor>> markerSet = List();
  List<Color> colors = List();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    isHistory = widget.isHistory == null ? false : widget.isHistory;
    _pageConfig(widget.data.routes.status);
    colors = [Color(0xFFFFF100),Color(0xFFFF8C00),Color(0xFFE81123),Color(0xFFEC008C)];
  }

  _pageConfig(bool isNeed2Update){
    getData(isNeed2Update);
    if( !isHistory ){
      socket.off('onAccept');
      socket.off('onNewAccept');
      socket.off('onNewMatch');
      socket.off('onNewMessage');
      socket.off('onRequest');
      socket.off('onNewNotification');
      socket.off('onTripEnd');
      socket.off('onKick');


      socket.on('onTripEnd', (data) {
        if (widget.data.uid == data['tripid']) {
          if(mounted) {
            unPopDialog(
              this.context,
              AppLocalizations.instance.text("tripClose"),
              Text(AppLocalizations.instance.text("tripCloseDes")),
              <Widget>[
                FlatButton(
                  child: Text(AppLocalizations.instance.text("ok")),
                  onPressed: () async {
                    Navigator.popUntil(context, ModalRoute.withName('/homeNavigation'));
                  },
                ),
              ],
            );
          }

        }
      });

      socket.on('onNewNotification', (data) {
        currentUser.status.navbarNoti = true;
      });

      socket.on('onKick', (data) async {
        print("onkick");
        if (widget.data.uid == data['tripid']) {
          if(widget.data.uid == data['kick']){
            if(mounted) {
              unPopDialog(
                this.context,
                AppLocalizations.instance.text("tripRM"),
                Text(AppLocalizations.instance.text("tripRMDes")),
                <Widget>[
                  FlatButton(
                    child: Text(AppLocalizations.instance.text("ok")),
                    onPressed: () async {
                      Navigator.popUntil(context, ModalRoute.withName('/homeNavigation'));
                    },
                  ),
                ],
              );
            }
          }else{
            await getData(true);
          }
        }
      });

      socket.on('onNewAccept', (data) async {
        print("onNewAccecpt");
        if (widget.data.uid == data['tripid']) {
          await getData(true);
        }
      });
    }
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if(  (message['data']['tag'] != widget.data.uid && message['data']['page'] == '/MatchInformation') ||  message['data']['page'] != '/MatchInformation' ){
            print("onMessage: $message");
            showNotification(message);
          }
        }
    );
  }


  @override
  void dispose() {
//    socket.off('onNewAccept');
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        socket.off('onTripEnd');
        socket.off('onKick');
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        if(isHistory)  Navigator.of(context).pop();
          else Navigator.popUntil(context, ModalRoute.withName('/homeNavigation'));
        return false;
      },
      child: tripDetails == null
        ? Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      )
      : Scaffold(
          body: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 210, left: 8.0, right: 8.0),
                child: Column(
                  children: listView(),
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
                  padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 8.0, right: 4.0),
                  child: SafeArea(
                    child: Wrap(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_back),
                                      tooltip: AppLocalizations.instance.text("back"),
                                      iconSize: 26.0,
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.of(context).maybePop();
                                      },
                                    ),
                                    SizedBox(width: 16.0),
                                    Text(
                                      AppLocalizations.instance.text("InfoFormTitle"),
                                      style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.white,
                                      ),
                                      // textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.chat_bubble),
                                  tooltip: AppLocalizations.instance.text("groupChat"),
                                  iconSize: 26.0,
                                  color: Colors.white,
                                  onPressed: (){
                                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ChatPage(tripid: widget.uid,currentTripid: widget.data.uid, isHistory: isHistory))).then((value){
                                      _pageConfig(false);
                                    });
                                  },
                                ),
                              ],
                            ),
                            Card(
                                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)
                                ),
                                child: InkWell(
                                  onTap: (){
                                    swipeUpDialog(this.context, ProfileInfo(data: tripDetails.hostUser));
                                  },
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Material(
                                          shape: CircleBorder(),
                                          clipBehavior: Clip.antiAlias,
                                          color: Colors.grey,
                                          child: ClipOval(
                                              child: Container(
                                                width: 64.0,
                                                height: 64.0,
                                                child: tripDetails.hostUser.imgpath != null
                                                    ? Ink.image(image: Image.network("${httpClass.API_IP}${tripDetails.hostUser.imgpath}").image)
                                                    : Icon(Icons.person, color: Colors.white, size: 32.0),
                                              )
                                          ),
                                        ),
                                        SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tripDetails.hostUser.name,
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              SizedBox(height: 8.0),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      padding: EdgeInsets.only(right: 8.0),
                                                      child: Text(
                                                        "${tripDetails.routes.vehicle.brand} ${tripDetails.routes.vehicle.model}",
                                                        // overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        border: Border.all(color: Colors.black)
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Vehicle().getTypeIcon(tripDetails.routes.vehicle.type, 64),
                                                        SizedBox(width: 4.0),
                                                        Text("${tripDetails.routes.vehicle.license}"),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
      )
    );
  }

  List<Widget> listView() {
    return [
      // VehicleCardTileMin(data: tripDetails.hostUser.vehicle.first, cardMargin: 4.0),
      detailsWidget(),
      SizedBox(height: 8.0),
      Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    AppLocalizations.instance.text("passengerTitle"),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 16.0),
            Container(
              height: 72,
              child: _buildListView(),
            )
          ],
        ),
      ),
      SizedBox(height: 8.0),
      Expanded(
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(16.294922,100.928026),
                zoom: 5,
              ),
              markers: Markers,
              polylines: lines,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
//            onCameraMove: center,
            ),
          ),
        ),
      ),
      SizedBox(height: 8.0),
      if(currentUser.uid == tripDetails.hostUser.uid && !isHistory)
        Container(
          width: double.infinity,
          child: RaisedButton(
            highlightElevation: 0.0,
            padding: EdgeInsets.all(16.0),
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(isEndTrip)
                SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(strokeWidth: 2,valueColor: AlwaysStoppedAnimation(Colors.white)),
                ),
                SizedBox(width: 8.0),
                Text(isEndTrip ? AppLocalizations.instance.text("loading"):AppLocalizations.instance.text("endTrip"), style: TextStyle(color: Colors.white))
              ],
            ),
            onPressed: () => isEndTrip ? null : alertDialog(
              this.context,
              AppLocalizations.instance.text("delTripDialogTitle"),
              Text(AppLocalizations.instance.text("delTripDialogDes")),
              <Widget>[
                FlatButton(
                  child: Text(AppLocalizations.instance.text("no")),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(AppLocalizations.instance.text("yes")),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    isEndTrip = true;
                    setState(() { });
                    await endTrip();
                  },
                ),
              ],
            ),
          ),
        ),
      SizedBox(height: 16.0),
    ];
  }

  Widget detailsWidget(){
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      child: Container(
          padding: EdgeInsets.all(16.0),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.instance.text("dst"), style: TextStyle(fontSize: 10.0)),
                          SizedBox(height: 4.0),
                          Text(tripDetails.routes.dst, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.0),
                          Text(AppLocalizations.instance.text("src"), style: TextStyle(fontSize: 10.0)),
                          SizedBox(height: 4.0),
                          Text(tripDetails.routes.src, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                            10.0)
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          DateManage().datetimeFormat("day", widget.data.routes.date) + " " + DateManage().datetimeFormat("month", widget.data.routes.date),
                          style: TextStyle(
                              fontSize: 10.0
                          ),
                        ),
                        Text(DateManage().datetimeFormat("time", widget.data.routes.date))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }

  Future<void> endTrip() async {
    List<Map<String,dynamic>> subuser = List();
    for(int i = 0 ; i<tripDetails.subUser.length ;i++){
      subuser.add({"user_id":tripDetails.subUser[i].uid,"trip_id":tripDetails.subRoutes[i].uid});
    }
    Map<String,dynamic> tmp = {
      "hostuser_trip_id" : widget.uid,
      "hostuser_id" : tripDetails.hostUser.uid
    };
    tmp['subuser'] = subuser;

   currentUser.endTrip(tmp).then((value){
     ScaffoldMessenger.of(context).removeCurrentSnackBar();
        if(value)
          Navigator.popUntil(context, ModalRoute.withName('/homeNavigation'));
        else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not End Trip.")));
    });
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: tripDetails.subUser.length + 1,
        itemBuilder: (context, i) {
          if(i == 0){
            if(currentUser.uid == tripDetails.hostUser.uid && tripDetails.routes.isMatch == false && !isHistory){
              return Container(
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: ClipOval(
                  child: Material(
                    child: InkWell(
                      child: SizedBox(width: 64, height: 64, child: Icon(Icons.add)),
                      onTap: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ReqList(data: widget.data,isFromMatchinfo: true,))).then((value){
                          _pageConfig(false);
                        });
                      },
                    ),
                  ),
                ),
              );
            }else{
              return SizedBox(width: 8.0);
            }
          }else{
            return _buildRow(tripDetails.subUser[i-1],tripDetails.subRoutes[i-1],colors[i]);
          }
        }
    );
  }


  Widget _buildRow(User user,Routes routes,Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2.0),
              shape: BoxShape.circle,
            ),
            child: Material(
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: Colors.grey,
              child: InkWell(
                  onTap: () {
                    swipeUpDialog(context, ProfileInfo(data: user, isHost: currentUser.uid == tripDetails.hostUser.uid, kickFunct :() => kickOut(user,routes) ));
                  },
                  child: ClipOval(
                    child: Container(
                        width: 64.0,
                        height: 64.0,
                        child: user.imgpath != null
                            ? Ink.image(image: NetworkImage("${httpClass.API_IP}${user.imgpath}"))
                            : Icon(Icons.person, color: Colors.white, size: 32.0)
                    ),
                  )
              ),
            )
            // Material(
            //   shape: CircleBorder(),
            //   clipBehavior: Clip.antiAlias,
            //   color: Colors.transparent,
            //   child: Ink.image(
            //     image: NetworkImage(
            //         "${httpClass.API_IP}${user.imgpath}"
            //     ),
            //     fit: BoxFit.cover,
            //     width: 64.0,
            //     height: 64.0,
            //     child: InkWell(
            //       onTap: () {
            //         swipeUpDialog(context, ProfileInfo(data: user, isHost: currentUser.uid == tripDetails.hostUser.uid, kickFunct :() => kickOut(user,routes) ));
            //       },
            //     ),
            //   ),
            // ),
          )
        ),
        SizedBox(width: 8.0)
      ],
    );
  }

  Future<void> getData(bool isNeed2Update) async {
    try{
    if(!isHistory) tripDetails =  await TripDetails().getDetails(widget.uid,widget.data.uid,isNeed2Update);
    else tripDetails =  await TripDetails().getHistory(widget.uid);
    for ( int x = 0 ; x < 4 ; x++) {
      BitmapDescriptor src = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/marker/color_${x+1}.png');
      BitmapDescriptor dst = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/marker/dst_color_${x+1}.png');
      markerSet.add({"src" : src , "dst" : dst });
    }
    if(tripDetails != null) _createMarkers();
    setState(() {});
    }catch(error){
      print("$error from Matchinfo");
    }
  }

  kickOut(User user,Routes routes ) async {
    // TODO: User description for kick.
    await tripDetails.kickOut(user.uid,routes.uid,"ขอโทษครับ").then((value)async{
      if(value){
        await getData(false);
      }else{
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not remove.")));
      }
    });

  }

  // find direction to destination
  findDirections(bool isFind_Direction ) async {
    // create line of routes on map
    var line = Polyline(
      points: tripDetails.routes.routes,
      geodesic: true,
      polylineId: PolylineId("mejor ruta"),
      color: Theme.of(context).accentColor.withOpacity(0.5),
      width: 4,
    );
    setState(() {
      lines.clear();
      lines.add(line);
    });
  }

  _createMarkers() {
    Markers.clear();
    for(int i = 0 ; i<tripDetails.subRoutes.length ; i++){
      Markers.add(
        Marker(
          markerId: MarkerId("1"),
          position: tripDetails.subRoutes[i].routes.first,
          infoWindow: InfoWindow(title:"dst : ${tripDetails.subUser[i].name}"),
          icon : markerSet[i]['src']
        ),
      );
      Markers.add(
        Marker(
          markerId: MarkerId("2"),
          position: tripDetails.subRoutes[i].routes.last,
          infoWindow: InfoWindow(title: "src : ${tripDetails.subUser[i].name}"),
          icon: markerSet[i]['dst']
        ),
      );
    }
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) async{
    print(markerSet.length);
    _mapController = controller;
    await _centerView(true);
  }

  _centerView(bool isFind_Direction ) async {
    await _mapController.getVisibleRegion();
    await findDirections(isFind_Direction);

    Routes temp = tripDetails.routes;
    var left = min(temp.routes.first.latitude, temp.routes.last.latitude);
    var right = max(temp.routes.first.latitude, temp.routes.last.latitude);
    var top = max(temp.routes.first.longitude, temp.routes.last.longitude);
    var bottom = min(temp.routes.first.longitude, temp.routes.last.longitude);

    lines.first.points.forEach((point) {
      left = min(left, point.latitude);
      right = max(right, point.latitude);
      top = max(top, point.longitude);
      bottom = min(bottom, point.longitude);
    });
    bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.moveCamera(cameraUpdate);
  }
}