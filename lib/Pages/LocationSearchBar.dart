import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import "package:google_maps_webservice/places.dart" as places;
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:travel_sharing/Pages/InfoFill.dart';

const API_KEY = "AIzaSyBQCf89JOkrq2ECa6Ko8LBQaMO8A7rJt9Q";
//GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: API_KEY);
//
//final searchScaffoldKey = GlobalKey<ScaffoldState>();
//
//Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
//  if (p != null) {
//    // get detail (lat/lng)
//    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
//    final lat = detail.result.geometry.location.lat;
//    final lng = detail.result.geometry.location.lng;
//
//    scaffold.showSnackBar(
//      SnackBar(content: Text("${p.description} - $lat/$lng")),
//    );
//  }
//}
//
//class CustomSearchScaffold extends PlacesAutocompleteWidget {
//  CustomSearchScaffold()
//      : super(
//    apiKey: API_KEY,
//    sessionToken: Uuid().generateV4(),
//    language: "th",
//    components: [Component(Component.country, "th")],
//  );
//
//  @override
//  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
//}
//
//class _CustomSearchScaffoldState extends PlacesAutocompleteState {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: searchScaffoldKey,
//      body: SafeArea(
//        child: Column(
//          children: <Widget>[
//            Card(
//                margin: EdgeInsets.all(8.0),
//                elevation: 2.0,
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(20.0)
//                ),
//                child: AppBarPlacesAutoCompleteTextField()
//            ),
//            Expanded(
//              child: Container(
//                child: PlacesAutocompleteResult(
//                  onTap: (p) {
//                    displayPrediction(p, searchScaffoldKey.currentState);
//                  },
//                  logo: Row(
//                    children: [FlutterLogo()],
//                    mainAxisAlignment: MainAxisAlignment.center,
//                  ),
//                ),
//              ),
//            ),
//          ],
//        ),
//      )
//    );
//  }
//
//  @override
//  void onResponseError(PlacesAutocompleteResponse response) {
//    super.onResponseError(response);
//    searchScaffoldKey.currentState.showSnackBar(
//      SnackBar(content: Text(response.errorMessage)),
//    );
//  }
//
//  @override
//  void onResponse(PlacesAutocompleteResponse response) {
//    super.onResponse(response);
//    if (response != null && response.predictions.isNotEmpty) {
//      searchScaffoldKey.currentState.showSnackBar(
//        SnackBar(content: Text("Got answer")),
//      );
//    }
//  }
//}
//
//class Uuid {
//  final Random _random = Random();
//
//  String generateV4() {
//    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
//    final int special = 8 + _random.nextInt(4);
//
//    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
//        '${_bitsDigits(16, 4)}-'
//        '4${_bitsDigits(12, 3)}-'
//        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
//        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
//  }
//
//  String _bitsDigits(int bitCount, int digitCount) =>
//      _printDigits(_generateBits(bitCount), digitCount);
//
//  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);
//
//  String _printDigits(int value, int count) =>
//      value.toRadixString(16).padLeft(count, '0');
//}

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
  List<Map<String, dynamic>> _placesList;
  List<Map<String, dynamic>> _historyList = [];
  @override
  void initState() {
    super.initState();
    _heading = "History";
    _placesList = _historyList;
    _searchController.addListener(_onSearchChanged);
    debugPrint('${widget.currentLocation}');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
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
        _placesList = _historyList;
      });
      return;
    }

    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String country = 'th';
    String radius = '20000';
    // TODO Add session token

    String request = '$baseURL?input=$input&key=$API_KEY&components=country:$country'
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          margin: EdgeInsets.all(0.0),
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.my_location),
                  SizedBox(width: 8.0),
                  Text('Your location')
                ],
              ),
            ),
            onTap: () {

            },
          ),
        ),
        Card(
          margin: EdgeInsets.all(0.0),
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.location_on),
                  SizedBox(width: 8.0),
                  Text('Choose on map')
                ],
              ),
            ),
            onTap: () {

            },
          ),
        ),
        SizedBox(height: 8.0),
        Card(
          margin: EdgeInsets.all(0.0),
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('History'),
            ),
            onTap: () {

            },
          ),
        ),
      ],
    );
  }

  Widget resultDisplay() {
    return Expanded(
      child: ListView.builder(
        itemCount: _placesList.length,
        itemBuilder: (BuildContext context, int index) =>
            buildPlaceRow(context, index),
      ),
    );
  }

  Widget buildPlaceRow(BuildContext context, int index) {
    return Card(
      margin: EdgeInsets.all(0.0),
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
                            child: Text(_placesList[index]['description'])
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
          Navigator.of(context).pop(_placesList[index]);
        },
      ),
    );
  }
}