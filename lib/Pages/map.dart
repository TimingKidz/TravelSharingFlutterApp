import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as l;
import 'package:location/location.dart' ;
import "package:google_maps_webservice/places.dart" as p;
import 'package:reorderables/reorderables.dart';
import 'package:travel_sharing/Class/NearbyPlace.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Pages/LocationSearchBar.dart';
import 'package:travel_sharing/Pages/InfoFill.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';

class CreateRoute extends StatefulWidget {
  final Routes data;
  const CreateRoute({Key key, this.data}) : super(key: key);
  @override
  _CreateRoutestate createState() => _CreateRoutestate();
}

class _CreateRoutestate extends State<CreateRoute> {
  static int Role = 0;
  final l.Distance distance = new l.Distance();
  final TextEditingController src_Textcontroller = new TextEditingController();
  final TextEditingController dst_Textcontroller = new TextEditingController();
  p.GoogleMapsPlaces _places = p.GoogleMapsPlaces(apiKey: api_key);
  GoogleMapController _mapController;
  bool isSet_Marker = false;
  LatLng Marker_Location;
  bool is_src = true;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<String,LatLng> Map_Latlng = <String,LatLng>{};
  Map<String,String> Map_Placename = <String,String>{};
  bool isChooseOnMap = false;
  bool isSelected = false;
  bool isWantCustom = false;
  bool isPreview = false;
  Set<Polyline> lines = Set();
  Set<Marker> mark = Set();
  Set<Polyline> finalLines = Set();
  int pointNo = 0;
  int i = 0;
  Location location = Location();
  List<LatLng> wayPoint = List();
  List<LatLng> tmp = List();
  StreamSubscription<LocationData> locationSubscription;
  LatLngBounds bounds;
  List<BitmapDescriptor> markerSet = List();
  bool previewBut = true;
  bool backBut = true;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  @override
  void dispose() {
   _mapController.dispose();
    src_Textcontroller.dispose();
    dst_Textcontroller.dispose();
    locationSubscription.cancel();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _pageConfig();
    getLocation();
  }

  void selectedMethod(dynamic result){
    if(result != null) {
      if ( result is Map<String,dynamic>) _Searchbar(result);
      if ( result is bool ) {
        if (result) {
          isChooseOnMap = true;
        }else {
          Src_OR_Dst(current_Location, AppLocalizations.instance.text("curLoc"), is_src);
          _mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: current_Location, zoom: 18)));
        }
      }
    }
    setState(() { });
    print(isChooseOnMap);
  }

