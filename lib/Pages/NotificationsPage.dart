import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/Notifications.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class NotificationsPage extends StatefulWidget{
  final Function setSate;
  final bool isNeed2Update;

  const NotificationsPage({Key key, this.setSate,this.isNeed2Update}) : super(key: key);
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage>{
  List<Notifications> notifications = List();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageConfig();

  }

  _pageConfig(){
    getData(widget.isNeed2Update);
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');

    socket.on('onRequest', (data) {
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewMatch' , (data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewAccept', (data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewMessage',(data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
    socket.on('onNewAccept',(data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });

    socket.on('onNewNotification', (data) => getData(true));
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if( message['data']['page'] != '/NotificationPage' ){
            print("onMessage: $message");
            showNotification(message);
          }
        }
    );
  }

  getData(bool Need2Update) async {
    try{
      notifications = await Notifications().getNotification(currentUser.uid,Need2Update) ?? [];
      setState(() { });
    }catch(error){
      print(error );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 80),
              child: notifications.isNotEmpty ? _buildListView() : Center(
                child: Text("Nothing in notifications yet."),
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
                padding: EdgeInsets.only(left: 24.0, top: 16.0, bottom: 30.0, right: 24.0),
                child: SafeArea(
                  child: Text(
                    "Notifications",
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white
                    ),
                    // textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        )
    );
    if( notifications.isEmpty ){
      return Scaffold(
        appBar: AppBar(
        title: Text("Notifications"),
        automaticallyImplyLeading: false,
        )
      );
    }else{
      return Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
          automaticallyImplyLeading: false,
        ),
        body: _buildListView(),
      );
    }
  }

  Widget _buildListView() {
    return ListView.separated(
        separatorBuilder: (context, i) => Divider(
          color: Colors.grey,
        ),
        physics: BouncingScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, i) {
          return _buildRow(notifications[i]);
        }
    );
  }

  Widget _buildRow(Notifications data) {
    return Theme(
      data: ThemeData(
        accentColor: Colors.black,
        dividerColor: Colors.transparent
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.announcement),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.Title,
                  style: TextStyle(
                    fontSize: 18.0
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  DateManage().datetimeFormat("full", data.date),
                  style: TextStyle(
                    fontSize: 10.0
                  ),
                )
              ],
            )
          ],
        ),
        childrenPadding: EdgeInsets.all(16.0),
        tilePadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        expandedAlignment: Alignment.centerLeft,
        children: <Widget>[
          Text(data.Message),
          // Text('Birth of the Sun'),
          // Text('Earth is Born'),
        ],
      ),
    );
  }

}