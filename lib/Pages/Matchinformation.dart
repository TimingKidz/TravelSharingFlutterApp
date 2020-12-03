import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/ChatFile/chatPage.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:http/http.dart' as Http;

import '../main.dart';

class TripDetails{
  String name;
  String src;
  String dst;
  String routes;
  String match;
  String amount;
  String date;
  String isMatch;
  String Room;

  TripDetails({this.amount, this.date, this.dst, this.isMatch, this.match, this.name, this.Room, this.routes, this.src});

  TripDetails.fromJson(Map<String, dynamic> json){
    name = json['name'];
    src = json['src'];
    dst = json['dst'];
    routes = json['routes'];
    match = json['match'];
    amount = json['amount'];
    date = json['date'];
    isMatch = json['isMatch'];
    Room = json['Room'];
  }

  Future<TripDetails> getDetails(String uid) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/Tripinformation";
      Http.Response response = await Http.post(url, headers: HTTP().header, body: jsonEncode({"_id":uid}));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
          // Map<String,dynamic> data = jsonDecode(response.body);
          // print(data);
          // TripDetails tmp = TripDetails.fromJson(data);
          // return Future.value(tmp);
        }
      }
    }catch(err){
      print(err);
      throw("can't connect Match");
    }
  }
}

class Matchinformation extends StatefulWidget {
  final User currentUser;
  final String uid;

  const Matchinformation({Key key, this.currentUser, this.uid}) : super(key: key);

 _Matchinformation createState() => _Matchinformation();
}

class _Matchinformation extends State<Matchinformation> {
  final TextEditingController date_Textcontroller = new TextEditingController();
  GoogleMapController _mapController;
  Routes Final_Data = new Routes();
  List<Map<String, dynamic>> passengerList = [];
  TripDetails tripDetails;

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
    Map<String, dynamic> test = {
      'name' : 'Thut Chayasatit'
    };
    passengerList.add(test);
    print(widget.uid);
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                            'Thanakrit Tatsamakorn',
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
                            builder: (context) => ChatPage(tripid: widget.uid, currentUser: widget.currentUser)));
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

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: passengerList.length,
        itemBuilder: (context, i) {
          return _buildRow(passengerList[i]);
        }
    );
  }

  Widget _buildRow(Map<String, dynamic> data) {
    print(data);
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 28,
          ),
          SizedBox(width: 16.0),
          Text(
            data['name'],
            style: TextStyle(
                fontSize: 18.0,
            ),
          )
        ],
      ),
    );
  }

}