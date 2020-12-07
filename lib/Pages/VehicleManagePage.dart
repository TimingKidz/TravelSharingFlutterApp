import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehicleManagePage extends StatefulWidget {
  VehicleManagePageState createState() => VehicleManagePageState();
}

class VehicleManagePageState extends State<VehicleManagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Manager"),
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, i) {
          return _buildRow(i.toString());
        }
    );
  }

  Widget _buildRow(String data) {
    return ListTile(
      title: Text(data),

    );
  }

}