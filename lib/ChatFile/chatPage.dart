import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:travel_sharing/Class/Message.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/custom_color_scheme.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final String tripid;
  final String currentTripid;
  final bool isHistory;
  ChatPage({this.tripid,this.currentTripid, this.isHistory});
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> with WidgetsBindingObserver  {
  List<Message> messages = List() ;
  List<Message> messagesReverseList = List();

  final textController = TextEditingController();
  ScrollController scrollController;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageConfig();
  }

  _pageConfig(){
    getData();
    socket.off('onNewNotification');
    socket.off('onNewMessage');

    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    socket.on('onNewMessage', (data) {
      if (data["tripid"] == widget.currentTripid){
        Message message = Message.fromJson(data["data"]);
        if(messagesReverseList.first.sender == message.sender) message.isDuplicate = true;
        else message.isDuplicate = false;
        messagesReverseList.insert(0, message);
        setState(() { });
      }
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print(messages);
          if( message['data']['tag'] != widget.tripid ){
            print("onMessage: $message");
            showNotification(message);
          }
        }
    );
  }

  @override
  void dispose() {
    socket.off('onNewMessage');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed){
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if(messagesReverseList.isNotEmpty)
                    Expanded(
                      child: _chatListView(),
                    ),
                  if(widget.isHistory == null ? true : !widget.isHistory)
                    _chatBottomBar(),
                  if(widget.isHistory == null ? false : widget.isHistory)
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8.0),
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.2),
                      child: Text("You can only view chat history"),
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
                        "Group Chat",
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
    return
      Scaffold(
          appBar: AppBar(
            title: Text("TKZ"),
            automaticallyImplyLeading: true,
          ),
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if(messagesReverseList.isNotEmpty)
              Expanded(
                child: _chatListView(),
              ),
              if(widget.isHistory == null ? true : !widget.isHistory)
              _chatBottomBar()
            ],
          )
        );
  }

  bool isSameTime;
  bool isBottom;

  Widget _chatListView() {
    return Container(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        reverse: true,
        controller: scrollController,
        itemCount: messagesReverseList.length,
        itemBuilder: (BuildContext context, int index) {
          if(index == 0){
            isSameTime = false;
            isBottom = true;
          }else{
            DateTime pastTime = DateTime.parse(messagesReverseList[index-1].timestamp);
            DateTime presentTime = DateTime.parse(messagesReverseList[index].timestamp);

            pastTime = DateTime(pastTime.year, pastTime.month, pastTime.day, pastTime.hour, pastTime.minute);
            presentTime = DateTime(presentTime.year, presentTime.month, presentTime.day, presentTime.hour, presentTime.minute);

            if(pastTime.compareTo(presentTime) == 0){
              isSameTime = true;
            }else{
              isSameTime = false;
            }
            isBottom = false;
          }
          return buildSingleMessage(messagesReverseList[index]);
        },
      ),
    );
  }

  getData() async {
    messages = widget.isHistory ? await Message().getHistoryMessage(widget.tripid) : await Message().getMessage(widget.tripid);
//    print(messages.first);
    messagesReverseList = messages.reversed.toList();
    setState((){});
  }

  List<TextSpan> telCheck(String content){
    List<TextSpan> span = List();
    List<String> allText = content.split(" ");
    final phonePattern = r'^(\d{10})$';
    final regEx = RegExp(phonePattern, multiLine: true);
    for(String text in allText){
      String obtainedPhone = regEx.stringMatch(text.toString());
      if(obtainedPhone == null){
        span.add(
          TextSpan(
            text: text,
            style: TextStyle(
              color: Colors.white
            ),
          )
        );
      }else{
        span.add(
          TextSpan(
            text: obtainedPhone,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final url = 'tel:$obtainedPhone';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
          )
        );
      }
      if(span.length != allText.length){
        span.add(
          TextSpan(text: " ")
        );
      }
    }
    return span;
  }

  Widget buildSingleMessage(Message message) {
    bool isSender = message.sender == currentUser.uid;
    if(isSender)
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: 8.0),
              if(!isSameTime)
                Text(
                  DateManage().datetimeFormat("time", message.timestamp),
                  style: TextStyle(
                      fontSize: 10.0
                  ),
                ),
              SizedBox(width: 4.0),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0, right: 10.0),
                  // margin: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                  decoration: BoxDecoration(
                    color: !isSender ? Colors.black : Colors.deepOrange,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: SelectableText.rich(
                    TextSpan(
                        children: telCheck(message.content)
                    ),
                  )
                ),
              ),
              SizedBox(width: 8.0),
            ],
          ),
          SizedBox(height: isBottom ? 8.0 : 4.0),
        ],
      );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 8.0),
            if(message.isDuplicate)
              SizedBox(width: 32.0),
            if(!message.isDuplicate)
              CircleAvatar(
                radius: 16,
                child: ClipOval(
                  child: message.imgpath != null ? Image.network("${httpClass.API_IP}${message.imgpath}") : Container(),
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(!message.isDuplicate)
                    SizedBox(height: 4.0),
                  if(!message.isDuplicate)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(message.name ?? "NO NAME", style: TextStyle(fontSize: 14.0)),
                      ),
                    ),
                  if(!message.isDuplicate)
                    SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0, right: 10.0),
                        // margin: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                        decoration: BoxDecoration(
                          color: !isSender ? Colors.black : Colors.deepOrange,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: SelectableText.rich(
                          TextSpan(
                            children: telCheck(message.content)
                          ),
                        )
                      ),
                      SizedBox(width: 4.0),
                      if(!isSameTime)
                        Text(
                          DateManage().datetimeFormat("time", message.timestamp),
                          style: TextStyle(
                              fontSize: 10.0
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(width: 4.0),
          ],
        ),
        SizedBox(height: isBottom ? 8.0 : 4.0),
      ],
    );
  }
  
  Widget _chatBottomBar() {
    return Material(
      child: Container(
        padding: EdgeInsets.only(left: 4.0, right: 12.0),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            // InkWell(
            //   child: Icon(Icons.image),
            //   onTap: () {
            //     debugPrint('Image');
            //   },
            // ),
            // SizedBox(width: 10.0),
            // InkWell(
            //   child: Icon(Icons.insert_emoticon),
            //   onTap: () {
            //     debugPrint('Sticker');
            //   },
            // ),
            Expanded(
                child: _chatTextField()
            ),
            InkWell(
              child: Icon(Icons.send),
              onTap: () {
                if(textController.text != ""){
                  debugPrint('Send');
                  Message().sendMessage(widget.tripid,textController.text, currentUser.uid, currentUser.name,widget.currentTripid, currentUser.imgpath);
                  textController.clear();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _chatTextField() {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.only(left: 12.0, right: 12.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Theme.of(context).canvasColor
      ),
      child: TextFormField(
        controller: textController,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: 'Type something...',
          border: InputBorder.none,
          errorStyle: TextStyle(height: 0),
        ),
      ),
    );
  }
}