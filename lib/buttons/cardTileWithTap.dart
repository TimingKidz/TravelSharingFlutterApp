import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_sharing/Class/RouteJson.dart';

class CardTileWithTap extends StatefulWidget {
  final Routes data;
  final IconData iconData;
  final Function onCardPressed;

  CardTileWithTap({
    this.data,
    this.iconData,
    this.onCardPressed
  });


  @override
  CardTileWithTapState createState() => CardTileWithTapState();
}

class CardTileWithTapState extends State<CardTileWithTap> {
  bool alreadySaved = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
        child: FlatButton(
          padding: EdgeInsets.only(top: 16.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          onPressed: () {
            widget.onCardPressed();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('ปลายทาง', style: TextStyle(fontSize: 10.0)),
                    SizedBox(height: 5.0),
                    Text(widget.data.dst, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.0),
                    Text('ต้นทาง', style: TextStyle(fontSize: 10.0, color: Colors.black54)),
                    SizedBox(height: 5.0),
                    Text(widget.data.src, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0)
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('${datetimeFormat('date')} | ${datetimeFormat('time')}', style: TextStyle(color: Colors.white)),
                    Text('0/${widget.data.amount}', style: TextStyle(color: Colors.white)),
                  ],
                )
              )
//              Row(
//                children: <Widget>[
//                  ClipRRect(
//                      borderRadius: BorderRadius.circular(10.0),
//                      child: Container(
//                          padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 6.0, right: 8.0),
//                          color: Colors.indigo,
//                          child: Row(
//                            children: <Widget>[
//                              Container(
//                                child: Icon(widget.iconData != null ? widget.iconData : Icons.block, size: 16.0, color: Colors.white),
//                                margin: EdgeInsets.only(bottom: 2.0),
//                              ),
//                              SizedBox(width: 4.0),
//                              Text(widget.data[DatabaseHelper.columnCateName].toString().toUpperCase(), style: TextStyle(color: Colors.white)),
//                            ],
//                          )
//                      )
//                  ),
//                  Container(
//                    padding: EdgeInsets.all(4.0),
//                  ),
//                  ClipRRect(
//                      borderRadius: BorderRadius.circular(10.0),
//                      child: condition()
//                  ),
//                ],
//              ),
//              SizedBox(height: 6.0),
//              Align(
//                alignment: Alignment.centerLeft,
//                child: Text(
//                    'Price ${NumberFormat.simpleCurrency(locale: 'th', decimalDigits: 0).format(widget.data[DatabaseHelper.columnPrice])} ' + warrantyText(),
//                    style: TextStyle(color: Colors.grey.shade700)),
//              ),
//              SizedBox(height: 6.0),
//              Align(
//                alignment: Alignment.centerLeft,
//                child: Text('Purchase Date : ${dateFormat()}', style: TextStyle(color: Colors.grey.shade700)),
//              ),
            ],
          ),
        )
    );
  }

//  String warrantyText() {
//    String textShown = '${widget.data[DatabaseHelper.columnWarrantyPeriod]} months warranty';
//
//    if(widget.data[DatabaseHelper.columnWarrantyPeriod] == '')
//      textShown = 'without warranty';
//    else if(widget.data[DatabaseHelper.columnWarrantyPeriod] % 12 == 0)
//      textShown = 'with ${(widget.data[DatabaseHelper.columnWarrantyPeriod]/12).toInt()} years warranty';
//
//    return textShown;
//  }

//  Widget condition(){
//    Color color;
//    if(widget.data[DatabaseHelper.columnStatus] == 'IN-USE'){
//      color = Colors.green;
//    }else if(widget.data[DatabaseHelper.columnStatus] == 'SOLD'){
//      color = Colors.amber;
//    }else if(widget.data[DatabaseHelper.columnStatus] == 'LOST'){
//      color = Colors.black38;
//    }else if(widget.data[DatabaseHelper.columnStatus] == 'BROKEN'){
//      color = Colors.red;
//    }else{
//      color = Colors.pinkAccent;
//    }
//
//    return Container(
//      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 8.0, right: 8.0),
//      color: color,
//      child: Text(widget.data[DatabaseHelper.columnStatus], style: TextStyle(color: Colors.white)),
//    );
//  }

  String datetimeFormat(String check) {
    var datetimeFromDB = DateTime.parse(widget.data.date);
    if(check == 'date'){
      return DateFormat('d MMM yyyy').format(datetimeFromDB);
    }else{
      return DateFormat('HH:mm').format(datetimeFromDB);
    }
  }
}