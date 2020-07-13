import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final String title;

  const CustomAppbar({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> blur = [];
    double height = MediaQuery.of(context).size.height;
    debugPrint('$height');
    int startPoint = (28/32 * height).floor();
    debugPrint('$startPoint');

    double sigmaX = 0;
    double sigmaY = 0.1;
    for (int i = startPoint; i < startPoint + 300; i += 3) {
      blur.add(Positioned(
        top: 0,
        bottom: i.toDouble(),
        left: 0,
        right: 0,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: sigmaX,
              sigmaY: sigmaY,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ));
      sigmaX += 0.2;
      sigmaY += 0.2;
    }

    return Stack(
      children: <Widget>[
        Stack(
          alignment: Alignment.topCenter,
          children: blur,
        ),
        SafeArea(
          child: Container(
            padding: EdgeInsets.all(16.0),
            height: height - startPoint,
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                fontSize: 20.0
              )
            ),
          ),
        )
      ],
    );
  }

}