
import 'dart:io';
import 'package:alphachat/helpers/db_helper.dart';
import 'package:alphachat/screens/chat_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import 'package:image/image.dart' as img;
import '../providers/chat_provider.dart';

class InputAndNotificationProvider with ChangeNotifier {
  bool state = false;
  void changeState(bool boolState) {
    state = boolState;

    notifyListeners();
  }

  void onSendMessage(
      String content,
      String id,
      String docId,
      BuildContext context,
      String groupChatId,
      String stamp,
      String nickname,
      String type) {
    var phoneNumber =
        Provider.of<ChatProvider>(context, listen: false).phoneNumber;
        
    HapticFeedback.lightImpact();
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      sendNotification('New Message', context, docId);
      HapticFeedback.vibrate();
      // textEditingController.clear();
      if (type[0] != '1' && type[0] !='2') {
        // DBHelper.insert(groupChatId.replaceAll('-', '_'), {
        //   'id': stamp,
        //   'idFrom': id,
        //   'idTo': docId,
        //   'timestamp': stamp,
        //   'content': content,
        //   'read': '1',
        //   'type': type
        // });
      }
      // Chat.of(context).setState(() {

      // });
      notifyListeners();
      print(
          'local v v v local v local local local local local local local locallocalyyyyyyyyyyyyyyYYYYYYYY');
      print(DateTime.now().toIso8601String().toString());
      // DocumentReference documentReference = Firestore.instance
      //     .collection('messages')
      //     .document(groupChatId)
      //     .collection(groupChatId)
      //     .document(stamp);

      // Firestore.instance.runTransaction((transaction) async {
      //   try {
      //     var result = await Firestore.instance
      //         .collection('users')
      //         .where('id', isEqualTo: docId)
      //         .getDocuments();

      //     String contactNumber = result.documents[0]['nickname'];
      //     await Firestore.instance
      //         .collection('users')
      //         .document(id)
      //         .collection('contacts')
      //         .document(contactNumber)
      //         .setData({
      //       'nickname': nickname,
      //       'id': result.documents[0].documentID,
      //       'order': DateTime.now().millisecondsSinceEpoch.toString()
      //     }, merge: true);
      //     await Firestore.instance
      //         .collection('users')
      //         .document(docId)
      //         .collection('contacts')
      //         .document(phoneNumber)
      //         .updateData(
      //       {
      //         'id': id,
      //         'photoUrl': null,
      //         'createdAt': null,
      //         'chattingWith': null,
      //         'order': DateTime.now().millisecondsSinceEpoch.toString(),
      //       },
      //     );
      //     // sendNotification('New Message');
      //   } catch (error) {
      //     print(phoneNumber.toString());
      //     await Firestore.instance
      //         .collection('users')
      //         .document(docId)
      //         .collection('contacts')
      //         .document(phoneNumber)
      //         .setData({
      //       'id': id,
      //       'nickname': phoneNumber,
      //       'photoUrl': null,
      //       'createdAt': null,
      //       'chattingWith': null,
      //       'order': DateTime.now().millisecondsSinceEpoch.toString(),
      //     }, merge: true);
      //     // sendNotification('New Message');

      //   }
      // });

      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      return;
      //Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Future getImageMessage(String groupChatId, String type, BuildContext context,
      String id, String docId, String nickname) async {
    String stamp = DateTime.now().millisecondsSinceEpoch.toString();
    File image = type[0] == '2'
        ? await ImagePicker.pickVideo(source: ImageSource.gallery)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    File cropped, send;
    var extDir = await Directory('/storage/emulated/0/Alphabics/media').create(recursive: true);
    //await getExternalStorageDirectory();
    String ext = type == '1' ? '.jpg' : '.mp4';
    if (image != null && type[0] != '2') {
      cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          //aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 10,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              backgroundColor: Colors.teal,
              statusBarColor: Colors.teal,
              toolbarColor: Colors.teal,
              toolbarTitle: 'send to $nickname'));
      img.Image gambard = img.decodeImage(cropped.readAsBytesSync());
      // img.Image gambarKecilx = img.copyResize(gambard);
      send = File("${extDir.path}/$stamp$ext")
        ..writeAsBytesSync(img.encodeJpg(gambard, quality: 50));
    } else if (image != null && type[0] == '2') {
      var size = await image.length();
      if (size < 53000000) {
        send = await image.copy("${extDir.path}/$stamp$ext");
      } else {
        Fluttertoast.showToast(
            msg: 'Max Supperted Size is 50 MB', backgroundColor: Colors.teal);
      }
    }
    int size = await send.length();
    
    if (send != null && size < 53000000) {
      DBHelper.insert(groupChatId.replaceAll('-', '_'), {
        'id': stamp,
        'idFrom': id,
        'idTo': docId,
        'timestamp': stamp,
        'content': "${extDir.path}/$stamp$ext",
        'read': '1',
        'type': type+(size/1048576).toStringAsFixed(2)
      });
      Chat.of(context).setState(() {});
      notifyListeners();
      await uploadFile(
          send, stamp, groupChatId, type+(size/1048576).toStringAsFixed(2), context, id, docId, nickname);
          print(type+(size/1048576).toStringAsFixed(2)+" "+" sizeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeesssssssizzzzzzzzzzzee");
    }
  }

  Future uploadFile(File cropped, String stamp, String groupChatId, String type,
      BuildContext context, String id, String docId, String nickname) async {
        String ext = type == '1' ? '.jpg' : '.mp4';
    String fileName = stamp+ext ;
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child(groupChatId)
        .child(type)
        .child(fileName);
    // final _flutterVideoCompress = FlutterVideoCompress();
    // await _flutterVideoCompress.compressVideo(cropped.path,
    //     quality: VideoQuality.LowQuality,
    //     deleteOrigin: true
    //     );
    //     print('upload hone ja raha h bhai reeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' );
    //     print(cropped.length().toString());
    StorageUploadTask uploadTask = reference.putFile(cropped);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          try {
            DocumentReference documentReference = Firestore.instance
                .collection('messages')
                .document(groupChatId)
                .collection(groupChatId)
                .document(stamp);

            Firestore.instance.runTransaction((transaction) async {
              if (downloadUrl.trim() != '') {
                await transaction.set(
                  documentReference,
                  {
                    'idFrom': id,
                    'idTo': docId,
                    'timestamp': stamp,
                    'content': downloadUrl,
                    'read': 1,
                    'type': type
                  },
                );
              }
            });
          } catch (error) {
            print(error.toString());
          }
          onSendMessage(downloadUrl, id, docId, context, groupChatId, stamp,
              nickname, type);
        }, onError: (err) {
          //
        });
      } else {
        //
      }
    }, onError: (err) {
      //
    });
  }
  Future<void> sendNotification(String title, BuildContext context, String docId) async {
    
    String body;
    var prefs = Provider.of<ChatProvider>(context, listen: false).prefs;
    var _phone =  prefs.getString('phoneNumber');
    var result = await Firestore.instance
        .collection('users')
        .document(docId)
        .collection('contacts')
        .document(_phone)
        .get();
    body = result['nickname'];

    var token = await getToken(docId);
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
          'key=AAAA93DUjvs:APA91bG4nVOLqiyy0rKlHSYWTAp3Z72E33RgygD_UPEoPNw0c79uXpxWPGlOuZtHHl6Vrg6LwSTYgEePk4i7Z-mt8J1-uzJmOaKpaQczbCZ88tC90qSSJzzQGFvU5MWsw5lYMn-MpLGg'
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

  Future<String> getToken(String userId,) async {
    final Firestore _db = Firestore.instance;

   // print('ye h docId  =============          ${docId}');

    var token;
    //String fcmToken = await _fcm.getToken();
    var result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .getDocuments();
    token = result.documents[0]['token'];
    print('ye h token  =============          $token');
    return token;
  }
}
