import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:travel_sharing/Class/Message.dart';
import 'package:travel_sharing/main.dart';

class ChatPage extends StatefulWidget {
  final String tripid;
  ChatPage({this.tripid});
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
    socket.on('onNewNotification', (data) {
      currentUser.status.navbarNoti = true;
    });
    socket.on('onNewMessage', (data) {
      messagesReverseList.insert(0, Message.fromJson(data["messages"]));
      setState(() { });
    });
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if( message['data']['page'] != '/chatPage' ){
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
    print(messages.first);
    messagesReverseList = messages.reversed.toList();
    setState((){});
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: messagesReverseList[index].sender != currentUser.uid ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messagesReverseList[index].content,
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }
  
  Widget _chatBottomBar() {
    return Material(
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
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
                Message().sendMessage(widget.tripid,textController.text, currentUser.uid, currentUser.name);
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
          color: Colors.black12
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