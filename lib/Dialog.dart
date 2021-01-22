import 'package:flutter/material.dart';
import 'package:travel_sharing/Class/RouteJson.dart';
import 'package:travel_sharing/main.dart';

void normalDialog(BuildContext context, Widget child){
  showDialog(
    context: context,
    builder: (BuildContext context){
      return Dialog(
        elevation: 1.0,
        // backgroundColor: Theme.of(context).accentColor,
        insetPadding: EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }
  );
}

void alertDialog(BuildContext context, String title, Widget content, List<Widget> actions){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
        title: Text(title),
        content: content,
        actions: actions,
      );
    },
  );
}

void activityInfoDialog(BuildContext context, Routes data){
  showDialog(
    context: context,
    // barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 1.0,
        backgroundColor: Theme.of(context).accentColor,
        insetPadding: EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      elevation: 1,
                      color: Colors.white,
                      shape: CircleBorder(),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black12,
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    clipBehavior: Clip.antiAlias,
                    width: MediaQuery.of(context).size.width - 32 - 16,
                    height: MediaQuery.of(context).size.width - 32 - 16,
                    child: data.imgpath != null ? Image.network("${httpClass.API_IP}${data.imgpath}") : Icon(Icons.broken_image, color: Colors.white),
                  ),
                  if(data.description != null)
                    SizedBox(height: 8.0),
                  if(data.description != null)
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      width: MediaQuery.of(context).size.width - 32 - 16,
                      child: Text(
                        data.description
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void unPopDialog(BuildContext context, String title, Widget content, List<Widget> actions){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child:AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          title: Text(title),
          content: content,
          actions: actions,
        ),
      );
    },
  );
}


void loadingDialog(BuildContext context,String text) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.0),
              Text(text),
            ],
          ),
        ),
      ),
      );
    },
  );
}

void swipeUpDialog(BuildContext context, Widget route){
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        DraggableScrollableSheet(
          initialChildSize: 0.36,
          minChildSize: 0.2,
          expand: false,
          builder: (context, scrollController) {
            return Card(
                margin: EdgeInsets.fromLTRB(0.0, MediaQuery.of(context).padding.top, 0.0, 0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.0),
                    )
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  ),
                  child: ListView(
                    controller: scrollController,
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 4,
                            margin: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(20.0)
                            ),
                          ),
                        ],
                      ),
                      route
                    ],
                  ),
                )
            );
          },
        ),
  );
}

Future<void> deleteDialog(BuildContext context, Function action) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
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
            onPressed: (){
              action();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}