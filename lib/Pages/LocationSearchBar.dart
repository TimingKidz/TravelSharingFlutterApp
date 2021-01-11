import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/UI/NotificationBarSettings.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';
import 'package:path_provider/path_provider.dart';

class LocationSearch extends StatefulWidget {
  final LatLng currentLocation;
  final String hintText;
  LocationSearch({Key key, @required this.currentLocation, @required this.hintText}) : super(key: key);

  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  TextEditingController _searchController = new TextEditingController();
  Timer _throttle;
  String _heading;
  List<Map<String, dynamic>> _placesList = [];
  List<dynamic> _historyList = [];
  Directory dir ;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _heading = "History";
//    _placesList = _historyList;
    _searchController.addListener(_onSearchChanged);
//    print(_historyList.length);
    getExternalStorageDirectory().then((Directory directory) {
      dir = directory;
      File file = new File(dir.path + "/History.json");
      if(file.existsSync()) _historyList = jsonDecode(file.readAsStringSync());
      else _historyList = [];
      _historyList.forEach((element) {
        print(element['description']);
      });
//      if (fileExists) this.setState(() => fileContent = JSON.decode(jsonFile.readAsStringSync()));
    setState(() {});
    });

    _pageConfig();
  }

  _pageConfig(){
    socket.off('onAccept');
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onTripEnd');
    socket.off('onKick');

    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showNotification(message);
        }
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    notificationBarIconLight();
    super.dispose();
  }

  _onSearchChanged() {
    if (_throttle?.isActive ?? false) _throttle.cancel();
    _throttle = Timer(const Duration(milliseconds: 500), () {
      getLocationResults(_searchController.text);
    });
  }

  void getLocationResults(String input) async {
    if (input.isEmpty) {
      setState(() {
        _heading = "History";
//        _placesList = _historyList;
      });
      return;
    }

    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String country = 'th';
    String radius = '20000';

    String request = '$baseURL?input=$input&key=$api_key&components=country:$country'
        '&location=${widget.currentLocation.longitude},${widget.currentLocation.latitude}&radius=$radius';
    Response response = await Dio().get(request);

    final predictions = response.data['predictions'];

    List<Map<String, dynamic>> _displayResults = [];
    print(predictions);

    for (var i=0; i < predictions.length; i++) {
      String name = predictions[i]['description'];
      _displayResults.add(predictions[i]);
    }

    setState(() {
      _heading = "Results";
      _placesList = _displayResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    notificationBarIconDark();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
                margin: EdgeInsets.all(8.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 15),
                            hintText: widget.hintText
                        ),
                      ),
                    )
                  ],
                )
            ),
            _heading == 'History' ? defaultDisplay() : resultDisplay(),
          ],
        ),
      )
    );
  }

  Widget defaultDisplay() {
    return Expanded(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(),
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.my_location),
                    SizedBox(width: 8.0),
                    Text(AppLocalizations.instance.text("curLocate"))
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(false);
              },
            ),
          ),
          Card(
            margin: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(),
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.location_on),
                    SizedBox(width: 8.0),
                    Text(AppLocalizations.instance.text("ChooseOnMap"))
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(),
              margin: EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(AppLocalizations.instance.text("RoutesHistory")),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _historyList.length,
                      itemBuilder: (BuildContext context, int index) =>
                          buildPlaceRow(context, _historyList[index]),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultDisplay() {
    return Expanded(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: _placesList.length,
        itemBuilder: (BuildContext context, int index) =>
            buildPlaceRow(context, _placesList[index]),
      ),
    );
  }

  Widget buildPlaceRow(BuildContext context, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(),
      child: InkWell(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                            child: Text(data['description'])
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          File file = new File(dir.path + "/History.json");
          file.createSync();
          int i = -1;
          _historyList.forEach((element) {
            if (element["place_id"] == data["place_id"]){
              print(element["description"]);
              i = _historyList.indexOf(element);
            }
          });
          if (i != -1 ) _historyList.removeAt(i);
          if (_historyList.length >= 10) _historyList.removeRange(9, _historyList.length);
          _historyList.insert(0, data);
          file.writeAsStringSync(jsonEncode(_historyList));
//          storage.setItem('history', _historyList);
          Navigator.of(context).pop(data);
        },
      ),
    );
  }
}