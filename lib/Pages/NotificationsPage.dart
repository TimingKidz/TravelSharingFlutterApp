import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Notifications.dart';
import 'package:travel_sharing/main.dart';

class NotificationsPage extends StatefulWidget{
 final bool isNeed2Update;

  const NotificationsPage({Key key, this.isNeed2Update}) : super(key: key);
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

    socket.on('onNewNotification', (data) => getData(false));
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
      notifications = await Notifications().getNotification(currentUser.uid,Need2Update);
      setState(() { });
    }catch(error){
      print(error );
    }
  }

  @override
  Widget build(BuildContext context) {
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
    return ListTile(
      title: Text(data.Title),
    );
  }

}