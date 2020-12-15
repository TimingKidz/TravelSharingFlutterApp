import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Notifications.dart';
import 'package:travel_sharing/main.dart';

class NotificationsPage extends StatefulWidget{
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
    getData();
  }

  getData() async {
    try{
      notifications = await Notifications().getNotification(currentUser.uid);
      setState(() { });
    }catch(error){
      print(error );
    }
  }

  @override
  Widget build(BuildContext context) {
    if( notifications.isEmpty ){
      return Scaffold();
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