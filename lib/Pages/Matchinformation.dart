import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/ChatFile/chatPage.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Class/TripDetails.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Pages/ReqList.dart';
import 'package:travel_sharing/UI/ProfileInfo.dart';
import 'package:travel_sharing/buttons/VehicleCardTileMin.dart';
import 'package:travel_sharing/main.dart';

class Matchinformation extends StatefulWidget {
  final String uid;
  final Travel_Info data;
  const Matchinformation({Key key,this.uid, this.data}) : super(key: key);
 _Matchinformation createState() => _Matchinformation();
}

class _Matchinformation extends State<Matchinformation> {
  final TextEditingController date_Textcontroller = new TextEditingController();
  Routes Final_Data = new Routes();
  List<Map<String, dynamic>> passengerList = [];
  TripDetails tripDetails;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Future<void> getData() async {
    try{
      tripDetails =  await TripDetails().getDetails(widget.uid,widget.data.uid);
      print(tripDetails.hostUser.vehicle.first.toJson());
      setState(() {});
    }catch(error){
      print("$error tttashgahsdajsdadkajdak");
    }
  }

  @override
  void initState() {
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
    socket.on('onNewAccept', (data) async => await getData());
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
    if (tripDetails == null ){
      return Scaffold(
          appBar: AppBar(
            title: Text('Trip Details'),
          ),
          body: Stack(
            children: <Widget>[
              Container(
                alignment : Alignment.center,
                margin: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16.0),
                    Text("Loading..."),
                  ],
                ),
              ),
            ],
          )
      );
    }else{
      return Scaffold(
          appBar: AppBar(
            title: Text('Trip Details'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.chat),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ChatPage(tripid: widget.uid,currentTripid: widget.data.uid,))).then((value){
                        _pageConfig();
                  });
                },
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Card(
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
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              tripDetails.hostUser.name,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                ),
                SizedBox(height: 4.0),
                VehicleCardTileMin(data: tripDetails.hostUser.vehicle.first),
                SizedBox(height: 8.0),
                Expanded(
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                if(currentUser.uid == tripDetails.hostUser.uid && tripDetails.routes.isMatch == false)
                                  ClipOval(
                                    child: Material(
                                      child: InkWell(
                                        child: SizedBox(width: 28, height: 28, child: Icon(Icons.add)),
                                        onTap: () {
                                          Navigator.pushReplacement(context, MaterialPageRoute(
                                              builder: (context) => ReqList(data: widget.data))).then((value){
                                            _pageConfig();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // SizedBox(height: 16.0),
                          Expanded(
                            child: _buildListView(),
                          )
                        ],
                      ),
                  ),
                ),
                SizedBox(height: 8.0),
                if(currentUser.uid == tripDetails.hostUser.uid )
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
              ],
            ),
          ),
      );
    }
  }

  Future<void> _showDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("This action couldn't be undone"),
                Text('Would you like to end this trip?'),
              ],
            ),
          ),
          actions: <Widget>[
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
        );
      },
    );
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
        itemCount: tripDetails.subUser.length,
        itemBuilder: (context, i) {
          return _buildRow(tripDetails.subUser[i],tripDetails.subRoutes[i]);
        }
    );
  }

  Widget _buildRow(User user,Routes routes) {
    return InkWell(
      onTap: (){
        swipeUpDialog(context, ProfileInfo(data: user));
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
            ),
            SizedBox(width: 16.0),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

}