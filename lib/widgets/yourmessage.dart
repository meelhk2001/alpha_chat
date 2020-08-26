import 'package:alphachat/helpers/message_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YourMessage extends StatelessWidget {
  const YourMessage(
      {@required this.hyperlink,
      @required this.document,
      @required this.groupChatId});

  final bool hyperlink;
  final Message document;
  final String groupChatId;

  @override
  Widget build(BuildContext context) {
    // try {
    //   Firestore.instance
    //       .collection('messages')
    //       .document(groupChatId)
    //       .collection(groupChatId)
    //       .where('timestamp', isEqualTo: document.timestamp)
    //       .getDocuments()
    //       .then(
    //           (value) => value.documents[0].reference.updateData({'read': 0}));
    // } catch (error) {
    //   print(error.toString());
    // }
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InkWell(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 300,
                      minWidth: 50,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          //color: Colors.white70,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            child: Text(
                              document
                                  .content, ///////////////////////////////////////////////////////////////////////////
                              style: TextStyle(
                                  color: hyperlink
                                      ? Colors.blue[900]
                                      : Colors.teal,
                                  fontSize: 18,
                                  decoration: hyperlink
                                      ? TextDecoration.underline
                                      : null,
                                  fontStyle:
                                      hyperlink ? FontStyle.italic : null),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            DateFormat('ddMMMyy h:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(document.timestamp))),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 10.0,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
                  //width: 200.0,

                  // margin: EdgeInsets.only(left: 0.0),
                ),
                onLongPress: () {
                  Clipboard.setData(ClipboardData(
                    text: document.content,
                  ));
                  Fluttertoast.showToast(
                      msg: 'Message Copied', backgroundColor: Colors.teal);
                },
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
              )
            ],
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      margin: EdgeInsets.only(bottom: 3.0),
    );
  }
}
