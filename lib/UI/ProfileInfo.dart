import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/UI/PlainBGInfo.dart';
import 'package:travel_sharing/main.dart';

class ProfileInfo extends StatelessWidget {
  final User data;

  const ProfileInfo({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 16.0),
          CircleAvatar(
            radius: 64,
            child: ClipOval(
              child: Image.network(
                "${httpClass.API_IP}${data.imgpath}",
              ),
            ),
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
