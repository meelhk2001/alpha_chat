import 'dart:io';
import 'package:alphachat/helpers/db_helper.dart';
import 'package:alphachat/screens/chat_screen.dart';
import 'package:alphachat/widgets/Profile.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../providers/chat_provider.dart';
import '../widgets/input.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class InputAndNotificationProvider with ChangeNotifier {
  bool state = false;
  void changeState(bool boolState){
    state = boolState;
    
    notifyListeners();
  }
  void onSendMessage(
    String content,
    String id,
    String docId,
    BuildContext context,
    String groupChatId,
  ) {
    var stamp = DateTime.now().millisecondsSinceEpoch.toString();
    var phoneNumber =
        Provider.of<ChatProvider>(context, listen: false).phoneNumber;
    HapticFeedback.lightImpact();
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      HapticFeedback.vibrate();
      // textEditingController.clear();
      DBHelper.insert(groupChatId.replaceAll('-', '_'), {
        'id': stamp,
        'idFrom': id,
        'idTo': docId,
        'timestamp': stamp,
        'content': content,
        'read': '1'
      });
      // Chat.of(context).setState(() {
        
      // });
      notifyListeners();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(stamp);
/////////////////////////////////////////////////////////////////////////////
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': docId,
            'timestamp': stamp,
            'content': content,
            'read': 1
          },
        );
        try {
          QuerySnapshot result = await Firestore.instance
              .collection('users')
              .document(id)
              .collection('contacts')
              .where('id', isEqualTo: docId)
              .getDocuments();
          String contactNumber = result.documents[0].documentID;
          await Firestore.instance
              .collection('users')
              .document(id)
              .collection('contacts')
              .document(contactNumber)
              .setData(
                  {'order': DateTime.now().millisecondsSinceEpoch.toString()},
                  merge: true);
          await Firestore.instance
              .collection('users')
              .document(docId)
              .collection('contacts')
              .document(phoneNumber)
              .updateData(
            {
              'id': id,
              'photoUrl': null,
              'createdAt': null,
              'chattingWith': null,
              'order': DateTime.now().millisecondsSinceEpoch.toString(),
            },
          );
          // sendNotification('New Message');
        } catch (error) {
          print(phoneNumber.toString());
          await Firestore.instance
              .collection('users')
              .document(docId)
              .collection('contacts')
              .document(phoneNumber)
              .setData({
            'id': id,
            'nickname': phoneNumber,
            'photoUrl': null,
            'createdAt': null,
            'chattingWith': null,
            'order': DateTime.now().millisecondsSinceEpoch.toString(),
          }, merge: true);
          // sendNotification('New Message');
        }
      });

      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      return;
      //Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }
}
