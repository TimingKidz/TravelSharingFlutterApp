import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Dialog.dart';
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
        icon: new Stack(
          children: <Widget>[
            new Icon(Icons.adjust),
            if( currentUser.status.navbarTrip )
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
  List<bool> isNeed2Update = [false,false];

  @override
  void setState(fn) {
    print("setsate homenav");
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    socket.on("tooManyOnline",(value) async {
      if(mounted) {
        print("tooManyOnline");
        socket = socket.disconnect();
        socket.destroy();
        socket.dispose();
        googleUser = await googleSignIn.signOut();
        unPopDialog(
          this.context,
          'Accept',
          Text("You already online with other device."),
          <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/'));
              },
            ),
          ],
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  List<Widget> pageRoute(){
    return [
      NotificationsPage(isNeed2Update: isNeed2Update[0] , setSate:() => setState(() { }) ),
      FeedPage(setSate:() => setState((){})),
      Dashboard(isNeed2Update : isNeed2Update[1] ,setSate:() => setState((){})),
      Account(setSate:() => setState((){}))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageRoute()[selectedBarIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: widget.barItems(),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor:  Colors.black,
        selectedFontSize: 12.0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 26,
        currentIndex: selectedBarIndex,
        onTap: (index) {
          if ( index == 0 ){
            isNeed2Update[0] = currentUser.status.navbarNoti;
            currentUser.status.navbarNoti = false;
            print(currentUser.status.navbarNoti);
          }
          if ( index == 2){
            isNeed2Update[1] = currentUser.status.navbarTrip;
            currentUser.status.navbarTrip = false;
            print(currentUser.status.navbarTrip);
          }
          setState(() {
            selectedBarIndex = index;
          });
        },
      ),
    );
  }
}