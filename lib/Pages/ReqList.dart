import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/MapStaticRequest.dart';
import 'package:travel_sharing/Class/Req_Info.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/UI/NotificationBarSettings.dart';
import 'package:travel_sharing/UI/ReqMapCard.dart';
import 'package:travel_sharing/main.dart';
import 'package:flutter/services.dart';


class ReqList extends StatefulWidget {
  final Travel_Info data; // current routes
  final bool isFromMatchinfo;
  static final GlobalKey<_ReqListstate> dashboardKey = GlobalKey<_ReqListstate>();
  ReqList({Key key, this.data, this.isFromMatchinfo}) : super(key: dashboardKey);
  @override
  _ReqListstate createState() => _ReqListstate();
}

class _ReqListstate extends State<ReqList> {
  List<Req_Info> _ReqList = null;
  int _index = 1;
//  Travel_Info Data; // current routes
//  bool isFromMatchinfo;
  Map<String,bool> isPress = Map();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    notificationBarIconLight();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageConfig(widget.data.routes.status);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    final arg = ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
//    Data = arg['data'];
//    isFromMatchinfo = arg['isFromMatchinfo'];
  }
  @override
  Widget build(BuildContext context) {
    notificationBarIconDark();
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(false);
      return false;
    },
    child:
      Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                    height: double.infinity, // card height
                    child: _widgetOptions()
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              if( _ReqList != null)
              if(_ReqList.isNotEmpty)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 32.0),
                      child: Text("$_index/${_ReqList.length}"),
                    ),
                  ),
                )
            ],
          ),
        )
      )
    );
  }

  Widget _widgetOptions(){
    if( _ReqList != null){
      if(_ReqList.isEmpty){
        return Center(
          child: Text('No List'),
        );
      }else{
        return _buildListView();
      }
    }
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.09),
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20.0),
              Text("Loading..."),
            ],
          )
      ),
    );

  }

  Widget _buildListView() {
    return PageView.builder(
      itemCount: _ReqList.length,
      controller: PageController(viewportFraction: 0.85),
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      onPageChanged: (int index) => setState(() => _index = index + 1),
      itemBuilder: (_, i) {
        return Card(
          margin: EdgeInsets.only(top: 64.0, bottom: 64.0, right: 8.0, left: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: cardDetails(_ReqList[i]),
        );
      },
    );
  }

  Widget cardDetails(Req_Info data){
    // int next = i - 1 < 0 ? i : i-1;
    // if(i == _index || next == _index){
    return ReqMapCard(
      url: MapStaticRequest().getMapUrl(widget.data.routes, data.routes),
      data: data,
      userData: widget.data,
      isPress : isPress[data.routes.uid],
      onAcceptPressed: () => _onAcceptPressed(data),
      onDeclinePressed: () => _onDeclinePressed(data),
      onCardPressed: () => activityInfoDialog(context, data.routes),
    );
    // }else{
    //   return Center(
    //     child: Text("Hello"),
    //   );
    // }
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
    socket.off('onAccept');

    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    socket.on('onRequest', (data) {
      if (widget.data.uid == data['tripid']){
        getData(true);
      }
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if( message['data']['page'] != '/ReqList' ){
            print("onMessage: $message");
            showNotification(message);
          }
        }
    );
  }

  // get request list of current routes
  Future<void> getData(bool isNeed2Update) async {
    try{
      _ReqList =  await Req_Info().getReq(widget.data,isNeed2Update) ?? [];
      _ReqList.forEach((element) {
        isPress[element.routes.uid] = false;
      });
      setState((){});
    }catch(error){
      print(error);
    }
  }

  _onAcceptPressed(Req_Info data) async{
    isPress[data.routes.uid] = true;
    setState((){ });
    currentUser.AcceptReq(data.reqid,widget.data.id,widget.data.uid)
    .then((v)async{
      var value = true;
      if(value){
        if(widget.isFromMatchinfo){
          Navigator.of(context).pop(false);
          setState(() { });
        }else{
          Navigator.of(context).pop(true);
        }
      }else{
        isPress[data.routes.uid] = false;
        await getData(true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not accept please try again.")));
      }
    });
  }

  _onDeclinePressed(Req_Info data) async{
    isPress[data.routes.uid] = true;
    setState((){ });
    currentUser.DeclineReq(data.reqid,widget.data.id,widget.data.uid)
    .then((v)async{
      var value = true;
      if(value){
        isPress[data.routes.uid] = false;
      }else{
        print("error");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not decline please try again.")));
      }
      await getData(true);
    });
  }
}
