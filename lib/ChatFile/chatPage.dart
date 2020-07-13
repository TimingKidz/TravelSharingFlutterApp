import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_sharing/customAppbar.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class ChatPage extends StatefulWidget {
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  SocketIO socketIO;
  List<String> messages;
  TextEditingController textController;
  ScrollController scrollController;

  @override
  void initState() {
    //Initializing the message list
    messages = List<String>();
    //Initializing the TextEditingController and ScrollController
    textController = TextEditingController();
    scrollController = ScrollController();
    //Creating the socket
    socketIO = SocketIOManager().createSocketIO(
      'http://10.0.2.2:3000/',
      '/',
    );
    //Call init before doing anything with socket
    socketIO.init();
    //Subscribe to an event to listen to
    socketIO.subscribe('receive_message', (jsonData) {
      //Convert the JSON data received into a Map
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data['message']));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
    //Connect to the socket
    socketIO.connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _chatListView(),
              _chatBottomBar()
            ],
          ),
          CustomAppbar(
            title: 'TimingKidz',
          ),
        ],
      ),
    );
  }
  
  Widget _chatListView() {
    return Container(
      child: ListView.builder(
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
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messages[index],
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }
  
  Widget _chatBottomBar() {
    return Material(
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        alignment: Alignment.center,
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
            InkWell(
              child: Icon(Icons.image),
              onTap: () {
                debugPrint('Image');
              },
            ),
            SizedBox(width: 10.0),
            InkWell(
              child: Icon(Icons.insert_emoticon),
              onTap: () {
                debugPrint('Sticker');
              },
            ),
            Expanded(
                child: _chatTextField()
            ),
            InkWell(
              child: Icon(Icons.send),
              onTap: () {
                debugPrint('Send');
                //Check if the textfield has text or not
                if (textController.text.isNotEmpty) {
                  //Send the message as JSON data to send_message event
                  socketIO.sendMessage(
                      'send_message', json.encode({'name': 'Time', 'message': textController.text}));
                  //Add the message to the list
                  this.setState(() => messages.add(textController.text));
                  textController.text = '';
                  //Scrolldown the list to show the latest message
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 600),
                    curve: Curves.ease,
                  );
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