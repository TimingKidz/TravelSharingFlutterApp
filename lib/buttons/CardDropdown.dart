import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardDropdown extends StatefulWidget {
  final String text;

  const CardDropdown({Key key, this.text}) : super(key: key);

  @override
  _CardDropdownState createState() => _CardDropdownState();
}

class _CardDropdownState extends State<CardDropdown> {
  GlobalKey actionKey;
  double height, width, xPosition, yPosition;
  bool isDropdownOpened = false;
  OverlayEntry floatingDropdown;
  String tt = "HH";

  @override
  void initState() {
    actionKey = LabeledGlobalKey(widget.text);
    super.initState();
  }

  void findDropdownData() {
    RenderBox renderBox = actionKey.currentContext.findRenderObject();
    height = renderBox.size.height;
    width = renderBox.size.width;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    xPosition = offset.dx;
    yPosition = offset.dy;
    print(height);
    print(width);
    print(xPosition);
    print(yPosition);
  }

  OverlayEntry _createFloatingDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: xPosition,
        width: width,
        top: yPosition + height,
        height: 4 * height + 40,
        child: DropDown(
          itemHeight: height,
        ),
      );
    });
  }

  void setData(String t){
    // setState(() {
    //   tt = "HELLO";
    // });
    tt = "HELLO";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: actionKey,
      onTap: () {
        setState(() {
          if (isDropdownOpened) {
            floatingDropdown.remove();
          } else {
            findDropdownData();
            floatingDropdown = _createFloatingDropdown();
            Overlay.of(context).insert(floatingDropdown);
          }
          isDropdownOpened = !isDropdownOpened;
        });
      },
      child: Material(
        elevation: 2,
        borderRadius: isDropdownOpened
            ? BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.zero,
        )
            : BorderRadius.circular(20),
        child: AnimatedContainer(
          decoration: BoxDecoration(
            borderRadius: isDropdownOpened
                ? BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.zero,
            )
                : BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          duration: Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          child: Row(
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.text.toUpperCase(), style: TextStyle(color: Colors.black.withOpacity(0.6))),
                      SizedBox(height: 8.0),
                      Text(tt)
                    ],
                  ),
                ],
              ),
              Spacer(),
              Icon(
                Icons.arrow_drop_down,
                // color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDown extends StatelessWidget {
  final double itemHeight;

  const DropDown({Key key, this.itemHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4 * itemHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          DropDownItem.first(
            text: "Add new",
            iconData: Icons.add_circle_outline,
            isSelected: true,
          ),
          DropDownItem(
            text: "View Profile",
            iconData: Icons.person_outline,
            isSelected: false,
          ),
          DropDownItem(
            text: "Settings",
            iconData: Icons.settings,
            isSelected: false,
          ),
          DropDownItem.last(
            text: "Logout",
            iconData: Icons.exit_to_app,
            isSelected: false,
          ),
        ],
      ),
    );
  }
}

class DropDownItem extends StatelessWidget {
  final String text;
  final IconData iconData;
  final bool isSelected;
  final bool isFirstItem;
  final bool isLastItem;

  const DropDownItem({Key key, this.text, this.iconData, this.isSelected = false, this.isFirstItem = false, this.isLastItem = false})
      : super(key: key);

  factory DropDownItem.first({String text, IconData iconData, bool isSelected}) {
    return DropDownItem(
      text: text,
      iconData: iconData,
      isSelected: isSelected,
      isFirstItem: true,
    );
  }

  factory DropDownItem.last({String text, IconData iconData, bool isSelected}) {
    return DropDownItem(
      text: text,
      iconData: iconData,
      isSelected: isSelected,
      isLastItem: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: isSelected ? Colors.grey.shade200 : Colors.white,
      borderRadius: BorderRadius.vertical(
        top: Radius.zero,
        bottom: isLastItem ? Radius.circular(20) : Radius.zero,
      ),
      child: InkWell(
        onTap: (){
          print(text);
          _CardDropdownState().setData(text);
        },
        child: Container(
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.vertical(
          //     top: Radius.zero,
          //     bottom: isLastItem ? Radius.circular(20) : Radius.zero,
          //   ),
          //   // color: isSelected ? Colors.white30 : Colors.white,
          // ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              Text(
                text.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Icon(
                iconData,
                // color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
