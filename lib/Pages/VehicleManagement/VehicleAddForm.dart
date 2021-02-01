import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/DropdownVar.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/localization.dart';

class VehicleAddForm extends StatefulWidget {
  VehicleAddFormState createState() => VehicleAddFormState();
}

class VehicleAddFormState extends State<VehicleAddForm> {
  Vehicle vehicleData = Vehicle();
  bool isChecked = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    vehicleData.isDefault = false;
    vehicleData.type = DropdownVar().vehicleType.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Form(
              key: _formKey,
              child: ListView.separated(
                separatorBuilder: (context, _){
                  return SizedBox(height: 8.0);
                },
                padding: EdgeInsets.fromLTRB(8.0, 115.0, 8.0, 8.0),
                physics: BouncingScrollPhysics(),
                itemCount: formList().length,
                itemBuilder: (context, i){
                  return formList()[i];
                },
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
                            AppLocalizations.instance.text("AddVehicle"),
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
                        icon: Icon(Icons.check),
                        tooltip: AppLocalizations.instance.text("AddVehicle"),
                        iconSize: 26.0,
                        color: Colors.white,
                        onPressed: () async {
                          if(_formKey.currentState.validate()){
                            await vehicleData.addVehicle();
                            Navigator.of(context).pop();
                          }
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



  List<Widget> formList(){
    return [
      CardDropdown(
        listItems: DropdownVar().vehicleType,
        labelText: AppLocalizations.instance.text("type"),
        dropdownTileBuild: (value) {
          return Text(value);
        },
        onChanged: (data) => vehicleData.type = data,
      ),
      CardTextField(
        notNull: true,
        labelText: AppLocalizations.instance.text("license"),
        onChanged: (data) => vehicleData.license = data,
      ),
      CardTextField(
        notNull: true,
        labelText: AppLocalizations.instance.text("brand"),
        onChanged: (data) => vehicleData.brand = data,
      ),
      CardTextField(
        notNull: true,
        labelText: AppLocalizations.instance.text("model"),
        onChanged: (data) => vehicleData.model = data,
      ),
      CardTextField(
        notNull: true,
        labelText: AppLocalizations.instance.text("color"),
        onChanged: (data) => vehicleData.color = data,
      ),
      CheckboxListTile(
        title: Text(AppLocalizations.instance.text("setDefault")),
        value: vehicleData.isDefault,
        onChanged: (val){
          setState(() {
            vehicleData.isDefault = val;
          });
        },
      ),
    ];
  }

}