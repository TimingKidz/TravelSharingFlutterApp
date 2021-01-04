import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/Class/History.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/Class/Travel_Info.dart';
import 'package:travel_sharing/Pages/Matchinformation.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/main.dart';

// TODO: Implement History Page
class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Travel_Info> historyList = List();

  @override
  void initState() {
    getHistoryList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 80),
              child: historyList.isNotEmpty ? _buildListView() : Center(
                child: Text("Nothing in your history yet."),
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
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        tooltip: "back",
                        iconSize: 26.0,
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        "History",
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
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: historyList.length,
        itemBuilder: (context, i) {
          return _buildRow(historyList[i]);
        }
    );
  }

  Widget _buildRow(Travel_Info data) {
    return ListTile(
      onTap: (){
        if(data.routes.role == "0") Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: data.routes.uid, data: data, isHistory: true)));
        else Navigator.push(context, MaterialPageRoute(
            builder: (context) => Matchinformation(uid: data.routes.match.first, data: data, isHistory: true)));
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            data.routes.src
          ),
          Icon(Icons.navigate_next_outlined),
          Text(
            data.routes.dst
          )
        ],
      ),
      subtitle: Text(DateManage().datetimeFormat("full", data.routes.date)),
      trailing: Icon(Icons.navigate_next),
    );
  }

  Future<void> getHistoryList() async {
    print("Get History List");
    try{
      historyList =  await Routes().getHistory(currentUser.uid) ?? [];
      setState(() {});
    }catch(error){
      print("$error history");
    }
  }
}
