import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.vertical,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: SafeArea(
        bottom: false,
        child: Card(
          elevation: 2,
          margin: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            )
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(20.0)
                ),
              )
            ],
          ),
        )
      )
    );
  }
}
