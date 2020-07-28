import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Pages/Account.dart';
import 'package:travel_sharing/Pages/dashboard.dart';

class HomeNavigation extends StatefulWidget {
  final List<BottomNavigationBarItem> barItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_none),
      title: Text('Notification'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      title: Text('Dashboard'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
      title: Text('Account'),
    ),
  ];

  final Function signOut;
  HomeNavigation({this.signOut});

  @override
  HomeNavigationState createState() =>
      HomeNavigationState();
}

class HomeNavigationState extends State<HomeNavigation> {
  int selectedBarIndex = 1;
  List<Widget> pageRoute;

  @override
  void initState() {
    super.initState();
    pageRoute = [
      Center(child: Text('Notification')),
      Dashboard(),
      Account(signOut: widget.signOut)
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
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 12.0,
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