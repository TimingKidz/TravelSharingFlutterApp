import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/MapStaticRequest.dart';
import 'package:travel_sharing/Class/Req_Info.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
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
  int _index = 0;
  List<Req_Info> _ReqList = List();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    socket.off('onRequest');
    notificationBarIconLight();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageConfig(widget.data.routes.status);
  }

  @override
  Widget build(BuildContext context) {
    notificationBarIconDark();
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: SizedBox(
                height: double.infinity, // card height
                child: _widgetOptions()
            ),
          ),
        )
    );
  }

  Widget _widgetOptions(){
    if(_ReqList.isEmpty){
      return Center(
        child: Text('No List'),
      );
    }else{
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return PageView.builder(
      itemCount: _ReqList.length,
      controller: PageController(viewportFraction: 0.85),
      physics: BouncingScrollPhysics(),
      onPageChanged: (int index) => setState(() => _index = index),
      itemBuilder: (_, i) {
        return Card(
          margin: EdgeInsets.only(top: 64.0, bottom: 64.0, right: 8.0, left: 8.0),
          elevation: 2,
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
      onAcceptPressed: () => _onAcceptPressed(data),
      onDeclinePressed: () => _onDeclinePressed(data),
    );
    // }else{
    //   return Center(
    //     child: Text("Hello"),
    //   );
    // }
  }

  _pageConfig(bool isNeed2Update) async {
    await getData(isNeed2Update);
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onNewNotification');
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
      setState((){});
    }catch(error){
      print(error);
    }
  }

  _onAcceptPressed(Req_Info data) async{
    currentUser.AcceptReq(data.reqid,widget.data.id,widget.data.uid).then((value){
      print(value);
      print("555555555555");
      if(widget.isFromMatchinfo){
        Navigator.of(context).pop();
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: widget.data.uid, data: widget.data)));
      }
    });
  }

  _onDeclinePressed(Req_Info data) async{
    currentUser.DeclineReq(data.reqid,widget.data.id,widget.data.uid).then((value) async => await getData(true));
  }

}
