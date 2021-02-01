import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/Match_Info.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Pages/mapview.dart';
import 'package:travel_sharing/UI/ProfileInfo.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

class MatchMapCard extends StatefulWidget {
  final String url;
  final Match_Info data;
  final Travel_Info userData;
  final bool isreq;
  final bool isPress;
  final Function onButtonPressed;
  final Function onCardPressed;

  const MatchMapCard({Key key,this.isPress,this.url ,this.data, this.isreq,this.onButtonPressed, this.userData, this.onCardPressed}) : super(key: key);
  @override
  _MatchMapCardState createState() => _MatchMapCardState();
}

class _MatchMapCardState extends State<MatchMapCard> {

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        onPressed: () => widget.onCardPressed(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    child: Ink.image(
                      fit: BoxFit.cover,
                      image: Image.network(widget.url).image,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: 48,
                      child: RawMaterialButton(
                        elevation: 1,
                        highlightElevation: 1,
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MapView(paiDuay: widget.userData.routes, chuan: widget.data.routes)));
                        },
                        shape: CircleBorder(),
                        fillColor: Colors.white,
                        child: Icon(Icons.map),
                      ),
                    ),
                  ),
                  if(widget.data.isOffer)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(20.0),
                      color: Theme.of(context).colorScheme.success,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: Text(
                          AppLocalizations.instance.text("offer"),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                child: Wrap(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(AppLocalizations.instance.text("dst"), style: TextStyle(fontSize: 10.0)),
                                          SizedBox(height: 5.0),
                                          Text(widget.data.routes.dst, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 16.0),
                                          Text(AppLocalizations.instance.text("src"), style: TextStyle(fontSize: 10.0)),
                                          SizedBox(height: 5.0),
                                          Text(widget.data.routes.src, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  rightWidget()
                                ],
                              ),
                              SizedBox(height: 16.0),
                              InkWell(
                                onTap: () async {
                                  swipeUpDialog(
                                    context,
                                    ProfileInfo(
                                        data: widget.data.user,
                                        isHost: false
                                    )
                                  );
                                },
                                borderRadius: BorderRadius.circular(20.0),
                                child: Row(
                                  children: <Widget>[
                                    Material(
                                      shape: CircleBorder(),
                                      clipBehavior: Clip.antiAlias,
                                      color: Colors.grey,
                                      child: ClipOval(
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          child: widget.data.user.imgpath != null
                                              ? Ink.image(image: Image.network("${httpClass.API_IP}${widget.data.user.imgpath}").image)
                                              : Icon(Icons.person, color: Colors.white, size: 20),
                                        )
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.data.user.name, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                        Row(
                                          children: [
                                            RatingBarIndicator(
                                              rating: widget.data.user.reviewSummary.amount == 0 ? 0.0: widget.data.user.reviewSummary.totalscore/widget.data.user.reviewSummary.amount,
                                              itemBuilder: (context, index) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 16.0,
                                              direction: Axis.horizontal,
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(widget.data.user.reviewSummary.amount == 0 ? "0.0": (widget.data.user.reviewSummary.totalscore/widget.data.user.reviewSummary.amount).toStringAsPrecision(2), style: TextStyle(fontSize: 10.0)),
                                            SizedBox(width: 4.0),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 2.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20.0),
                                                  border: Border.all(color: Colors.black, width: 0.5)
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.people, size: 10.0),
                                                  SizedBox(width: 2.0),
                                                  Text(widget.data.user.reviewSummary.amount.toString(), style: TextStyle(fontSize: 10.0)),
                                                  SizedBox(width: 1.0),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: RaisedButton(
                            highlightElevation: 0.0,
                            padding: EdgeInsets.all(16.0),
                            color: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                if (widget.isPress)
                                SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator(strokeWidth: 2,valueColor: AlwaysStoppedAnimation(Colors.white),),
                                ),
                                if (widget.isPress)
                                SizedBox( width: 20,),
                                Text(widget.isreq ? AppLocalizations.instance.text("reqFin") : widget.isPress ? AppLocalizations.instance.text("loading"): AppLocalizations.instance.text("req"), style: TextStyle(color: Colors.white,)),
                              ],
                            ),
                            onPressed: widget.isreq ? null : widget.isPress ? null :() async {
                              widget.onButtonPressed();
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget rightWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Vehicle().getTypeIcon(widget.data.routes.vehicle.type, 32),
        SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(
                  10.0)
          ),
          child: Column(
            children: <Widget>[
              Text(
                DateManage().datetimeFormat("day", widget.data.routes.date) + " " + DateManage().datetimeFormat("month", widget.data.routes.date),
                style: TextStyle(
                    fontSize: 10.0
                ),
              ),
              Text(DateManage().datetimeFormat("time", widget.data.routes.date))
            ],
          ),
        ),
        if(widget.data.routes.role == "0")
          SizedBox(height: 12.0),
        if(widget.data.routes.role == "0")
          Text(widget.data.routes.cost == "0" ? AppLocalizations.instance.text("free") :"฿${widget.data.routes.cost}"),
        SizedBox(height: 8.0),
        Text(
          widget.data.routes.role == "1"
              ? "ไปด้วย"
              : "ต้องการ",
          style: TextStyle(fontSize: 12.0),
        ),
        Text(
          widget.data.routes.role == "1"
              ? '${widget.data.routes.amount} ${AppLocalizations.instance.text("personUnit")}'
              : '${int.parse(
              widget.data.routes.amount) -
              widget.data.routes.match.length} ${AppLocalizations.instance.text("personUnit")}',
          style: TextStyle(fontSize: 12.0),
        )
      ],
    );
  }
}
