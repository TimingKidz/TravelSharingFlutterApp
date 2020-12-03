import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:travel_sharing/Class/User.dart';
import 'package:travel_sharing/main.dart';
import 'package:http/http.dart' as Http;

class ChatPage extends StatefulWidget {
  final String tripid;
  User currentUser;

  ChatPage({this.tripid, this.currentUser});
  ChatPageState createState() => ChatPageState();
}

class Message{
  String sender;
  String content;
  String timestamp;


  Message({this.sender, this.content ,this.timestamp});

  Message.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    content = json['content'];
    timestamp = json['timestamp'];
  }

  Future< List<Message>> getMessage(String tripid) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/getMessage";
      Http.Response response = await Http.post(url, headers: HTTP().header, body: jsonEncode({"tripid":tripid }));
      if(response.statusCode == 400 ){
        return Future.value(null);
      }else{
        if(response.statusCode == 404){
          return Future.value(null);
        }else{
          print(jsonDecode(response.body));
          Map<String,dynamic> data = jsonDecode(response.body);
          print(data);
          List< Message > Message_List = List();
          data['messages'].forEach((x) {
            Message tmp = Message.fromJson(x);
            Message_List.add(tmp);
          });
          return Future.value(Message_List);
        }
      }
    }catch(error){
      print(error);
      throw("can't connect Match");
    }
  }

  Future<bool> sendMessage(String tripid,String message,String form_id, String name) async {
    try{
      var url = "${HTTP().API_IP}/api/routes/sendMessage";
      Map<String,dynamic> tmp = {
        "title": name,
        "message" : message,
        "formid" : form_id,
        "tripid" : tripid
      };
      Http.Response response = await Http.post(url, headers: HTTP().header, body: jsonEncode(tmp));
      if(response.statusCode == 400 ){
        return Future.value(false);
      }else{
        if(response.statusCode == 404){
          return Future.value(false);
        }else{
          print(jsonDecode(response.body));
          return Future.value(true);
        }
      }
    }catch(error){
      print(error);
      throw("can't send");
    }
  }


}

class ChatPageState extends State<ChatPage> with WidgetsBindingObserver  {
  // Chat messages List { "message": "**USER MESSAGE**", "isReceiver": true/false }
  // PAST -> PRESENT
  List<Message> messages = List() ;
  List<Message> messagesReverseList;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//  List<Message> Message_list;



  final textController = TextEditingController();
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    a();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        a();
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        print(message['notification']);
      },
      onLaunch: (Map<String, dynamic> message) async{
        print(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed){
      a();
    }
  }

  a()async{
    messages = await Message().getMessage(widget.tripid);
    print(messages.first);
    messagesReverseList = messages.reversed.toList();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TKZ"),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
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
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: messagesReverseList[index].sender != widget.currentUser.uid ? Alignment.centerLeft : Alignment.centerRight,
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
                Message().sendMessage(widget.tripid,textController.text, widget.currentUser.uid, widget.currentUser.name);
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