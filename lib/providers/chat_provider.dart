import 'package:alphachat/helpers/db_helper.dart';
import 'package:alphachat/helpers/message_modal.dart';
import 'package:sqlbrite/sqlbrite.dart';
import '../screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/authprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../widgets/mymessage.dart';
import '../widgets/yourmessage.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class ChatProvider with ChangeNotifier {
  SharedPreferences prefs;
  String phoneNumber;
  String id;
  String groupChatId;
  List<dynamic> links;

  void readLocal(String docId) async {
    prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber');
    id = prefs.getString('id') ?? '';
    print('id ========================= ' + id.toString());
    print('docid ===================== ' + docId);
    if (id.hashCode <= docId.hashCode) {
      groupChatId = '$id-$docId';
    } else {
      groupChatId = '$docId-$id';
    }

    await Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': docId});
    var docs =
        await Firestore.instance.collection('links').document('links').get();
    links = docs.data['linkText'];

    notifyListeners();
  }

  Future<void> list() async {
    // sql.getDatabasesPath()
    //var document =
    var docs =
        await Firestore.instance.collection('links').document('links').get();
    links = docs.data['linkText'];
  }

  Widget buildListMessage(
      String groupChatId, listMessage, scaffoldKey, BuildContext context) {
    // print('databaseeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
    // print(sql.openReadOnlyDatabase(path.join(Provider.of<AuthProvider>(context, listen: false).dbPath, 'messages.db')).toString());
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)))
          : StreamBuilder<dynamic>(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(101)
                  .snapshots(),
              builder: (context, messageSnapshot) {
                if (messageSnapshot.hasData &&
                    messageSnapshot.data.documents.length != 0) {
                  for (int si = 0;
                      si < messageSnapshot.data.documents.length;
                      si++) {
                    if (messageSnapshot.data.documents[si]['idTo'] == id) {
                      DocumentSnapshot listMessage =
                          messageSnapshot.data.documents[si];
                      DBHelper.insert(groupChatId.replaceAll('-', '_'), {
                        'id': listMessage['timestamp'],
                        'idFrom': listMessage['idFrom'],
                        'idTo': listMessage['idTo'],
                        'timestamp': listMessage['timestamp'],
                        'content': listMessage['content'],
                        'read': '0'
                      });
                      Firestore.instance
                          .collection('messages')
                          .document(groupChatId)
                          .collection(groupChatId)
                          .where('timestamp',
                              isEqualTo: listMessage['timestamp'])
                          .where('idTo', isEqualTo: id)
                          .getDocuments()
                          .then((value) => value.documents[0].reference
                              .updateData({'read': 0}));
                    } else {
                      if (int.parse(messageSnapshot.data.documents[si]['read']
                              .toString()) ==
                          0) {
                        DocumentSnapshot listMessage =
                            messageSnapshot.data.documents[si];
                        // try {
                        //   DBHelper.update(groupChatId.replaceAll('-', '_'), {
                        //     'id': listMessage['timestamp'],
                        //     'idFrom': listMessage['idFrom'],
                        //     'idTo': listMessage['idTo'],
                        //     'timestamp': listMessage['timestamp'],
                        //     'content': listMessage['content'],
                        //     'read': '0'
                        //   }).then((value) => Firestore.instance
                        //       .collection('messages')
                        //       .document(groupChatId)
                        //       .collection(groupChatId)
                        //       .where('timestamp',
                        //           isEqualTo: listMessage['timestamp'])
                        //       .where('idTo', isEqualTo: id)
                        //       .getDocuments()
                        //       .then((value) =>
                        //           value.documents[0].reference.delete()));
                        // } catch (error) {
                        //   throw error;
                        // }
                      }
                    }
                  }
                }
                return StreamBuilder<List<Message>>(
                  stream:
                      DBHelper.getAllItems(groupChatId.replaceAll('-', '_')),
                  // future.data
                  //     .query(groupChatId.replaceAll('-', '_'))
                  //     .asStream(),
                  //  Firestore.instance
                  //     .collection('messages')
                  //     .document(groupChatId)
                  //     .collection(groupChatId)
                  //     .orderBy('timestamp', descending: true)
                  //     .limit(101)
                  //     .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.teal)),
                      ));
                    } else {
                      print(
                          'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
                      print(snapshot.data.toString());
                      listMessage = snapshot.data;
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) => buildChat(
                            index,
                            snapshot.data[snapshot.data.length - index - 1],
                            index,
                            listMessage,
                            scaffoldKey),
                        itemCount: snapshot.data.length,
                        reverse: true,
                        //controller: listScrollController,
                      );
                    }
                  },
                );
              }),
    );
  }

  Widget buildChat(
      int index, Message document, int i, listMessage, scaffoldKey) {
    bool hyperlink = false;
    // if (!document['content'].toString().contains(" ")) {
    //   links.forEach((element) {
    //     if (document['content'].toString().contains(element.toString())) {
    //       hyperlink = true;
    //     }
    //   });
    // }

    if (document.idFrom == id) {
      // Right (my message)
      return MyMessage(
        hyperlink: hyperlink,
        groupChatId: groupChatId,
        document: document,
        id: id,
        index: index,
        listMessage: listMessage,
        scaffoldKey: scaffoldKey,
        //key: scaffoldKey,
      );
    } else {
      // Firestore.instance
      //     .collection('messages')
      //     .document(groupChatId)
      //     .collection(groupChatId)
      //     .document(document.documentID)
      //     .setData({'read': 0}, merge: true);

      return YourMessage(
        hyperlink: hyperlink,
        document: document,
      );
    }
  }
}
