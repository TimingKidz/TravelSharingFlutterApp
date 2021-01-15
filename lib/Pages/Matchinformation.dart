import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/ChatFile/chatPage.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/TripDetails.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Pages/ReqList.dart';
import 'package:travel_sharing/UI/ProfileInfo.dart';
import 'package:travel_sharing/buttons/VehicleCardTileMin.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
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

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isHistory = widget.isHistory == null ? false : widget.isHistory;
    _pageConfig(widget.data.routes.status);
  }

  _pageConfig(bool isNeed2Update){
    getData(isNeed2Update);
    socket.off('onAccept');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onNewNotification');
    socket.off('onTripEnd');
    socket.off('onKick');

    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });

    socket.on('onKick', (data) async {
      print("onkick");
      if (widget.data.uid == data['tripid']) {
        await getData(true);
      }
    });

    socket.on('onNewAccept', (data) async {
      print("onNewAccecpt");
      if (widget.data.uid == data['tripid']) {
        await getData(true);
      }
    });

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
                                      tooltip: "back",
                                      iconSize: 26.0,
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.of(context).maybePop();
                                      },
                                    ),
                                    SizedBox(width: 16.0),
                                    Text(
                                      "ข้อมูลการเดินทาง",
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
                                  tooltip: "Group chat",
                                  iconSize: 26.0,
                                  color: Colors.white,
                                  onPressed: (){
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
                                        Column(
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
                                            Text(
                                                tripDetails.routes.vehicle.brand +
                                                    " " +
                                                    tripDetails.routes.vehicle.model +
                                                    " | " +
                                                    tripDetails.routes.vehicle.license
                                            )
                                          ],
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
      // SizedBox(height: 8.0),
      Card(
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
                    'Passenger List',
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
                  child: CircularProgressIndicator(strokeWidth: 2,valueColor: AlwaysStoppedAnimation(Colors.white),),
                ),
                SizedBox(width: 8.0),
                Text(isEndTrip ? 'Loading...':'End Trip', style: TextStyle(color: Colors.white,))
              ],
            ),
            onPressed: () => isEndTrip ? null : alertDialog(
              this.context,
              'Are you sure',
              Text("This action couldn't be undone. Would you like to end this trip ?"),
              <Widget>[
                FlatButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Yes'),
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
            return _buildRow(tripDetails.subUser[i-1],tripDetails.subRoutes[i-1]);
          }
        }
    );
  }

  Widget _buildRow(User user,Routes routes) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2.0),
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
    _createMarkers();
    setState(() {});
    }catch(error){
      print("$error from Matchinfo");
    }
  }

  kickOut(User user,Routes routes ) async {
    await tripDetails.kickOut(user.uid,routes.uid,"ขอโทษครับ");
    await getData(false);
  }

  // find direction to destination
  findDirections(bool isFind_Direction ) async {
    // create line of routes on map
    var line = Polyline(
      points: tripDetails.routes.routes,
      geodesic: true,
      polylineId: PolylineId("mejor ruta"),
      color: Colors.blue,
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
        ),
      );
      Markers.add(
        Marker(
          markerId: MarkerId("2"),
          position: tripDetails.subRoutes[i].routes.last,
          infoWindow: InfoWindow(title: "src : ${tripDetails.subUser[i].name}"),
        ),
      );
    }
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) async{
    _mapController = controller;
    await _centerView(true);
  }

  _centerView(bool isFind_Direction ) async {
    await _mapController.getVisibleRegion();
    await findDirections(isFind_Direction);

    Routes temp = widget.data.routes;
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