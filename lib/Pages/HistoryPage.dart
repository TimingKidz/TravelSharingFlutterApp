import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/History.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Travel_Info> historyList = List();
  List<Travel_Info> historyReverseList = List();

  @override
  void initState() {
  _pageConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 80),
              child: historyReverseList.isNotEmpty ? _buildListView() : Center(
                child: Text("Nothing in your history yet."),
              ),
            ),
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(0.0),
              color: Theme.of(context).colorScheme.darkBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)
                  )
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        tooltip: AppLocalizations.instance.text("back"),
                        iconSize: 26.0,
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        AppLocalizations.instance.text("History"),
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.white,
                        ),
                        // textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  _pageConfig(){
    getHistoryList();
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
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
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showNotification(message);
        }
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: historyReverseList.length,
        itemBuilder: (context, i) {
          return _buildRow(historyReverseList[i]);
        }
    );
  }

  Widget _buildRow(Travel_Info data) {
    return ListTile(
      onTap: (){
        if(data.routes.role == "0")  Navigator.pushNamed(context,"/MatchInfo", arguments: {
          "uid" : data.routes.uid,
          "data" : data,
          "isHistory" : true
        }).then((value) => _pageConfig());
        else   Navigator.pushNamed(context,"/MatchInfo", arguments: {
          "uid" : data.routes.match.first,
          "data" : data,
          "isHistory" : true
        }).then((value) =>  _pageConfig());
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            data.routes.src,
            overflow: TextOverflow.ellipsis,
          ),
          Icon(Icons.navigate_next_outlined),
          Flexible(
            child: Text(
              data.routes.dst,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
      subtitle: Text(DateManage().datetimeFormat("full", data.routes.date)),
      trailing: Icon(Icons.navigate_next),
    );
  }

  Future<void> getHistoryList() async {
    print("Get History List");
//    try{
      historyList =  await Routes().getHistory(currentUser.uid) ?? [];
      historyReverseList = historyList.reversed.toList();
      setState(() {});
//    }catch(error){
//      print("$error history");
//    }
  }
}