//------------------------------------ UI---------------------------------------
  @override
  Widget build(BuildContext context) {
    if(current_Location == null){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        if (backBut) {
          if (isChooseOnMap) {
            setState(() {
              isChooseOnMap = false;
            });
            return false;
          }else{
            if(!isSelected) return true;
            else {
              backBut = false;
              await _Fin();
              isPreview = true;
              setState(() {
                isWantCustom = false;
                isSelected = false;
                backBut = true;
              });
              return false;
            }
          }
        }else{
          return false;
        }
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target:current_Location,
                zoom: 15,
              ),
              markers: isSelected ? Set<Marker>.of(_markers.values).union(mark) : Set<Marker>.of(_markers.values) ,
              polylines: isSelected ? lines : finalLines,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
//              onCameraIdle: OnMove_End ,
              onCameraMove: center,
              mapToolbarEnabled: !isSelected,
            ),
            if(isChooseOnMap)
              Positioned.fill(
                bottom: 20,
                child: Center(
                  child: Icon(Icons.place, size: 40.0, color: Colors.red),
                ),
              ),
            Card(
              margin: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)
                  )
              ),
              child: Container(
                  padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, isChooseOnMap ? 16.0 : 2.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0)
                      )
                  ),
                  // color: Theme.of(context).primaryColor,
                  child: Wrap(
                    children: <Widget>[
                      SafeArea(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: isChooseOnMap ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  tooltip: AppLocalizations.instance.text("back"),
                                  iconSize: 26.0,
                                  color: Colors.white,
                                  onPressed: () => Navigator.of(context).maybePop(),
                                ),
                                SizedBox(width: 8.0),
                                if(isChooseOnMap)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.0),
                                    child: Text(
                                      AppLocalizations.instance.text("ChooseOnMap"),
                                      style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.white,
                                      ),
                                      // textAlign: TextAlign.center,
                                    ),
                                  ),
                                if (!isSelected && !isChooseOnMap)
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Icon(Icons.location_searching, color: Colors.white),
                                            Expanded(
                                              child: Card(
                                                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                                                elevation: 2.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0)
                                                ),
                                                child: TextFormField(
                                                  readOnly: true,
                                                  controller: src_Textcontroller,
                                                  cursorColor: Colors.black,
                                                  keyboardType: TextInputType.text,
                                                  onTap: (){
                                                    is_src = true;
                                                    isChooseOnMap = false;
                                                    isPreview = false;
                                                    finalLines.clear();
                                                    wayPoint.clear();
                                                    tmp.clear();
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) => LocationSearch(currentLocation: current_Location, hintText: "จุดเริ่มต้น ...")
                                                        )
                                                    ).then((result) {
                                                     selectedMethod(result);
                                                    });
                                                  },
                                                  textInputAction: TextInputAction.go,
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                      EdgeInsets.symmetric(horizontal: 15),
                                                      hintText: AppLocalizations.instance.text("SrcPoint")
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: <Widget>[
                                            Icon(Icons.location_on, color: Colors.white),
                                            Expanded(
                                              child: Card(
                                                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                                                elevation: 2.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0)
                                                ),
                                                child: TextFormField(
                                                  readOnly: true,
                                                  controller: dst_Textcontroller,
                                                  cursorColor: Colors.black,
                                                  keyboardType: TextInputType.text,
                                                  onTap: (){
                                                    is_src = false;
                                                    isChooseOnMap = false;
                                                    isPreview = false;
                                                    finalLines.clear();
                                                    wayPoint.clear();
                                                    tmp.clear();
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) => LocationSearch(currentLocation: current_Location, hintText: "จุดปลายทาง ...")
                                                        )
                                                    ).then((result) {
                                                     selectedMethod(result);
                                                    });
                                                  },
                                                  textInputAction: TextInputAction.go,
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                      EdgeInsets.symmetric(horizontal: 15),
                                                      hintText: AppLocalizations.instance.text("DstPoint")
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                if(isSelected && !isChooseOnMap)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
                                      child: SizedBox(
                                        height: 64,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20.0),
                                          child: _buildListView(),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if(!isSelected && !isChooseOnMap)
                              Container(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Switch(
                                          value: isWantCustom,
                                          onChanged: (bool value){
                                            setState(() {
                                              isWantCustom = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          AppLocalizations.instance.text("addPoint"),
                                          style: TextStyle(
                                              color: Colors.white
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: (){
                                        normalDialog(
                                          context,
                                          Wrap(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 8.0),
                                                          child: Text(AppLocalizations.instance.text("tips"), style: Theme.of(context).textTheme.subtitle1),
                                                        ),
                                                        SizedBox(
                                                          height: 36,
                                                          width: 36,
                                                          child: Material(
                                                            elevation: 2,
                                                            color: Colors.white,
                                                            shape: CircleBorder(),
                                                            clipBehavior: Clip.antiAlias,
                                                            child: InkWell(
                                                              onTap: () => Navigator.of(context).pop(),
                                                              child: Icon(Icons.clear),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                                                      child: Text(AppLocalizations.instance.text("addPointTips")),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        );
                                      },
                                      icon: Icon(Icons.info, color: Colors.white),
                                    )
                                  ],
                                ),
                              )
                          ],
                        ),
                      )
                    ],
                  )
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.bottomCenter,
              child:
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if( isChooseOnMap )
                      FloatingActionButton.extended(
                        elevation: 1,
                        label: Text(AppLocalizations.instance.text("ok")),
                        onPressed: () async {
                          if(isSelected){
                            createRoute(Marker_Location);
                            _drawLine();
                            isChooseOnMap = false;
                          }else{
                            await OnMove_End();
                            isChooseOnMap = false;
                            setState(() { });
                          }
                        },
                        heroTag: null,
                      ),
                    if( Map_Latlng["src"] != null && Map_Latlng["dst"] != null && !isChooseOnMap && isWantCustom)
                      FloatingActionButton.extended(
                        elevation: 1,
                        icon: Icon(Icons.arrow_forward_sharp),
                        label: Text(AppLocalizations.instance.text("next")),
                        onPressed: (){
                          previewBut = true;
                          isPreview = false;
                          isChooseOnMap = false;
                          isWantCustom = false;
                          _drawLine();
                        },
                        heroTag: null,
                      ),
                    if( Map_Latlng["src"] != null && Map_Latlng["dst"] != null && !isChooseOnMap && !isWantCustom && !isPreview)
                      FloatingActionButton.extended(
                        elevation: 1,
                        icon: Icon(Icons.check),
                        label: Text(AppLocalizations.instance.text("preview")),
                        onPressed: () async {
                          if (previewBut) {
                            previewBut = false;
                            isChooseOnMap = false;
                            isWantCustom = false;
                            isSelected = false;
                            await _Fin();
                            isPreview = true;
                            setState(() { });
                          }
                        },
                        heroTag: null,
                      ),
                    if( Map_Latlng["src"] != null && Map_Latlng["dst"] != null && !isChooseOnMap && !isWantCustom && isPreview)
                      FloatingActionButton.extended(
                        elevation: 1,
                        icon: Icon(Icons.check),
                        label: Text(AppLocalizations.instance.text("finish")),
                        onPressed: _Fin,
                        heroTag: null,
                      ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(){
    return ReorderableRow(
      onReorder: (int oldIndex, int newIndex){
        setState(() {
          final items = wayPoint.removeAt(oldIndex);
          wayPoint.insert(newIndex, items);
          _drawLine();
        });
        print(wayPoint);
      },
      buildDraggableFeedback: (context, _, widget) => widget,
      footer: wayPoint.length < 15
          ? Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ClipOval(
        child: Material(
            child: InkWell(
              child: SizedBox(width: 64, height: 64, child: Icon(Icons.add)),
              onTap: () {
                isChooseOnMap = true;
                setState(() {});
              },
            ),
        ),
      ),
          )
          : Container(),
      children: [
        for(int i = 0; i < wayPoint.length; i++)
          Padding(
            key: UniqueKey(),
            padding: i == 0 || i == (wayPoint.length - 1)
                ? (i == 0 ? EdgeInsets.only(right: 4.0) : EdgeInsets.only(left: 4.0))
                : EdgeInsets.symmetric(horizontal: 4.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipOval(
                  child: Material(
                    child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Center(
                            child: Text(
                              "${i+1}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        )
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: Colors.red,
                    child: InkWell(
                      child: SizedBox(width: 20, height: 20, child: Icon(Icons.clear, color: Colors.white, size: 12)),
                      onTap: () async {
                        wayPoint.removeAt(i);
                        _drawLine();
                        setState(() { });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
  // ----------------------------------------------------------------------------

  _drawLine(){
    print(markerSet.length);
    int j = 0;
    mark.clear();
    wayPoint.forEach((element) async {
      MarkerId markerId = MarkerId(j.toString());
      Marker marker =  Marker(
        markerId: markerId,
        position:  element,
        infoWindow: InfoWindow(title: j.toString()),
        icon: markerSet[j]
      );
      mark.add(marker);
      j++;
    });
    isSelected = true;
    setState(() { });
  }
  _pageConfig() async {
    if(widget.data != null){
      socket.off('onAccept');
      socket.off('onNewNotification');
      socket.off('onNewAccept');
      socket.off('onNewMatch');
      socket.off('onNewMessage');
      socket.off('onRequest');
      socket.off('onTripEnd');
      socket.off('onKick');

      socket.on('onKick', (data){
        currentUser.status.navbarTrip = true;
      });

      socket.on('onRequest', (data) {
        currentUser.status.navbarTrip = true;
      });
      socket.on('onNewMatch' , (data){
        currentUser.status.navbarTrip = true;
      });
      socket.on('onNewAccept', (data){
        currentUser.status.navbarTrip = true;
      });
      socket.on('onNewMessage',(data){
        currentUser.status.navbarTrip = true;
      });
      socket.on('onNewAccept',(data){
        currentUser.status.navbarTrip = true;
      });
      socket.on('onNewNotification', (data) {
        currentUser.status.navbarNoti = true;
      });
    }else{
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
    }
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showNotification(message);
        }
    );

    if(widget.data != null){
      MarkerId markerId = MarkerId("other src");
      Marker marker =  Marker(
          markerId: markerId,
          position:  widget.data.routes.first,
          infoWindow: InfoWindow(title: widget.data.src),
          icon:  await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/icons/person.png')
    );
    _markers[markerId] = marker;
    markerId = MarkerId("other dst");
    marker =  Marker(
        markerId: markerId,
        position:  widget.data.routes.last,
        infoWindow: InfoWindow(title: widget.data.dst),
        icon:  await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/icons/dst_paiduay.png')
    );
    _markers[markerId] = marker;
    setState(() { });

    var left = min( widget.data.routes.first.latitude,  widget.data.routes.last.latitude);
    var right = max( widget.data.routes.first.latitude,  widget.data.routes.last.latitude);
    var top = max( widget.data.routes.first.longitude,  widget.data.routes.last.longitude);
    var bottom = min( widget.data.routes.first.longitude,  widget.data.routes.last.longitude);

    left = min(left, current_Location.latitude);
    right = max(right, current_Location.latitude);
    top = max(top, current_Location.longitude);
    bottom = min(bottom, current_Location.longitude);

    bounds = LatLngBounds(
    southwest: LatLng(left, bottom),
    northeast: LatLng(right, top),
    );
  }
    for ( int x = 0 ; x < 15 ; x++) {
      BitmapDescriptor tmp =await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/marker/marker_${x+1}.png');
      markerSet.add(tmp);
    }
  }

  getLocation() async{
    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      current_Location = LatLng(currentLocation.latitude, currentLocation.longitude);
    });
    Marker_Location = current_Location;
    setState(() { });
    isSet_Marker = true;
  }


  Future<void> _Fin() async {
    isChooseOnMap = false;
    String Placename_src = Map_Placename["src"];
    String Placename_dst = Map_Placename["dst"];
    var origin = PointLatLng(Map_Latlng["src"].latitude, Map_Latlng["src"].longitude);
    var destination = PointLatLng(Map_Latlng["dst"].latitude, Map_Latlng["dst"].longitude);
//    List<LatLng> tmp = List();
    if(!isPreview){
      tmp = List();
      PolylinePoints polylinePoints = PolylinePoints();
      List<PolylineWayPoint> waypoint = List();
      wayPoint.forEach((element) {
        waypoint.add(PolylineWayPoint(location:"${element.latitude.toString()},${element.longitude.toString()}"));
      });
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(api_key, origin,destination,wayPoints: waypoint);
      result.points.forEach((step) {
        tmp.add(LatLng(step.latitude, step.longitude));
      });
      finalLines.clear();
      finalLines.add(Polyline(
        patterns: [PatternItem.dot],
        points: tmp,
        geodesic: true,
        polylineId: PolylineId("mejor ruta"),
        color: Theme.of(context).accentColor.withOpacity(0.5),
        width: 5,
      ));
    }


    var left = min(tmp.first.latitude, tmp.last.latitude);
    var right = max(tmp.first.latitude, tmp.last.latitude);
    var top = max(tmp.first.longitude, tmp.last.longitude);
    var bottom = min(tmp.first.longitude, tmp.last.longitude);

    finalLines.first.points.forEach((point) {
        left = min(left, point.latitude);
        right = max(right, point.latitude);
        top = max(top, point.longitude);
        bottom = min(bottom, point.longitude);
    });

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );

    if(!isPreview){
      await _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }

    // go to fill all information in next page before save to DB
    if(isPreview){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => InfoFill(
              routes: [Map_Latlng["src"]]+tmp+[Map_Latlng["dst"]],
              bounds:bounds,
              Markers : Set<Marker>.of(_markers.values),
              lines :finalLines,
              src:Placename_src,
              dst: Placename_dst ,
              data: widget.data,
              Role: Role))).then((value) => setState(() { previewBut = true; }));
    }
  }

  OnMove_End() async {
    if (isChooseOnMap){
      if( isSet_Marker && Marker_Location != null){
        bool isSrc = is_src;
        NearbyPlace place; String name = ""; double min = double.maxFinite;
        List<NearbyPlace> tmp = await NearbyPlace().getNearbyPlace(Marker_Location.latitude, Marker_Location.longitude);
        tmp.forEach((element) {
          l.LatLng NearPlace_Loc = new l.LatLng(element.location.latitude,element.location.longitude);
          l.LatLng Marker_Loc = new l.LatLng(Marker_Location.latitude, Marker_Location.longitude);
          double dis = distance(NearPlace_Loc,Marker_Loc);
          if(dis <= min){
            min = dis;
            place = min > 30 ? null:element;
            name = element.name;
          }
        });
        if(place!=null) {
          Marker_Location = place.location;
        }
        Src_OR_Dst(Marker_Location,name,isSrc);
      }
    }
  }

  center(CameraPosition pos) {
    Marker_Location = pos.target;
  }

  Future<void> _Searchbar(Map<String, dynamic> result) async {
    bool isSrc = is_src;
    p.PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(result['place_id']);
    debugPrint(result['place_id']);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    Src_OR_Dst(LatLng(lat,lng), detail.result.name,isSrc);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat,lng), zoom: 18)));
  }

  createRoute(LatLng x){
    wayPoint.add(x);
  }


  Src_OR_Dst(LatLng point,String name, bool isSrc) async {
    if(isSrc){ // select source state
      Map_Latlng["src"] = point ;
      Map_Placename["src"] = name;
      src_Textcontroller.text = name;
      MarkerId markerId = MarkerId("src");
      Marker marker =  Marker(
          markerId: markerId,
          position:  Map_Latlng["src"],
          infoWindow: InfoWindow(title: Map_Placename["src"]),
          icon:  await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/icons/car.png')
      );
      _markers[markerId] = marker;
    }else{ // select destination state
      Map_Latlng["dst"] = point ;
      Map_Placename["dst"] = name;
      dst_Textcontroller.text = name;
      MarkerId markerId = MarkerId("dst");
      Marker marker =  Marker(
          markerId: markerId,
          position:  Map_Latlng["dst"],
          infoWindow: InfoWindow(title: Map_Placename["dst"]),
          icon:  await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(3,3)), 'assets/icons/dst_chuan.png')
      );
      _markers[markerId] = marker;
    }
    setState(() {
    });
  }

  // set Map controller
  void _onMapCreated(GoogleMapController controller){
    _mapController = controller;
    if(bounds != null){
      Future.delayed(new Duration(milliseconds: 100), () async {
        await _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      });
    }

  }
}