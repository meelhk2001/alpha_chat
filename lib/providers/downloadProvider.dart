// import 'dart:io';

// import 'package:alphachat/helpers/db_helper.dart';
// import 'package:alphachat/helpers/message_modal.dart';
// import 'package:alphachat/screens/chat_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class DownloadProvider with ChangeNotifier {
//   // Future<bool> initialize(String link, String stamp) async {
//   //   // WidgetsFlutterBinding.ensureInitialized();
//   //   // await FlutterDownloader.initialize(
//   //   //     debug: true // optional: set false to disable printing logs to console
//   //   //     );
//   //   return download(link, stamp);
//   //}

//   Future<bool> download(String link, Message document, String groupChatId,
//       BuildContext ctx) async {
//     final extDir = await Directory('/storage/emulated/0/Alphabics/media').create(recursive: true);
//     try{
//       final taskId = await FlutterDownloader.enqueue(
//       url: link,
//       savedDir: extDir.path,
//       fileName: document.timestamp,
//       showNotification:
//           true, // show download progress in status bar (for Android)
//       openFileFromNotification:
//           true, // click on notification to open downloaded file (for Android)
//     );
//     // FirebaseStorage.instance.ref().child(groupChatId)
//     //     .child(document.type)
//     //     .child(document.timestamp).delete();
//     await DBHelper.insert(groupChatId.replaceAll('-', '_'), {
//       'id': document.timestamp,
//       'idFrom': document.idFrom,
//       'idTo': document.idTo,
//       'timestamp': document.timestamp,
//       'content': "${extDir.path}/${document.timestamp}",
//       'read': '0',
//       'type': document.type
//     });
//     //Chat.of(ctx).setState(() {});
//     }catch(error){
//       print(error.toString());
//     }
//     // var extDir = await getExternalStorageDirectory();
    
//     try {
//       Firestore.instance
//           .collection('messages')
//           .document(groupChatId)
//           .collection(groupChatId)
//           .document(document.timestamp)
//           .updateData({'content': "${extDir.path}/${document.timestamp}"});
//     } catch (error) {
//       print(error.toString());
//     }
    
//     return true;
//   }
// }
