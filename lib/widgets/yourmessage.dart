import 'package:alphachat/helpers/message_modal.dart';
import 'package:alphachat/widgets/image_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class YourMessage extends StatelessWidget {
  const YourMessage(
      {@required this.hyperlink,
      @required this.document,
      @required this.groupChatId,
      @required this.ctx});

  final bool hyperlink;
  final Message document;
  final String groupChatId;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    print(document.content);
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
              Container(
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
                        document.type != '0'
                            ? ImageMessage(ctx, groupChatId, document)
                            : InkWell(
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
                                onTap: hyperlink
                                    ? () async {
                                        String text =
                                            document.content.toString();
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
