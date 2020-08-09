import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/buttons/cardTileWithTapMatch.dart';
import 'package:travel_sharing/buttons/cardTileWithTapReq.dart';
/// This Widget is the main application widget.


class ReqList extends StatefulWidget {
  final Map<String, dynamic> data; // current routes
  static final GlobalKey<_ReqListstate> dashboardKey = GlobalKey<_ReqListstate>();

  ReqList({Key key, this.data}) : super(key: dashboardKey);

  @override
  _ReqListstate createState() => _ReqListstate();
}

class _ReqListstate extends State<ReqList> {
  List< Map<String,dynamic>> _ReqList = List();
  bool isFirstPage = true;

  // get request list of current routes
  Future<void> getData() async {
    try{
      _ReqList =  await Routes().getReq(widget.data) ?? [];
      setState(() {});
    }catch(error){
      print(error);
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
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

  Widget _buildRow( Map<String,dynamic> data) {
    return CardTileWithTapReq(
      data: data,
      onCardPressed:() => _onCardPressed(data),
    );
  }

  _onCardPressed(Map<String,dynamic> data) async{

  }

  _onAcceptPressed(Map<String,dynamic> data) async{

  }

  _onDeclinePressed(Map<String,dynamic> data) async{

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('ตอบรับคำขอของคนที่จะไปด้วย'),
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

}
