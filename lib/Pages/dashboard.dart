import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Pages/JoinMap.dart';
import 'package:travel_sharing/Pages/MatchList.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/ReqList.dart';
import 'package:travel_sharing/Pages/map.dart';
import 'package:location/location.dart' ;
import 'package:travel_sharing/buttons/DashboardCardTile.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
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
  List<Travel_Info> _joinList  = List();
  List<Travel_Info> _invitedList = List();
  // GlobalKey actionKey = GlobalKey();
  // double height;
  bool isFirstPage = true;

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
      currentUser.status.navbarNoti = true;
      widget.setSate();
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
     // backgroundColor: Theme.of(context).primaryColor,
     //  appBar: AppBar(
     //    backgroundColor: isFirstPage ? Theme.of(context).accentColor : Theme.of(context).colorScheme.orange,
     //    automaticallyImplyLeading: false,
     //    title: const Text('แดชบอร์ด'),
     //  ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: isFirstPage ? _newroute1 : _newroute,
        backgroundColor: isFirstPage ? Theme.of(context).accentColor : Theme.of(context).accentColor,
        heroTag: null,
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 80),
            child: _widgetOptions(),
          ),
          // AppBar
          Card(
            // key: actionKey,
            elevation: 2.0,
            margin: EdgeInsets.all(0.0),
            color: isFirstPage ? Theme.of(context).colorScheme.darkBlue : Theme.of(context).colorScheme.amber,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)
                )
            ),
            child: Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0, top: 8.0),
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          highlightElevation: 0.0,
                          padding: EdgeInsets.all(16.0),
                          color: isFirstPage ? Theme.of(context).colorScheme.orange : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Text('ไปด้วย', style: TextStyle(color: isFirstPage ? Colors.white : Colors.black)),
                          onPressed: () {
                            setState(() {
                              isFirstPage = true;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: RaisedButton(
                          highlightElevation: 0.0,
                          padding: EdgeInsets.all(16.0),
                          color: isFirstPage ? Colors.white : Theme.of(context).colorScheme.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Text('ชวน', style: TextStyle(color: isFirstPage ? Colors.black : Colors.white)),
                          onPressed: () {
                            setState(() {
                              isFirstPage = false;
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
      setState(() {});
    }catch(error){
      print("$error lllLLLL");
    }
  }

  Widget _widgetOptions(){
    if((_joinList.isEmpty && isFirstPage) || (_invitedList.isEmpty && !isFirstPage)){
      return Center(
        child: Text('No List'),
      );
    }else{
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: isFirstPage ? _joinList.length : _invitedList.length,
        itemBuilder: (context, i) {
          return _buildRow(isFirstPage ? _joinList[i] : _invitedList[i]);
        }
    );
  }

  Widget _buildRow(Travel_Info data) {
    print(data);
    return DashboardCardTile(
      data: data.routes,
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
    if( isFirstPage ){
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
          _pageConfig(currentUser.status.navbarTrip);
          currentUser.status.navbarTrip = false;
          await widget.setSate();
        });
      }
    }
  }

  _newroute() async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CreateRoute())).then((value) async {
      _pageConfig(currentUser.status.navbarTrip);
      currentUser.status.navbarTrip = false;
      await widget.setSate();
    });
  }

  _newroute1() async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CreateRoute_Join())).then((value) async {
          _pageConfig(currentUser.status.navbarTrip);
          currentUser.status.navbarTrip = false;
      await widget.setSate();
    });
  }

}
