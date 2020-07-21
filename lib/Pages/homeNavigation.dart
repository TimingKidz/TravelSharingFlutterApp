import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Pages/dashboard.dart';

class HomeNavigation extends StatefulWidget {
  final List<BottomNavigationBarItem> barItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      title: Text('Dashboard'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map),
      title: Text('Map'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
      title: Text('Account'),
    ),
  ];

  @override
  HomeNavigationState createState() =>
      HomeNavigationState();
}

class HomeNavigationState extends State<HomeNavigation> {
  int selectedBarIndex = 0;

  final List<Widget> pageRoute = [
    Dashboard(),
    Center(child: Text('Hello')),
    Center(child: Text('Account'))
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageRoute[selectedBarIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: widget.barItems,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        selectedFontSize: 12.0,
        currentIndex: selectedBarIndex,
        onTap: (index) {
          setState(() {
            selectedBarIndex = index;
          });
        },
      ),
    );
  }
}