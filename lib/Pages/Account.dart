import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Pages/VehicleManagePage.dart';
import 'package:travel_sharing/buttons/VehicleCardTile.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class Account extends StatefulWidget {

  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Card(
            elevation: 2.0,
            margin: EdgeInsets.all(0.0),
            color: Theme.of(context).colorScheme.orange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)
                )
            ),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 64.0,
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    RatingBarIndicator(
                      rating: 3.5,
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
                    VehicleCardTile()
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

  List<Widget> menuList(){
    return [
      ListTile(
        title: Text(
          "Edit profile"
        ),
        onTap: (){},
      ),
      ListTile(
        title: Text(
          "Vehicle Management"
        ),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => VehicleManagePage()));
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
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/'));
  }

}