import 'package:alphachat/helpers/message_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class MyMessage extends StatelessWidget {
  const MyMessage(
      {
      @required this.hyperlink,
      @required this.groupChatId,
      @required this.document,
      @required this.scaffoldKey,
      @required this.listMessage,
      @required this.id,
      @required this.index})
      ;

  final bool hyperlink;
  final String groupChatId;
  final Message document;
  final dynamic scaffoldKey;
  final dynamic listMessage;
  final String id;
  final int index;

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
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              bottom: isLastMessageRight(index) ? 20.0 : 3.0, right: 0.0),
          padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
          decoration: BoxDecoration(
              color: document.read == '1' ? Colors.cyan[800] : Colors.teal,
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
                    InkWell(
                      child: Text(
                        document.content,
                        style: TextStyle(
                            color: hyperlink ? Colors.blue[900] : Colors.white,
                            fontSize: 18,
                            decoration:
                                hyperlink ? TextDecoration.underline : null,
                            fontStyle: hyperlink ? FontStyle.italic : null),
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
                    color:
                        document.read == '1' ? Colors.cyan[800] : Colors.teal,
                    borderRadius: BorderRadius.circular(8.0)),
              ),
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

                                Fluttertoast.showToast(msg: 'Message Copied');
                              }),
                          // IconButton(
                          //     icon: Icon(Icons.delete),
                          //     onPressed: () async {
                          //       Navigator.of(context).pop();
                          //       await Firestore.instance
                          //           .collection('messages')
                          //           .document(groupChatId)
                          //           .collection(groupChatId)
                          //           .document(document.documentID)
                          //           .delete();
                          //     }),
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