import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatPage extends StatefulWidget {
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  // Chat messages List { "message": "**USER MESSAGE**", "isReceiver": true/false }
  // PAST -> PRESENT
  List<Map<String, dynamic>> messages = [{"message":"Hello.", "isReceiver":false}, {"message":"Hi.", "isReceiver":true}];
  List<Map<String, dynamic>> messagesReverseList;

  final textController = TextEditingController();
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    messagesReverseList = messages.reversed.toList();
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
      alignment: messagesReverseList[index]["isReceiver"] ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messagesReverseList[index]["message"],
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
                setState(() {
                  messages.add({"message":textController.text, "isReceiver":false});
                  messagesReverseList = messages.reversed.toList();
                  textController.clear();
                });
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