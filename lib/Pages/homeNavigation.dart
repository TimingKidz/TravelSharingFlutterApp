import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/Account.dart';
import 'package:travel_sharing/Pages/dashboard.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class HomeNavigation extends StatefulWidget {
  final List<BottomNavigationBarItem> barItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_none),
//      title: Text('Notification'),
      title: Text('การแจ้งเตือน'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
//      title: Text('Dashboard'),
      title: Text('แดชบอร์ด'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
//      title: Text('Account'),
      title: Text('บัญชี'),
    ),
  ];

  final GoogleSignIn googleSignIn;
  final User currentUser;

  HomeNavigation({this.currentUser, this.googleSignIn});

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
      Dashboard(currentUser : widget.currentUser),
      Account(currentUser : widget.currentUser, googleSignIn: widget.googleSignIn)
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