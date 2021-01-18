
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/Notifications.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Pages/ratingPage.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/localization.dart';

class NotificationsPage extends StatefulWidget{
  final Function setSate;
  final bool isNeed2Update;

  const NotificationsPage({Key key, this.setSate,this.isNeed2Update}) : super(key: key);
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage>{
  List<Notifications> notifications = null;


  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageConfig(widget.isNeed2Update);

  }

  _pageConfig(bool isNeed2Update){
    getData(isNeed2Update);
    socket.off('onAccept');
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onTripEnd');
    socket.off('onKick');

    // remove all page except dashboard
    socket.on('onKick', (data){
      currentUser.status.navbarTrip = true;
      widget.setSate();
    });
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
            notifications != null ?
            Padding(
              padding: EdgeInsets.only(top: 80),
              child: notifications.isNotEmpty ? _buildListView() : Center(
                child: Text("Nothing in notifications yet."),
              ),
            ) : Padding(
              padding: EdgeInsets.only(top: 80),
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
                    AppLocalizations.instance.text('NotiTitle'),
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
  }

  Widget _buildListView() {
    return ListView.separated(
        separatorBuilder: (context, i) => Divider(
          color: Colors.grey,
        ),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: notifications.length,
        itemBuilder: (context, i) {
          if(notifications[i].tag == "review")
            return _buildRow(notifications[i]);
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async{
              bool isDelete = false;
              alertDialog(
                this.context,
                'Are you sure',
                Text("This action couldn't be undone. Would you like to end this trip ?"),
                <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () async {
                      notifications[i].deleteNotification(currentUser.uid).then((value){
                        if(value){
                          isDelete = true;
                          notifications.removeAt(i);
                          Navigator.of(context).pop();
                          setState(() {  });
                        }else{
                          print("error");
                        }
                      });
                    },
                  ),
                ],
              );
              return isDelete;
            },
            background: Container(
              color: Theme.of(context).accentColor,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: _buildRow(notifications[i]),
          );
        }
    );
  }

  Widget _buildRow(Notifications data) {
    switch (data.tag) {
      case "announcement":
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
                Flexible(
                  child: Text(
                    data.Title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18.0
                    ),
                  ),
                )
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                DateManage().datetimeFormat("full", data.date),
                style: TextStyle(
                    fontSize: 10.0
                ),
              ),
            ),
            childrenPadding: EdgeInsets.all(16.0),
            expandedAlignment: Alignment.centerLeft,
            children: <Widget>[
              for(Child each in data.child)
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(each.type),
                      Text(each.message)
                    ],
                  ),
                )


              // Text('Birth of the Sun'),
              // Text('Earth is Born'),
            ],
          ),
        );
      // do something
        break;
      case "notification":
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
                Flexible(
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.Title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 18.0
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            data.src ?? "Source",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.0
                            ),
                          ),
                          Icon(Icons.navigate_next_outlined),
                          Text(
                            data.dst ?? "Destination",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.0
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                DateManage().datetimeFormat("full", data.date),
                style: TextStyle(
                    fontSize: 10.0
                ),
              ),
            ),
            childrenPadding: EdgeInsets.all(16.0),
            expandedAlignment: Alignment.centerLeft,
            children: <Widget>[
              for(Child each in data.child)
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(each.type),
                      Text(each.message)
                    ],
                  ),
                )


              // Text('Birth of the Sun'),
              // Text('Earth is Born'),
            ],
          ),
        );
        // do something
        break;
      case "review":
        return Theme(
          data: ThemeData(
              accentColor: Colors.black,
              dividerColor: Colors.transparent
          ),
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) =>RatingPage(sendToid: data.sender,notiId: data.uid,))).then((value) async {
                  await _pageConfig(true);
                  widget.setSate();
                }),
            trailing: Icon(Icons.navigate_next),
            title: Row(
              children: [
                Icon(Icons.rate_review),
                SizedBox(width: 16.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.Title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 18.0
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            data.src ?? "Source",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.0
                            ),
                          ),
                          Icon(Icons.navigate_next_outlined),
                          Text(
                            data.dst ?? "Destination",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.0
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                DateManage().datetimeFormat("full", data.date),
                style: TextStyle(
                    fontSize: 10.0
                ),
              ),
            ),
          ),
        );
        // do something
        break;
      case "alert":
        return Theme(
          data: ThemeData(
              accentColor: Colors.black,
              dividerColor: Colors.transparent
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(Icons.error),
                SizedBox(width: 16.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.Title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 18.0
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            data.src ?? "Source",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.0
                            ),
                          ),
                          Icon(Icons.navigate_next_outlined),
                          Text(
                            data.dst ?? "Destination",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.0
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                DateManage().datetimeFormat("full", data.date),
                style: TextStyle(
                    fontSize: 10.0
                ),
              ),
            ),
            childrenPadding: EdgeInsets.all(16.0),
            expandedAlignment: Alignment.centerLeft,
            children: <Widget>[
              for(Child each in data.child)
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(each.type),
                      Text(each.message)
                    ],
                  ),
                )
              // Text('Birth of the Sun'),
              // Text('Earth is Born'),
            ],
          ),
        );
        // do something
        break;
    }

  }

}