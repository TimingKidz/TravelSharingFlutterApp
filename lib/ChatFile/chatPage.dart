import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:travel_sharing/Class/Message.dart';
import 'package:travel_sharing/main.dart';
import 'package:travel_sharing/Class/DateManage.dart';
import 'package:travel_sharing/custom_color_scheme.dart';

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
        messagesReverseList.insert(0, Message.fromJson(data["data"]));
        setState(() { });
      }
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if( message['notification']['tag'] != widget.tripid ){
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
                    _chatBottomBar()
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


  
  Widget _chatListView() {
    return Container(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        reverse: true,
        controller: scrollController,
        itemCount: messagesReverseList.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  getData() async {
    messages = await Message().getMessage(widget.tripid);
//    print(messages.first);
    messagesReverseList = messages.reversed.toList();
    setState((){});
  }

  Widget buildSingleMessage(int index) {
    // TODO: Add sender name and time stamp
    bool isSender = messagesReverseList[index].sender == currentUser.uid;
    return Column(
      children: [
        if(!isSender)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(messagesReverseList[index].name ?? "NO NAME"),
          ),
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: !isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if(isSender)
            Text(
              DateManage().datetimeFormat("time", messagesReverseList[index].timestamp),
              style: TextStyle(
                fontSize: 10.0
              ),
            ),
            if(!isSender)
              CircleAvatar(
                radius: 16,
                child: ClipOval(
                  child: Image.network(
                      "src"
                  ),
                ),
              ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                decoration: BoxDecoration(
                  color: !isSender ? Colors.black : Colors.deepOrange,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  messagesReverseList[index].content,
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
            ),
            if(!isSender)
              Text(
                DateManage().datetimeFormat("time", messagesReverseList[index].timestamp),
                style: TextStyle(
                    fontSize: 10.0
                ),
              ),
          ],
        )
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
                debugPrint('Send');
                Message().sendMessage(widget.tripid,textController.text, currentUser.uid, currentUser.name,widget.currentTripid, currentUser.imgpath);
                textController.clear();
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