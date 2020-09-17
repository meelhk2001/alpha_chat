import 'package:alphachat/helpers/message_modal.dart';
import 'package:alphachat/screens/full_screen.dart';
import 'package:alphachat/screens/photo_view.dart';
import 'package:alphachat/widgets/videoMessage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/db_helper.dart';
import 'dart:io';

class MyMessage extends StatelessWidget {
  MyMessage(
      {@required this.read,
      @required this.hyperlink,
      @required this.groupChatId,
      @required this.document,
      @required this.scaffoldKey,
      @required this.listMessage,
      @required this.id,
      @required this.index,
      @required this.cntx});

  final bool hyperlink;
  final String groupChatId;
  final Message document;
  final dynamic scaffoldKey;
  final dynamic listMessage;
  final String id;
  final int index;
  final bool read;
  final BuildContext cntx;

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (read && document.read == '1') {
    //   DBHelper.update(groupChatId.replaceAll('-', '_'), {
    //     'id': document.timestamp,
    //     'idFrom': document.idFrom,
    //     'idTo': document.idTo,
    //     'timestamp': document.timestamp,
    //     'content': document.content,
    //     'read': '0'
    //   }).then((value) => Firestore.instance
    //       .collection('messages')
    //       .document(groupChatId)
    //       .collection(groupChatId)
    //       .where('timestamp', isEqualTo: document.timestamp).where('read', isEqualTo: 0)
    //       .getDocuments()
    //       .then((value) => value.documents[0].reference.delete()));
    // }
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              bottom: isLastMessageRight(index) ? 20.0 : 3.0, right: 0.0),
          padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
          decoration: BoxDecoration(
              color: read ? Colors.teal : Colors.cyan[800],
              borderRadius: BorderRadius.circular(8.0)),
          // /;;;;';;
          child: ConstrainedBox(
            constraints: new BoxConstraints(
              //minHeight: 5.0,
              minWidth: 50.0,
              //maxHeight: 30.0,
              maxWidth: 300.0,
            ),
            child: InkWell(
              child: DecoratedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    document.type[0] != '0'
                        ? InkWell(
                            child: Container(
                              width: 250,
                              height: 250,
                              child: document.type[0] == '2'
                                  ? VideoMessage(document.content)
                                  : Image.file(
                                      File(document.content),
                                      fit: BoxFit.fill,
                                    ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => document.type[0] == '2'
                                          ? FullVideo(document.content)
                                          : ImageView(document.content)));
                            },
                          )
                        : InkWell(
                            child: Text(
                              document.content,
                              style: TextStyle(
                                  color: hyperlink
                                      ? Colors.blue[900]
                                      : Colors.white,
                                  fontSize: 18,
                                  decoration: hyperlink
                                      ? TextDecoration.underline
                                      : null,
                                  fontStyle:
                                      hyperlink ? FontStyle.italic : null),
                            ),
                            onTap: hyperlink
                                ? () async {
                                    String text = document.content.toString();

                                    //document['content'].toString().toLowerCase();
                                    text = text.replaceAll('https://', '');
                                    text = text.replaceAll('http://', "");
                                    text = text.replaceAll('https//', "");
                                    text = text.replaceAll('http//', "");
                                    //print('resume'.replaceAll('e', 'é'));

                                    var url =
                                        'https://$text'; //document['content'].toString();
                                    //await launch(url);

                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  }
                                : () {},
                          ),
                    SizedBox(height: 5),
                    Text(
                      DateFormat('ddMMMyy h:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document.timestamp))),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                    // color:
                    //     document.read == '1' ? Colors.cyan[800] : Colors.teal,
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onTap: document.type[0] == '1'
                  ? () {
                      // Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => ImageView(
                      //             document.content
                      //               )));
                    }
                  : null,
              onLongPress: () {
                scaffoldKey.currentState.showBottomSheet((context) => Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              icon: Icon(Icons.content_copy),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Clipboard.setData(ClipboardData(
                                  text: document.content,
                                ));

                                Fluttertoast.showToast(
                                    msg: 'Message Copied',
                                    backgroundColor: Colors.teal);
                              }),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                try {
                                  await Firestore.instance
                                      .collection('messages')
                                      .document(groupChatId)
                                      .collection(groupChatId)
                                      .document(document.timestamp)
                                      .delete();
                                  if (document.type[0] != '1') {
                                    FirebaseStorage.instance
                                        .ref()
                                        .child(groupChatId)
                                        .child(document.type)
                                        .child(document.timestamp)
                                        .delete();
                                  }
                                } catch (error) {
                                  print(error);
                                }
                                DBHelper.delete(
                                    groupChatId.replaceAll('-', '_'),
                                    document.id,
                                    cntx);
                              }),
                          IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
                      ),
                      color: Colors.teal,
                    ));
              },
            ),
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }
}
