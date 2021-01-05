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
  bool isHistory;

  GoogleMapController _mapController;
  Set<Polyline> lines = Set();
  List<LatLng> temp = List();
  Set<Marker> Markers = Set();
  LatLngBounds bounds;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Future<void> getData(bool isNeed2Update) async {
    try{
      if(!isHistory) tripDetails =  await TripDetails().getDetails(widget.uid,widget.data.uid,isNeed2Update);
      else tripDetails =  await TripDetails().getHistory(widget.uid);
      print(tripDetails.hostUser.vehicle.first.toJson());
      setState(() {});
    }catch(error){
      print("$error tttashgahsdajsdadkajdak");
    }
  }

  @override
  void initState() {
    super.initState();
    isHistory = widget.isHistory == null ? false : widget.isHistory;
    _createMarkers();
    _pageConfig(widget.data.routes.status);
  }



  _pageConfig(bool isNeed2Update){
    getData(isNeed2Update);
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
    socket.on('onNewAccept', (data) async => await getData(true));
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if( message['data']['page'] != '/MatchInformation' ){
            print("onMessage: $message");
            showNotification(message);
          }
        }
    );
  }


  @override
  void dispose() {
    socket.off('onNewAccept');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(tripDetails == null)
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    return Scaffold(
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
                                    onPressed: () => Navigator.of(context).pop(),
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
                                      CircleAvatar(
                                        radius: 32,
                                        child: ClipOval(
                                          child: Image.network(
                                            "${httpClass.API_IP}${tripDetails.hostUser.imgpath}",
                                          ),
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
                                            tripDetails.hostUser.vehicle.first.brand +
                                                " " +
                                                tripDetails.hostUser.vehicle.first.model +
                                              " | " +
                                                tripDetails.hostUser.vehicle.first.license
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
          // TODO: Add MAP
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
            child: Text('End Trip', style: TextStyle(color: Colors.white,)),
            onPressed: () => normalDialog(
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
                  onPressed: () {
                    endTrip();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
    ];
  }

  endTrip() async {
    List<Map<String,dynamic>> subuser = List();
    for(int i = 0 ; i<tripDetails.subUser.length ;i++){
      subuser.add({"user_id":tripDetails.subUser[i].uid,"trip_id":tripDetails.subRoutes[i].uid});
    }
    Map<String,dynamic> tmp = {
      "hostuser_trip_id" : widget.uid,
      "hostuser_id" : tripDetails.hostUser.uid
    };
    tmp['subuser'] = subuser;
    User().endTrip(tmp).then((value){
      print(value);
      Navigator.of(context).pop();
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
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => ReqList(data: widget.data))).then((value){
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
              color: Colors.transparent,
              child: Ink.image(
                image: NetworkImage(
                    "${httpClass.API_IP}${user.imgpath}"
                ),
                fit: BoxFit.cover,
                width: 64.0,
                height: 64.0,
                child: InkWell(
                  onTap: () {
                    swipeUpDialog(context, ProfileInfo(data: user, isHost: currentUser.uid == tripDetails.hostUser.uid, kickFunct: () => kickOut(user,routes)));
                  },
                ),
              ),
            ),
          )
        ),
        SizedBox(width: 8.0)
      ],
    );
  }

  kickOut(User user,Routes routes ) async {
    print("Kick out ${user.uid} ${routes.uid}");
    await tripDetails.kickOut(user.uid,routes.uid,"ขอโทษครับ");
    await getData(false);
  }
  // find direction to destination
  findDirections(bool isFind_Direction ) async {
    // create line of routes on map
    var line = Polyline(
      points: widget.data.routes.routes,
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
    Markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: widget.data.routes.routes.first,
        infoWindow: InfoWindow(title: "Roca 123"),
      ),
    );
    Markers.add(
      Marker(
        markerId: MarkerId("2"),
        position: widget.data.routes.routes.last,
        infoWindow: InfoWindow(title: "Roca 123"),
      ),
    );
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