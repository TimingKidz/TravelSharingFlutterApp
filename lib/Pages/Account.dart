import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/Pages/ProfileManagePage.dart';
import 'package:travel_sharing/Pages/VehicleManagement/VehicleManagePage.dart';
import 'package:travel_sharing/buttons/VehicleCardTileMin.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class Account extends StatefulWidget {
  final Function setSate;

  const Account({Key key, this.setSate}) : super(key: key);

  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Card(
            elevation: 2.0,
            margin: EdgeInsets.all(0.0),
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)
                )
            ),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16.0),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    // CircleAvatar(
                    //   radius: 64.0,
                    // ),
                    SizedBox(
                      width: 128.0,
                      height: 128.0,
                      child: GoogleUserCircleAvatar(
                        identity: googleUser,
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Text(
                      currentUser.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    RatingBarIndicator(
                      rating: 4.75,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 30.0,
                      direction: Axis.horizontal,
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    if(defaultVehicle() != null)
                      VehicleCardTileMin(data: defaultVehicle())
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: menuList(),
            ),
          )
        ],
      ),
    );
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: _handleSignOut,
          child: Text('Sign Out'),
        ),
      ),
    );
  }


  _pageConfig(){
    socket.off('onNewNotification');
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    socket.off('onNewNotification');
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
      widget.setSate();
    });
  }

  Vehicle defaultVehicle(){
    for(Vehicle each in currentUser.vehicle){
      if(each.isDefault){
        return each;
      }
    }
    return null;
  }

  List<Widget> menuList(){
    return [
      ListTile(
        title: Text(
          "Profile"
        ),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ProfileManagePage())).then((v){
            _pageConfig();
            setState((){});
          });
        },
      ),
      ListTile(
        title: Text(
          "Vehicle Management"
        ),
        onTap: () async {
              Navigator.push(context, MaterialPageRoute(
              builder: (context) => VehicleManagePage())).then((v){
                _pageConfig();
                setState((){});
              });
        },
      ),
      ListTile(
        title: Text(
          "History"
        ),
        onTap: (){},
      ),
      SizedBox(
        height: 32.0,
      ),
      ListTile(
        title: Center(
          child: Text(
            "SIGN OUT",
            style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        onTap: _handleSignOut,
      )
    ];
  }

  Future<void> _handleSignOut() async {
    await googleSignIn.disconnect();
    // set user.token_id in DB to " "
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/'));
  }

}