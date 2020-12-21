import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Pages/Account.dart';
import 'package:travel_sharing/Pages/Feed.dart';
import 'package:travel_sharing/Pages/NotificationsPage.dart';
import 'package:travel_sharing/Pages/dashboard.dart';

import '../main.dart';

class HomeNavigation extends StatefulWidget {
  List<BottomNavigationBarItem> barItems() {
    return [
      BottomNavigationBarItem(
        icon: new Stack(
          children: <Widget>[
            new Icon(Icons.notifications_none),
            if( currentUser.status.navbarNoti )
              new Positioned(
                right: 0,
                child: new Container(
                  padding: EdgeInsets.all(1),
                  decoration: new BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: new Text(
                    '!',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        ),
//      title: Text('Notification'),
        title: Text('การแจ้งเตือน'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.view_agenda),
//      title: Text('Feed'),
        title: Text('ฟีด'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.adjust),
//      title: Text('On going'),
        title: Text('การเดินทาง'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
//      title: Text('Account'),
        title: Text('บัญชี'),
      ),
    ];
  }
  @override
  HomeNavigationState createState() =>
      HomeNavigationState();
}

class HomeNavigationState extends State<HomeNavigation> {
  int selectedBarIndex = 1;
  bool isNeed2Update = false;

  @override
  void setState(fn) {
    print("setsate homenav");
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  List<Widget> pageRoute(){
    return [
      NotificationsPage(isNeed2Update: isNeed2Update),
      FeedPage(setSate:() => setState((){})),
      Dashboard(setSate:() => setState((){})),
      Account(setSate:() => setState((){}))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: pageRoute()[selectedBarIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: widget.barItems(),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor:  Colors.black,
          selectedFontSize: 12.0,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          currentIndex: selectedBarIndex,
          onTap: (index) {
            if ( index == 0 ){
              isNeed2Update = currentUser.status.navbarNoti;
              currentUser.status.navbarNoti = false;
              print(currentUser.status.navbarNoti);
            }
            setState(() {
              selectedBarIndex = index;
            });
          },
        ),
      ),
    );
  }
}