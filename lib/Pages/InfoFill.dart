import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/cardDatePicker.dart';
import 'package:travel_sharing/buttons/cardTextField.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class InfoFill extends StatefulWidget {
  final List<LatLng> routes;
  final LatLngBounds bounds;
  final Set<Polyline> lines;
  final Set<Marker> Markers;
  final String src ;
  final String dst;
  final int Role;
  final Routes data;

  const InfoFill({Key key,this.routes, this.bounds, this.lines, this.Markers, this.src, this.dst,this.Role,this.data}) : super(key: key);
  _InfoFillState createState() => _InfoFillState();
}

class _InfoFillState extends State<InfoFill> {
  GoogleMapController _mapController;
  Routes Final_Data = new Routes();
  List<String> tagList = ["Travel", "T&A"];
  final _formKey = GlobalKey<FormState>();
  bool isActivity = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }

  @override
  void initState() {
    super.initState();
    Final_Data.date =  DateTime.now().toString();
    Final_Data.src = widget.src;
    Final_Data.dst = widget.dst;
    Final_Data.tag = [tagList.first];
    if(widget.data != null){
      Final_Data.tag = widget.data.tag;
      Final_Data.date = DateTime.parse(widget.data.date).toLocal().toString();
      Final_Data.range = widget.data.range;
    }
    print(widget.data.date);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(isActivity){
          setState(() {
            isActivity = !isActivity;
          });
          return false;
        }else{
          return true;
        }
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          elevation: 2,
          highlightElevation: 2,
          icon: Icon(Final_Data.tag.first == "Travel & Activity" ? (isActivity ? Icons.check : Icons.arrow_forward_sharp) : Icons.check),
          label: Text(Final_Data.tag.first == "Travel & Activity" ? (isActivity ? "Finish" : "Next") : "Finish"),
          onPressed: (){
            if(_formKey.currentState.validate()){
              if(Final_Data.tag.first == "Travel & Activity"){
                setState(() {
                  isActivity = !isActivity;
                });
              }else{
                _SavetoDB();
              }
            }
          },
          heroTag: null,
        ),
          body: Stack(
            children: <Widget>[
              Form(
                key: _formKey,
                child: isActivity ? activityForm() : infoForm(),
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
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          tooltip: AppLocalizations.instance.text("back"),
                          iconSize: 26.0,
                          color: Colors.white,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          AppLocalizations.instance.text("InfoFormTitle"),
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                          // textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget infoForm(){
    return ListView(
      padding: EdgeInsets.fromLTRB(8.0, MediaQuery.of(context).size.height * 0.135, 8.0, 8.0),
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        Card(
          margin: EdgeInsets.all(0.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: AbsorbPointer(
                absorbing: true,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.routes.last.latitude,widget.routes.last.longitude),
                    zoom: 14,
                  ),
                  markers: widget.Markers,
                  polylines: widget.lines ?? Set(),
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        CardDropdown(
          labelText: 'Tag',
          listItems: tagList,
          initData: Final_Data.tag.first,
          dropdownTileBuild: (value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 18.0
                ),
              ),
            );
          },
          onChanged: (text) {
            setState(() {
              Final_Data.tag = [text];
            });
          },
        ),
        SizedBox(height: 8.0),
        CardTextField(
          notNull: true,
          initValue: widget.src,
          labelText: 'ต้นทาง',
          onChanged: (text) {
            Final_Data.src = text;
          },
        ),
        SizedBox(height: 8.0),
        CardTextField(
          notNull: true,
          initValue: widget.dst,
          labelText: 'ปลายทาง',
          onChanged: (text) {
            Final_Data.dst = text;
          },
        ),
        SizedBox(height: 8.0),
        CardDatePicker(
            labelText: 'วันเดินทาง',
            initDateTime: DateTime.parse(Final_Data.date),
            onDatePick: (date) {
              Final_Data.date = date;
            },
            additionWidget: CardTextField(
              labelText: 'ช่วง',
              type: TextInputType.number,
              onChanged: (text) {
                Final_Data.range = text;
              },
            )
        ),
        SizedBox(height: 8.0),
        widget.Role == 0
            ? Row(
          children: [
            Expanded(
              child: CardTextField(
                notNull: true,
                initValue: Final_Data.amount ?? "",
                labelText: 'ต้องการคนไปด้วย',
                type: TextInputType.number,
                onChanged: (text) {
                  Final_Data.amount = text;
                },
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: CardTextField(
                initValue: Final_Data.cost ?? "",
                labelText: 'ราคา',
                type: TextInputType.number,
                onChanged: (text) {
                  print(text);
                  Final_Data.cost = text;
                },
              ),
            )
          ],
        )
            : CardTextField(
              notNull: true,
              initValue: Final_Data.amount ?? "",
              labelText: 'จำนวนคนไปด้วย',
              type: TextInputType.number,
              onChanged: (text) {
                Final_Data.amount = text;
              },
            ),
        if(widget.Role == 0)
          SizedBox(height: 8.0),
        if(widget.Role == 0)
          CardDropdown(
            labelText: 'ยานพาหนะที่จะใช้',
            initData: Final_Data.vehicle,
            listItems: currentUser.vehicle,
            dropdownTileBuild: (value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  "${value.brand} ${value.model} - ${value.license}",
                  style: TextStyle(
                      fontSize: 18.0
                  ),
                ),
              );
            },
            onChanged: (data) {
              Final_Data.vehicle = data;
            },
          ),
        SizedBox(height: 72)
      ],
    );
  }

  String description;
  File selectedImage;

  Widget activityForm(){
    double _imageSize = MediaQuery.of(context).size.width - 16;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(8.0, MediaQuery.of(context).size.height * 0.135, 8.0, 8.0),
      child: Column(
        children: [
          Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            child: selectedImage != null
            ? Ink.image(
              image: Image.file(selectedImage).image,
              fit: BoxFit.cover,
              width: _imageSize,
              height: _imageSize,
              child: InkWell(
                onTap: () {
                  getImage();
                },
              ),
            )
            : InkWell(
              onTap: (){
                getImage();
              },
              child: Container(
                width: _imageSize,
                height: _imageSize,
                color: Colors.black12,
                child: Icon(Icons.add_a_photo),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          CardTextField(
            labelText: "อธิบายกิจกรรมของคุณ",
            minLines: 5,
            maxLines: 8,
            onChanged: (text){
              description = text;
            },
          )
        ],
      ),
    );
  }

  PickedFile image;

  Future getImage() async {
    image = await ImagePicker().getImage(source: ImageSource.gallery);
    if(image != null)
      await _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            rectX: 1,
            rectY: 1
        ));
    if (croppedFile != null) {
      selectedImage = croppedFile;
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) async{
    _mapController = controller;
    Future.delayed(new Duration(milliseconds: 100), () async {
      await _mapController.animateCamera(CameraUpdate.newLatLngBounds(widget.bounds, 50));
    });
  }

  _SavetoDB()async{
    User user = currentUser;
    Final_Data = new Routes(
        id: user.uid,
        routes: widget.routes,
        src: Final_Data.src,
        dst: Final_Data.dst,
        amount: Final_Data.amount,
        date:Final_Data.date,
        isMatch: false,
        match: List(),
        role: widget.Role.toString(),
        vehicle: widget.Role == 0 ? Final_Data.vehicle : Vehicle(),
        tag: Final_Data.tag,
        cost: widget.Role == "0" ? Final_Data.cost : "0",
        range: Final_Data.range
    );

    Final_Data.SaveRoute_toDB(user,widget.data).then((x){
      Navigator.popUntil(context, ModalRoute.withName('/homeNavigation'));
    });
  }
}

