import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_sharing/localization.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:travel_sharing/main.dart';

class LanguageSelect extends StatefulWidget {
  @override
  _LanguageSelectState createState() => _LanguageSelectState();
}

class _LanguageSelectState extends State<LanguageSelect> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 80),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  ListTile(
                    title: Text("English"),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await AppLocalizations.instance.load(Locale("en"));
                      await prefs.setString("lang", "en");
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text("ไทย"),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await AppLocalizations.instance.load(Locale("th"));
                      await prefs.setString("lang", "th");
                      Navigator.of(context).pop();
                    },
                  )
                ],
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
                        AppLocalizations.instance.text("Language"),
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
}
