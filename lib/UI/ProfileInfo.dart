import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/UI/PlainBGInfo.dart';
import 'package:travel_sharing/main.dart';

class ProfileInfo extends StatelessWidget {
  final User data;
  final bool isHost;
  final Function kickFunct;
  const ProfileInfo({Key key, @required this.data, this.isHost, this.kickFunct}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 16.0),
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 64,
                  child: ClipOval(
                    child: Image.network(
                      "${httpClass.API_IP}${data.imgpath}",
                    ),
                  ),
                ),
              ),
              if(isHost != null ? isHost : false)
                Align(
                  alignment: Alignment.topRight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Material(
                      color: Colors.red,
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          child: Text("Kick", style: TextStyle(color: Colors.white)),
                        ),
                        onTap: () async {
                            kickFunct();
                            Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                )
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            data.name,
            style: TextStyle(
              fontSize: 18.0
            ),
          ),
          SizedBox(height: 28.0),
          PlainBGInfo(label: "Email", info: data.email),
          SizedBox(height: 16.0),
          PlainBGInfo(label: "Faculty", info: data.faculty),
          SizedBox(height: 16.0),
          PlainBGInfo(label: "Gender", info: data.gender),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
