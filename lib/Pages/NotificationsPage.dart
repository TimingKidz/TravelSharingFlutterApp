import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget{
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        automaticallyImplyLeading: false,
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      separatorBuilder: (context, i) => Divider(
        color: Colors.grey,
      ),
        physics: BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, i) {
          return _buildRow(i.toString());
        }
    );
  }

  Widget _buildRow(String data) {
    return ListTile(
      title: Text(data),

    );
  }

}