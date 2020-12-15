import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/main.dart';

class VehicleCardTileFull extends StatefulWidget {
  final Vehicle data;
  final double cardMargin;
  final Function setState;
  VehicleCardTileFull({@required this.data,this.cardMargin,this.setState});
  VehicleCardTileFullState createState() => VehicleCardTileFullState();
}

class VehicleCardTileFullState extends State<VehicleCardTileFull> {
  Vehicle editData;
  double fieldPadding = 16.0;
  TextStyle fieldTextStyle = TextStyle(
    color: Colors.black.withOpacity(0.7)
  );
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    setEditDataDefault();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.all(widget.cardMargin == null ? 0.0 : widget.cardMargin),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Container(
          padding: EdgeInsets.all(16.0),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Icon(Icons.motorcycle),
                      // SizedBox(width: 8.0),
                      Text(
                        widget.data.brand + " " + widget.data.model,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(width: 8.0),
                      if(widget.data.isDefault)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 8.0, right: 8.0),
                            color: Colors.red,
                            child: Text("Default", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          child: InkWell(
                            child: SizedBox(width: 32, height: 32, child: Icon(Icons.edit)),
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(
                              //     builder: (context) => ReqList(data: widget.data)));
                              setState(() {
                                isEdit = true;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ClipOval(
                        child: Material(
                          child: InkWell(
                            child: SizedBox(width: 32, height: 32, child: Icon(Icons.delete)),
                            onTap: () {
                              _deleteDialog();
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 16.0),
              for(Widget w in infoField()) w
            ],
          )
      ),
    );
  }

  void setEditDataDefault(){
    editData = new Vehicle(
      vid: widget.data.vid,
      brand: widget.data.brand,
      license: widget.data.license,
      model: widget.data.model,
      color: widget.data.color,
      type: widget.data.type,
      isDefault: widget.data.isDefault
    );
  }

  Future<void> _deleteDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                await widget.data.deleteVehicle();
                Navigator.of(context).pop();
                widget.setState();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> infoField(){
    if(isEdit){
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: CardTextField(
                labelText: "ทะเบียน",
                initValue: editData.license,
                onChanged: (val){
                  editData.license = val;
                },
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: CardTextField(
                labelText: "ยี่ห้อ",
                initValue: editData.brand,
                onChanged: (val){
                  editData.brand = val;
                },
              )
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: <Widget>[
            Expanded(
              child: CardTextField(
                labelText: "รุ่น",
                initValue: editData.model,
                onChanged: (val){
                  editData.model = val;
                },
              )
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: CardTextField(
                labelText: "สี",
                initValue: editData.color,
                onChanged: (val){
                  editData.color = val;
                },
              )
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: <Widget>[
            Checkbox(
              // title: const Text("Set to default vehicle"),

              value: editData.isDefault,
              onChanged: (val){
                setState(() {
                  editData.isDefault = val;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text("cancel"),
              onPressed: (){
                setState(() {
                  setEditDataDefault();
                  isEdit = false;
                });
              },
            ),
            FlatButton(
              child: Text("ok"),
              onPressed: () async {
                // print(editData.toJson());
                isEdit = false;
                await editData.editVehicle();
                setState(() {});
                widget.setState();
              },
            )
          ],
        ),
      ];
    } else {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Theme
                      .of(context)
                      .canvasColor,
                  padding: EdgeInsets.all(fieldPadding),
                  child: Column(
                    children: <Widget>[
                      Text('ทะเบียน', style: fieldTextStyle),
                      Text(widget.data.license)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Theme
                      .of(context)
                      .canvasColor,
                  padding: EdgeInsets.all(fieldPadding),
                  child: Column(
                    children: <Widget>[
                      Text('ยี่ห้อ', style: fieldTextStyle),
                      Text(widget.data.brand)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Theme
                      .of(context)
                      .canvasColor,
                  padding: EdgeInsets.all(fieldPadding),
                  child: Column(
                    children: <Widget>[
                      Text('รุ่น', style: fieldTextStyle),
                      Text(widget.data.model)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                    color: Theme
                        .of(context)
                        .canvasColor,
                    padding: EdgeInsets.all(fieldPadding),
                    child: Column(
                      children: <Widget>[
                        Text('สี', style: fieldTextStyle),
                        Text(widget.data.color)
                      ],
                    )
                ),
              ),
            ),
          ],
        )
      ];
    }
  }

}