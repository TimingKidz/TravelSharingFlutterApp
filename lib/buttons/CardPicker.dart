import 'package:flutter/material.dart';

class CardPicker extends StatefulWidget {
  final String labelText;
  final List<String> itemsList;
  final String initItem;
  final Function onChange;

  const CardPicker({Key key, @required this.labelText, @required this.itemsList, this.initItem, this.onChange}) : super(key: key);

  @override
  _CardPickerState createState() => _CardPickerState();
}

class _CardPickerState extends State<CardPicker> {
  String selectedItem;
  bool beforeEnable = true;
  bool nextEnable = true;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initItem ?? widget.itemsList.first;
    buttonEnableCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.labelText, style: TextStyle(color: Colors.black.withOpacity(0.6))),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: !beforeEnable ? null : () {
                      setState(() {
                        selectedItem = widget.itemsList[widget.itemsList.indexOf(selectedItem) - 1];
                        buttonEnableCheck();
                      });
                      widget.onChange(selectedItem);
                    },
                    child: Icon(Icons.navigate_before, color: beforeEnable ? Colors.black : Colors.black26),
                  ),
                  SizedBox(width: 16.0),
                  Text(
                    selectedItem,
                    style: Theme.of(context).textTheme.subtitle1
                  ),
                  SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: !nextEnable ? null : (){
                      setState(() {
                        selectedItem = widget.itemsList[widget.itemsList.indexOf(selectedItem) + 1];
                        buttonEnableCheck();
                      });
                      widget.onChange(selectedItem);
                    },
                    child: Icon(Icons.navigate_next, color: nextEnable ? Colors.black : Colors.black26),
                  )
                ],
              ),
            ],
          ),
        )
    );
  }

  void buttonEnableCheck(){
    if(selectedItem == widget.itemsList.first) beforeEnable = false;
    else if(selectedItem == widget.itemsList.last) nextEnable = false;
    else{
      beforeEnable = true;
      nextEnable = true;
    }
  }
}
