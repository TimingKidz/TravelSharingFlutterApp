import 'package:flutter/material.dart';

void normalDialog(BuildContext context, String title, Widget content, List<Widget> actions){
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

void swipeUpDialog(BuildContext context, Widget route){
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        DraggableScrollableSheet(
          initialChildSize: 0.33,
          minChildSize: 0.2,
          maxChildSize: 1,
          expand: false,
          builder: (context, scrollController) {
            return Card(
                margin: EdgeInsets.fromLTRB(0.0, 46.0, 0.0, 0.0),
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