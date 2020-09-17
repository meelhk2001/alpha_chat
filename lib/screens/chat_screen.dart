import 'dart:io';
import 'package:alphachat/widgets/Profile.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../providers/chat_provider.dart';
import '../widgets/input.dart';
import 'user_details.dart';

class Chat extends StatefulWidget {
  static _ChatState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<_ChatState>());
  final String docId;
  final String imageUrl;
  final String name;
  final String id;
  Chat(this.docId, this.imageUrl, this.name, this.id);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String phoneNumber;

  String typedMessage;
  var listMessage;
  String groupChatId;
  var isInit = true;

  var textEditingController = TextEditingController();
  File imageFile;
  bool isLoading;
  List<String> linkText;

  //notification
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    //print('ab to reload huaa bhai ye 8888888888888888884444444444444444444444444445555555555555555555555555555555555555555555555555555');
    //Firestore.instance.collection('links').document('links').
    _fcm.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     content: ListTile(
        //       title: Text(message['notification']['title']),
        //       subtitle: Text(message['notification']['body']),
        //     ),
        //     actions: <Widget>[
        //       FlatButton(
        //         child: Text('Ok'),
        //         onPressed: () => Navigator.of(context).pop(),
        //       ),
        //     ],
        //   ),
        // );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        showDialog(context: context, builder: (context)=> AlertDialog(
          title: message['notification'],
        ));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );

    //StreamSubscription iosSubscription;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // if (Provider.of<InputAndNotificationProvider>(context).state) {
    //   setState(() {});
    //   Provider.of<InputAndNotificationProvider>(context, listen: false)
    //       .changeState(false);
    // }
    if (isInit) {
      groupChatId = '';
      Provider.of<ChatProvider>(context, listen: false).readLocal(widget.docId);

      isInit = false;
    }
    if (widget.id.hashCode <= widget.docId.hashCode) {
      groupChatId = '${widget.id}-${widget.docId}';
    } else {
      groupChatId = '${widget.docId}-${widget.id}';
    }
    super.didChangeDependencies();
  }

  // bool isLastMessageLeft(int index) {
  //   if ((index > 0 &&
  //           listMessage != null &&
  //           listMessage[index - 1]['idFrom'] == widget.id) ||
  //       index == 0) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // Widget buildInput() {
  //   return Input(
  //       textEditingController: textEditingController,
  //       typedMessage: typedMessage,
  //       id: widget.id,
  //       docId: widget.docId,
  //       phoneNumber: phoneNumber,
  //       groupChatId: groupChatId);
  //   // Input(
  //   //     textEditingController: textEditingController,
  //   //     typedMessage: typedMessage);
  // }

  @override
  Widget build(BuildContext context) {
   // DBHelper.delete('all');
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color.fromRGBO(236, 229, 221, 1),
      appBar: AppBar(
        //leading: null,
        elevation: 0,
        title: Row(
          children: <Widget>[
            Profile(widget.docId),
            SizedBox(
              width: 30,
            ),
            GestureDetector(
              child: Text(widget.name ?? 'Chat'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetails(
                        userId: widget.docId,
                        userName: widget.name,
                      ),
                    ));
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body:
      //  Provider.of<InputAndNotificationProvider>(context).state
      //     ? Center(child: CircularProgressIndicator())
      //     :
           Column(
              children: <Widget>[
                // List of messages
                Provider.of<ChatProvider>(context, listen: false)
                    .buildListMessage(groupChatId, listMessage, scaffoldKey, context),
                // Input content
                Input(
                    textEditingController: textEditingController,
                    typedMessage: typedMessage,
                    id: widget.id,
                    docId: widget.docId,
                    phoneNumber: phoneNumber,
                    groupChatId: groupChatId,
                    nickname: widget.name,),
              ],
            ),
    );
  }

///////////////
  ///Strating of notification code

  Future<void> sendNotification(String title) async {
    
    String body;
    var prefs = Provider.of<ChatProvider>(context, listen: false).prefs;
    var _phone =  prefs.getString('phoneNumber');
    var result = await Firestore.instance
        .collection('users')
        .document(widget.docId)
        .collection('contacts')
        .document(_phone)
        .get();
    body = result['nickname'];

    var token = await getToken(widget.docId);
    print('token : $token');

    final data = {
      "notification": {"body": 'From : $body', "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        'sound': 'default'
      },
      "to": "$token"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAXbEZttU:APA91bGoF3JppZ75pswhJETzJqHKiwRXOVg-3HWAS-BhqUsDoUeDYZU3My18Jbs9Uo-Xab9AeT4I8hwhLBBw3BxgibyLQLTMPOE3tjQRotISLhYkbU3NNQ7nzI7xGZfASzvza8I_DZUo'
    };

    BaseOptions options = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers,
    );

    try {
      final postUrl = 'https://fcm.googleapis.com/fcm/send';
      final response = await Dio(options).post(postUrl, data: data);

      // if (response.statusCode == 200) {
      //   Fluttertoast.showToast(msg: 'Request Sent To Driver');
      // } else {
      //   print('notification sending failed');
      //   // on failure do sth
      // }
    } catch (e) {
      print('exception $e');
    }
  }

  Future<String> getToken(userId) async {
    final Firestore _db = Firestore.instance;

    print('ye h docId  =============          ${widget.docId}');

    var token;
    //String fcmToken = await _fcm.getToken();
    var result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.docId)
        .getDocuments();
    token = result.documents[0]['token'];
    print('ye h token  =============          $token');
    return token;
  }

//////////////////
  ///Ending of Notification code

}
