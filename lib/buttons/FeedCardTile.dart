import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/Feed.dart';
import 'package:travel_sharing/Class/Vehicle.dart';
import 'package:travel_sharing/Dialog.dart';
import 'package:travel_sharing/UI/ProfileInfo.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/main.dart';

class FeedCardTile extends StatefulWidget {
  final Feed data;
  final IconData iconData;
  final Function onCardPressed;

  FeedCardTile({
    this.data,
    this.iconData,
    this.onCardPressed
  });

  @override
  FeedCardTileState createState() => FeedCardTileState();
}

class FeedCardTileState extends State<FeedCardTile> {
  BorderRadius cardBorder = BorderRadius.circular(20.0);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        shape: RoundedRectangleBorder(
            borderRadius: cardBorder
        ),
        onPressed: () {
          widget.onCardPressed();
        },
        child: Stack(
          children: <Widget>[
            widget.data.routes.imgpath != null || widget.data.routes.description.isNotEmpty
            ? Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      leftWidget(),
                      SizedBox(width: 16.0),
                      Flexible(child: Container(child: mainInfo()))
                    ],
                  ),
                ),
                if(widget.data.routes.description.isNotEmpty)
                  tripImage(),
                if(widget.data.routes.imgpath != null)
                  tripDescription(),
                SizedBox(height: 8.0),
                Align(alignment: Alignment.centerRight, child: profile())
              ],
            )
            : Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: leftWidget(),
                ),
                Flexible(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: mainInfo()
                          ),
                        ),
                        Align(alignment: Alignment.centerRight,child: profile())
                      ],
                    ),
                  ),
                )
              ],
            ),
            badge() // Type badge
          ],
        )
    );
  }

  GlobalKey _tooltipKey = GlobalKey();

  // Date, Time, and People Widget
  Widget leftWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 8.0),
        widget.data.routes.role == "0"
            ? InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () {
            final dynamic tooltip = _tooltipKey.currentState;
            tooltip.ensureTooltipVisible();
            Future.delayed(Duration(milliseconds: 1500), () => tooltip.deactivate());
          },
          child: Tooltip(
            key: _tooltipKey,
            message: "${widget.data.routes.vehicle.brand} ${widget.data.routes.vehicle.model}",
            child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: Vehicle().getTypeIcon(widget.data.routes.vehicle.type,32)
            ),
          ),
        )
            : SizedBox(
            width: 40.0,
            height: 40.0,
            child: Vehicle().getTypeIcon(widget.data.routes.vehicle.type,32)
        ),
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
              ? '${widget.data.routes.amount} คน'
              : '${int.parse(
              widget.data.routes.amount) -
              widget.data.routes.match.length} คน',
          style: TextStyle(fontSize: 12.0),
        )
      ],
    );
  }

  // Source and Destination widget
  Widget mainInfo(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment
          .start,
      children: <Widget>[
        Text(AppLocalizations.instance.text("dst"),
            style: TextStyle(fontSize: 10.0)),
        SizedBox(height: 8.0),
        Text(widget.data.routes.dst,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 24.0),
        Text(AppLocalizations.instance.text("src"), style: TextStyle(
            fontSize: 10.0,
            color: Colors.black54)),
        SizedBox(height: 8.0),
        Text(widget.data.routes.src,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
      ],
    );
  }

  Widget tripImage(){
    return Column(
      children: [
        SizedBox(height: 8.0),
        Ink(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(20.0)
          ),
          width: MediaQuery.of(context).size.width - 32 - 8,
          child: Text(
              widget.data.routes.description
          ),
        ),
      ],
    );
  }

  Widget tripDescription(){
    return Column(
      children: [
        SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20.0)
          ),
          clipBehavior: Clip.antiAlias,
          width: MediaQuery.of(context).size.width - 32 - 8,
          height: MediaQuery.of(context).size.width - 32 - 8,
          child: widget.data.routes.imgpath != null ? Image.network("${httpClass.API_IP}${widget.data.routes.imgpath}") : Icon(Icons.broken_image, color: Colors.white),
        ),
      ],
    );
  }

  Widget profile(){
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Wrap(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 0.0),
              child: Ink(
                padding: EdgeInsets.fromLTRB(8.0, 4.0, 40.0, 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(widget.data.user.name, textAlign: TextAlign.end, style: TextStyle(fontSize: 12.0)),
              ),
            ),
          ],
        ),
        Material(
            shape: CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: Colors.grey,
            child: InkWell(
              onTap: () {
                swipeUpDialog(context, ProfileInfo(data: widget.data.user));
              },
              child: widget.data.user.imgpath != null
                  ? Ink.image(
                image: Image.network("${httpClass.API_IP}${widget.data.user.imgpath}").image,
                fit: BoxFit.cover,
                width: 48.0,
                height: 48.0,
              )
                  : Container(
                width: 48.0,
                height: 48.0,
                child: Icon(Icons.person, color: Colors.white),
              ),
            )
        )
      ],
    );
  }

  Widget badge(){
    return Align(
      alignment: Alignment.topRight,
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(20.0),
        color: Theme
            .of(context)
            .accentColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Text(widget.data.routes.tag.first, style: TextStyle(fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}