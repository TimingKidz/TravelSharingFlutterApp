import 'package:flutter/material.dart';
import 'package:travel_sharing/Dialog.dart';

class CardPicker extends StatefulWidget {
  final String labelText;
  final List<String> itemsList;
  final String initItem;
  final Function onChange;
  final String tipsText;
  final String unit;

  const CardPicker({Key key, @required this.labelText, @required this.itemsList, this.initItem, this.onChange, this.tipsText, this.unit}) : super(key: key);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: Container(child: Text(widget.labelText, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black.withOpacity(0.6))))),
                  if(widget.tipsText != null)
                    GestureDetector(
                      onTap: () => tipsDialog(),
                      child: Icon(Icons.info, size: 18.0),
                    )
                ],
              ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: widget.unit != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: [
                  Row(
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
                      SizedBox(width: 12.0),
                      Text(
                        selectedItem,
                        style: Theme.of(context).textTheme.subtitle1
                      ),
                      SizedBox(width: 12.0),
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
                  if(widget.unit != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Text(widget.unit, style: TextStyle(color: Colors.black.withOpacity(0.6))),
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

  void tipsDialog(){
    normalDialog(
        context,
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(widget.labelText, style: Theme.of(context).textTheme.subtitle1),
                      ),
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: Material(
                          elevation: 2,
                          color: Colors.white,
                          shape: CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.clear),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                    child: Text(widget.tipsText),
                  )
                ],
              ),
            ),
          ],
        )
    );
  }
}
