import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Pages/Account.dart';
import 'package:travel_sharing/Pages/Feed.dart';
import 'package:travel_sharing/Pages/NotificationsPage.dart';
import 'package:travel_sharing/Pages/dashboard.dart';

class HomeNavigation extends StatefulWidget {
  final List<BottomNavigationBarItem> barItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_none),
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

  @override
  HomeNavigationState createState() =>
      HomeNavigationState();
}

class HomeNavigationState extends State<HomeNavigation> {
  int selectedBarIndex = 1;
  List<Widget> pageRoute;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    pageRoute = [
      NotificationsPage(),
      Feed(),
      Dashboard(),
      Account()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: pageRoute[selectedBarIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: widget.barItems,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          selectedFontSize: 12.0,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          currentIndex: selectedBarIndex,
          onTap: (index) {
            setState(() {
              selectedBarIndex = index;
            });
          },
        ),
      ),
    );
  }
}