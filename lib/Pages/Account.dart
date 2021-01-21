import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/Pages/HistoryPage.dart';
import 'package:travel_sharing/Pages/LanguageSelect.dart';
import 'package:travel_sharing/Pages/ProfileManagePage.dart';
import 'package:travel_sharing/Pages/ReviewView.dart';
import 'package:travel_sharing/Pages/VehicleManagement/VehicleManagePage.dart';
import 'package:travel_sharing/buttons/VehicleCardTileMin.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/localization.dart';

class Account extends StatefulWidget {
  final Function setSate;
  const Account({Key key, this.setSate}) : super(key: key);
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {
  bool isLoading = false;

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
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.grey,
                      child: ClipOval(
                        child: currentUser.imgpath != null
                            ? Image.network("${httpClass.API_IP}${currentUser.imgpath}")
                            : Container(
                          width: 128.0,
                          height: 128.0,
                          child: Icon(Icons.person, color: Colors.white, size: 64),
                        ),
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
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ReviewView(user: currentUser)));
                      },
                      borderRadius: BorderRadius.circular(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RatingBarIndicator(
                            rating: currentUser.reviewSummary.amount == 0 ? 0.0: currentUser.reviewSummary.totalscore/currentUser.reviewSummary.amount,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 30.0,
                            direction: Axis.horizontal,
                          ),
                          SizedBox(width: 4.0),
                          Text(currentUser.reviewSummary.amount == 0 ? "0.0": (currentUser.reviewSummary.totalscore/currentUser.reviewSummary.amount).toString(), style: TextStyle(fontSize: 16.0, color: Colors.white)),
                          SizedBox(width: 4.0),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(color: Colors.white, width: 0.5)
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.people, size: 14.0, color: Colors.white),
                                SizedBox(width: 2.0),
                                Text(currentUser.reviewSummary.amount.toString(), style: TextStyle(fontSize: 14.0, color: Colors.white)),
                                SizedBox(width: 1.0),
                              ],
                            ),
                          ),
                          SizedBox(width: 4.0),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    if(Vehicle().defaultVehicle() != null)
                      VehicleCardTileMin(data: Vehicle().defaultVehicle())
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
    socket.off('onAccept');
    socket.off('onNewNotification');
    socket.off('onNewAccept');
    socket.off('onNewMatch');
    socket.off('onNewMessage');
    socket.off('onRequest');
    socket.off('onTripEnd');
    socket.off('onKick');

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
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
      widget.setSate();
    });
  }

  List<Widget> menuList(){
    return [
      ListTile(
        title: Text(
            AppLocalizations.instance.text("Profile")
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
            AppLocalizations.instance.text("Vehicle Management")
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
          AppLocalizations.instance.text("History")
        ),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => HistoryPage())).then((value){
            _pageConfig();
            widget.setSate();
//            setState((){});
          });
        },
      ),
      ListTile(
        title: Text(
          AppLocalizations.instance.text("Language")
        ),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => LanguageSelect())).then((value){
//            _pageConfig();
            setState((){});
          });
        },
      ),
      SizedBox(
        height: 32.0,
      ),
      if(isLoading)
        CircularProgressIndicator(),
      if(!isLoading)
      ListTile(
        title: Center(
          child: Text(
            AppLocalizations.instance.text("SIGNOUT"),
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
    isLoading = true;
    currentUser.updateToken(" ").then((value) async {
      if(value){
        socket = socket.disconnect();
        socket.destroy();
        socket.dispose();
        googleUser = await googleSignIn.signOut();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/'));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not sign out. Please try again.")));
        setState(() { isLoading = false; });
      }
    });

  }

}