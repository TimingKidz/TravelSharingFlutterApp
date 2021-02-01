import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_sharing/Class/DropdownVar.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/buttons/CardDropdown.dart';
import 'package:travel_sharing/buttons/CardPicker.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool isActivity = false;
  bool isLoading = false;

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
    Final_Data.tag = [DropdownVar().tagList.first];
    Final_Data.vehicle = widget.Role == 0 ? (Vehicle().defaultVehicle() ?? currentUser.vehicle.first) : null;
    Final_Data.range = "15";
    Final_Data.amount = "1";
    if(widget.data != null){
      Final_Data.tag = widget.data.tag;
      Final_Data.date = DateTime.parse(widget.data.date).toLocal().toString();
      Final_Data.range = widget.data.range;
    }
//    print(widget.data.date);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
          icon: isLoading ? SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator(strokeWidth: 2,valueColor: AlwaysStoppedAnimation(Colors.black),),
          ) : Icon(isActivity ? Icons.check : Icons.arrow_forward_sharp),
          label: isLoading ? Text(AppLocalizations.instance.text("loading")) : Text(isActivity ? AppLocalizations.instance.text("finish") : AppLocalizations.instance.text("next")),
          onPressed: isLoading ? null : (){
            if(_formKey.currentState.validate()){
              if(!isActivity){
                setState(() {
                  isActivity = !isActivity;
                });
              }else{
                setState(() { isLoading = true; });
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
          labelText: AppLocalizations.instance.text("tag"),
          listItems: DropdownVar().tagList,
          initData: Final_Data.tag.first,
          dropdownTileBuild: (value) {
            return Text(value);
          },
          onChanged: (text) {
            setState(() {
              Final_Data.tag = [text];
            });
          },
        ),
        if(widget.Role == 0)
          SizedBox(height: 8.0),
        if(widget.Role == 0)
          CardDropdown(
            labelText: AppLocalizations.instance.text("selectVehicle"),
            initData: Final_Data.vehicle,
            listItems: currentUser.vehicle,
            dropdownTileBuild: (value) {
              return Text("${value.brand} ${value.model} - ${value.license}");
            },
            onChanged: (data) {
              Final_Data.vehicle = data;
            },
          ),
        SizedBox(height: 8.0),
        CardTextField(
          notNull: true,
          initValue: widget.src,
          labelText: AppLocalizations.instance.text("src"),
          onChanged: (text) {
            Final_Data.src = text;
          },
        ),
        SizedBox(height: 8.0),
        CardTextField(
          notNull: true,
          initValue: widget.dst,
          labelText: AppLocalizations.instance.text("dst"),
          onChanged: (text) {
            Final_Data.dst = text;
          },
        ),
        SizedBox(height: 8.0),
        CardDatePicker(
            labelText: AppLocalizations.instance.text("dateTravel"),
            initDateTime: DateTime.parse(Final_Data.date),
            onDatePick: (date) {
              Final_Data.date = date;
            }
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: CardPicker(
                labelText: widget.Role == 0 ? AppLocalizations.instance.text("tripDemandChuan") : AppLocalizations.instance.text("tripDemandPaiDuay"),
                unit: AppLocalizations.instance.text("personUnit"),
                initItem: Final_Data.amount,
                itemsList: [for(int i = 1; i <= 10; i++) "$i"],
                onChange: (text){
                  Final_Data.amount = text;
                },
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: CardPicker(
                labelText: AppLocalizations.instance.text("timerange"),
                unit: AppLocalizations.instance.text("minute"),
                initItem: Final_Data.range,
                tipsText: "ช่วงเวลาบวกลบจากเวลาที่คุณต้องการเดินทาง เพื่อเพิ่มโอกาสในการจับคู่กับคนอื่นมากขึ้น ยิ่งช่วงกว้าง ยิ่งเพิ่มโอกาส เช่น \n\n"
                    "เดินทางเวลา 12:00 และเลือกช่วง 15 นาที คุณจะถูกจับคู่กับคนที่เดินทางในช่วง 11:45 - 12:15",
                itemsList: ["15", "30", "45", "60"],
                onChange: (text){
                  Final_Data.range = text;
                },
              ),
            )
          ],
        ),
        if(widget.Role == 0)
          SizedBox(height: 8.0),
        if(widget.Role == 0)
          CardTextField(
          initValue: Final_Data.cost ?? "",
          labelText: AppLocalizations.instance.text("price"),
          type: TextInputType.number,
          inputFormat: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (text) {
            print(text);
            Final_Data.cost = text;
          },
        ),
        SizedBox(height: 72)
      ],
    );
  }

  String description = "";
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
            labelText: AppLocalizations.instance.text("description"),
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
    image = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    if(image != null)
      await _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 75,
        maxHeight: 1080,
        maxWidth: 1080,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: AppLocalizations.instance.text("cropimg"),
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
            title: AppLocalizations.instance.text("cropimg"),
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
        vehicle: widget.Role == 0 ? Final_Data.vehicle : Vehicle(type: int.parse(Final_Data.amount) > 1 ? "People" : "Person"),
        tag: Final_Data.tag,
        cost: widget.Role == 0 ? ( Final_Data.cost == "" ? "0" : Final_Data.cost ): "0",
        range: Final_Data.range,
        description: description
    );

    Final_Data.SaveRoute_toDB(user,widget.data).then((x){
      if(x != null){
        if(selectedImage != null){
          currentUser.uploadImg(selectedImage, x.uid).then((value){
            if(value){
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.popUntil(context, ModalRoute.withName('/homeNavigation'));
            }else{
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.instance.text("imgUploadErr"))));
            }
          });
        }else{
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.popUntil(context, ModalRoute.withName('/homeNavigation'));
        }
      }else{
        setState(() { isLoading = false; });
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.instance.text("routeCreateErr"))));
      }
    });
  }
}

