import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/ChatFile/chatPage.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/TripDetails.dart';
import 'package:travel_sharing/Class/User.dart';

class Matchinformation extends StatefulWidget {
  final String uid;
  const Matchinformation({Key key,this.uid}) : super(key: key);
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
      tripDetails =  await TripDetails().getDetails(widget.uid);
      setState(() {});
    }catch(error){
      print("$error ttt");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }



  @override
  Widget build(BuildContext context) {
    if (tripDetails == null ){
      return Scaffold(
          appBar: AppBar(
//          automaticallyImplyLeading: false,
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
                    Text("Signing in..."),
                  ],
                ),
              ),
            ],
          )
      );
    }else{
      return Scaffold(
          appBar: AppBar(
//          automaticallyImplyLeading: false,
            title: Text('Trip Details'),
          ),
          body: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      ),
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
                    ),
                    SizedBox(height: 4.0),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.motorcycle),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Motorcycle',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 4.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Text('ทะเบียน', style: TextStyle(color: Colors.black.withOpacity(0.7)),),
                                      Text('1กณ 8698 ชร.')
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text('ยี่ห้อ', style: TextStyle(color: Colors.black.withOpacity(0.7)),),
                                      Text('Honda')
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text('รุ่น', style: TextStyle(color: Colors.black.withOpacity(0.7)),),
                                      Text('Moove')
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text('สี', style: TextStyle(color: Colors.black.withOpacity(0.7)),),
                                      Text('ส้ม-ดำ')
                                    ],
                                  )
                                ],
                              ),
                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Expanded(
                      child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Passenger List',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Expanded(
                                  child: _buildListView(),
                                )
                              ],
                            ),
                          )
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: FloatingActionButton(
                        heroTag: null,
                        child: Icon(Icons.add),
                        tooltip: 'Request List',
                        onPressed: () {

                        },
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FloatingActionButton(
                        heroTag: null,
                        child: Icon(Icons.map),
                        tooltip: 'Route Map',
                        onPressed: () {

                        },
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FloatingActionButton(
                        heroTag: null,
                        child: Icon(Icons.message),
                        tooltip: 'Chat',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ChatPage(tripid: widget.uid)));
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
      );
    }
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
    return Container(
      padding: EdgeInsets.all(8.0),
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
    );
  }

}