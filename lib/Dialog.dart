import 'package:flutter/material.dart';

void normalDialog(BuildContext context, String title, Widget content, List<Widget> actions){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: actions,
      );
    },
  );
}

void swipeDownDialog(BuildContext context, route){
  showGeneralDialog(
    barrierLabel: "Label",
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 200),
    context: context,
    pageBuilder: (context, anim1, anim2) {
      return route;
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
            .animate(anim1),
        child: child,
      );
    },
  );
}