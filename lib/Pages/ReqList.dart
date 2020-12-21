import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Req_Info.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/buttons/cardTileWithTapReq.dart';
import 'package:travel_sharing/main.dart';


class ReqList extends StatefulWidget {
  final Travel_Info data; // current routes
  static final GlobalKey<_ReqListstate> dashboardKey = GlobalKey<_ReqListstate>();
  ReqList({Key key, this.data}) : super(key: dashboardKey);
  @override
  _ReqListstate createState() => _ReqListstate();
}

class _ReqListstate extends State<ReqList> {
  List<Req_Info> _ReqList = List();
  bool isFirstPage = true;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    socket.off('onRequest');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตอบรับคำขอของคนที่จะไปด้วย'),
        elevation: 2.0,
      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.dashboard),
//        onPressed: (){
//          Navigator.of(context).pop();
//        },
//        heroTag: null,
//      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _widgetOptions(),
            ),
          ],
        ),
      ),
    );
  }

  _pageConfig(){
    getData();
    socket.off('onNewNotification');
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    socket.on('onRequest', (data) => getData());
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
  Future<void> getData() async {
    try{
      _ReqList =  await Req_Info().getReq(widget.data) ?? [];
      setState((){});
    }catch(error){
      print(error);
    }
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
    return ListView.builder(
        itemCount: _ReqList.length,
        itemBuilder: (context, i) {
          return _buildRow(_ReqList[i]);
        });
  }

  Widget _buildRow( Req_Info data) {
    return CardTileWithTapReq(
      data: data,
      onCardPressed:() => _onCardPressed(data),
      onAcceptPressed: () => _onAcceptPressed(data),
      onDeclinePressed: () => _onDeclinePressed(data),
    );
  }

  _onCardPressed(Req_Info data) async{
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => mapview(from:data.routes,to:widget.data.routes)));
  }

  _onAcceptPressed(Req_Info data) async{
    currentUser.AcceptReq(data.reqid,widget.data.id,widget.data.uid).then((value){
      print(value);
      print("555555555555");
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => Matchinformation(uid: widget.data.uid, data: widget.data)));
    });

  }

  _onDeclinePressed(Req_Info data) async{
    await currentUser.DeclineReq(data.reqid,widget.data.id,widget.data.uid);
    getData();
  }

}
