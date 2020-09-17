import 'package:alphachat/helpers/db_helper.dart';
import 'package:alphachat/helpers/message_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mymessage.dart';
import '../widgets/yourmessage.dart';

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
      String groupChatId, listMessage, scaffoldKey, BuildContext ctx) {
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
                        'read': '0',
                        'type': listMessage['type']
                      }).then((_) => Firestore.instance
                          .collection('messages')
                          .document(groupChatId)
                          .collection(groupChatId)
                          .where('timestamp',
                              isEqualTo: listMessage['timestamp'])
                          .where('idTo', isEqualTo: id)
                          .getDocuments()
                          .then((value) => value.documents[0].reference
                              .updateData({'read': 0})));
                    } else {
                      if (int.parse(messageSnapshot.data.documents[si]['read']
                              .toString()) ==
                          0) {
                        DocumentSnapshot listMessage =
                            messageSnapshot.data.documents[si];
                        try {
                          DBHelper.update(groupChatId.replaceAll('-', '_'), {
                            'id': listMessage['timestamp'],
                            // 'idFrom': listMessage['idFrom'],
                            // 'idTo': listMessage['idTo'],
                            // 'timestamp': listMessage['timestamp'],
                            'read': '0',
                            // 'type':listMessage['type']
                          }).then((_) => Firestore.instance
                              .collection('messages')
                              .document(groupChatId)
                              .collection(groupChatId)
                              .where('timestamp',
                                  isEqualTo: listMessage['timestamp'])
                              .getDocuments()
                              .then((value) =>
                                  value.documents[0].reference.delete()));
                        } catch (error) {
                          print(error.toString());
                        }
                      }
                    }
                  }
                }

                return StreamBuilder<List<Message>>(
                  stream:
                      DBHelper.getAllItems(groupChatId.replaceAll('-', '_')),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.teal)),
                      ));
                    } else {
                      snapshot.data.sort((a, b) => int.parse(a.timestamp)
                          .compareTo(int.parse(b.timestamp)));
                      // print(
                      //     'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
                      // print(snapshot.data.toString());
                      //listMessage = snapshot.data;
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) => buildChat(
                            index,
                            snapshot.data[snapshot.data.length - index - 1],
                            snapshot.data,
                            scaffoldKey,
                            context),
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

  Widget buildChat(int index, Message document, List<Message> listMessage,
      scaffoldKey, BuildContext context) {
    bool hyperlink = false;
    if (!document.content.contains(" ")) {
      links.forEach((element) {
        if (document.content.contains(element.toString())) {
          hyperlink = true;
        }
      });
    }

    if (document.idFrom == id) {
      // Right (my message)
      return MyMessage(
          read: !(document.read == '1'),
          hyperlink: hyperlink,
          groupChatId: groupChatId,
          document: document,
          id: id,
          index: listMessage.length - index - 1,
          listMessage: listMessage,
          scaffoldKey: scaffoldKey,
          cntx: context
          //key: scaffoldKey,
          );
      // return StreamBuilder<dynamic>(
      //     stream: Firestore.instance
      //         .collection('messages')
      //         .document(groupChatId)
      //         .collection(groupChatId)
      //         .where('timestamp', isEqualTo: document.timestamp)
      //         .snapshots(),
      //     builder: (context, readSnapshot) {
      //       if (readSnapshot.hasData && readSnapshot.data.documents.length !=0) {
      //         print(readSnapshot.data.documents[0]['read'].toString());
      //         return MyMessage(
      //           read: int.parse(readSnapshot.data.documents[0]['read'].toString()) == 0,
      //           hyperlink: hyperlink,
      //           groupChatId: groupChatId,
      //           document: document,
      //           id: id,
      //           index: index,
      //           listMessage: listMessage,
      //           scaffoldKey: scaffoldKey,
      //           //key: scaffoldKey,
      //         );
      //       } else {
      //         return MyMessage(
      //           read: !(document.read=='1'),
      //           hyperlink: hyperlink,
      //           groupChatId: groupChatId,
      //           document: document,
      //           id: id,
      //           index: index,
      //           listMessage: listMessage,
      //           scaffoldKey: scaffoldKey,
      //           //key: scaffoldKey,
      //         );
      //       }
      //     });
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
        groupChatId: groupChatId,
        ctx: context,
      );
    }
  }
}
