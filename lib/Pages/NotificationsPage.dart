import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

class NotificationsPageState extends State<NotificationsPage> with TickerProviderStateMixin{
  List<Notifications> notifications;


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
      // Sorted by child timestamp
      notifications.sort((current, next) {
        // Find lastest timestamp in List<Child>
        String curMax = current.child.reduce((cur, next) => cur.timestamp.compareTo(next.timestamp) > 0 ? cur : next).timestamp;
        String nextMax = next.child.reduce((cur, next) => cur.timestamp.compareTo(next.timestamp) > 0 ? cur : next).timestamp;
        return nextMax.compareTo(curMax);
      });
      // Last timestamp for display
      for(var each in notifications){
        each.lastStamp = each.child.reduce((cur, next) => cur.timestamp.compareTo(next.timestamp) > 0 ? cur : next).timestamp;
      }
      print(notifications);
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
                child: Text(AppLocalizations.instance.text("notiempty")),
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
                    Text(AppLocalizations.instance.text("loading")),
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
          if(notifications[i].tag == "review" || notifications[i].tag == "notification")
            return _buildRow(notifications[i]);
          return Slidable(
            key: UniqueKey(),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
                IconSlideAction(
                  caption: AppLocalizations.instance.text("delete"),
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    deleteDialog(context, () {
                      notifications[i].deleteNotification(currentUser.uid).then((value){
                        if(value){
                          notifications.removeAt(i);
                          setState(() {});
                        }else{
                          print("error");
                        }
                      });
                    });
                  },
                ),
            ],
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
                // Icon(Icons.announcement),
                SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: getTypeIcon("announcement")
                ),
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
                  child: Text(each.message),
                )
            ],
          ),
        );
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
                // Icon(Icons.announcement),
                SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: getTypeIcon("notification")
                ),
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
                DateManage().datetimeFormat("full", data.lastStamp),
                style: TextStyle(
                    fontSize: 10.0
                ),
              ),
            ),
            // childrenPadding: EdgeInsets.all(8.0),
            expandedAlignment: Alignment.centerLeft,
            children: <Widget>[
              for(Child each in data.child)
                Card(
                  margin: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(each.type),
                            SizedBox(height: 4.0),
                            Text(each.message, style: TextStyle(fontSize: 12.0))
                          ],
                        ),
                        if(each.count > 1)
                        Material(
                          elevation: 1.0,
                          shape: CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          color: Colors.red,
                          textStyle: TextStyle(color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(each.count.toString()),
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        );
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
                // Icon(Icons.rate_review),
                SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: getTypeIcon("review")
                ),
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
                // Icon(Icons.error),
                SizedBox(
                    width: 32.0,
                    height: 32.0,
                    child: getTypeIcon("alert")
                ),
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
                  child: Text(each.message),
                )
            ],
          ),
        );
        break;
      default:
        return Container();
        break;
    }
  }

  Widget getTypeIcon(String type){
    switch(type){
      case "announcement": {
        return Image.asset("assets/icons/announcement.png", filterQuality: FilterQuality.medium);
      }
      break;
      case "notification": {
        return Image.asset("assets/icons/trip.png", filterQuality: FilterQuality.medium);
      }
      break;
      case "review": {
        return Image.asset("assets/icons/review.png", filterQuality: FilterQuality.medium);
      }
      break;
      case "alert": {
        return Image.asset("assets/icons/alert.png", filterQuality: FilterQuality.medium);
      }
      break;
      default: {
        return null;
      }
      break;
    }
  }

}