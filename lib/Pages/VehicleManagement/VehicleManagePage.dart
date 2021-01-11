import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/Pages/VehicleManagement/VehicleAddForm.dart';
import 'package:travel_sharing/buttons/VehicleCardTileFull.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class VehicleManagePage extends StatefulWidget {
  VehicleManagePageState createState() => VehicleManagePageState();
}

class VehicleManagePageState extends State<VehicleManagePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 70),
              child: currentUser.vehicle.isNotEmpty ? _buildListView() : Center(
                child: Text("No vehicle yet."),
              ),
            ),
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(0.0),
              color: Theme.of(context).colorScheme.darkBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)
                  )
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 16.0, right: 4.0),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            tooltip: AppLocalizations.instance.text("back"),
                            iconSize: 26.0,
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          SizedBox(width: 16.0),
                          Text(
                            AppLocalizations.instance.text("Vehicle Management"),
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                            // textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        tooltip: AppLocalizations.instance.text("AddVehicle"),
                        iconSize: 26.0,
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(
                              builder : (context) => VehicleAddForm())).then((value){
                            getData();
                            setState((){});
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: currentUser.vehicle.length,
        itemBuilder: (context, i) {
          return _buildRow(currentUser.vehicle[i]);
        }
    );
  }

  Widget _buildRow(Vehicle data) {
    return VehicleCardTileFull(
      data: data,
      cardMargin: 8.0,
      setState: getData,
    );
  }

  Future<void> getData() async {
    currentUser = await currentUser.getCurrentuser(currentUser.id);
    setState(() {});
  }

}