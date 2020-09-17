import 'package:alphachat/helpers/db_helper.dart';
import 'package:alphachat/providers/chat_provider.dart';
import 'package:alphachat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/input_and_notificationprovider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Input extends StatefulWidget {
  Input({
    @required this.textEditingController,
    @required this.typedMessage,
    // @required this.content,
    @required this.id,
    @required this.docId,
    @required this.phoneNumber,
    @required this.groupChatId,
    @required this.nickname,
  });

  TextEditingController textEditingController;
  String typedMessage, content, id, docId, phoneNumber, groupChatId, nickname;

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 50,
        maxHeight: 130,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 5, left: 5),
        child: Row(
          children: <Widget>[
            // Button send image

            // Edit text
            Flexible(
              child: Container(
                //height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal, width: 1.7),
                  color: Colors.white70,
                ),
                padding: EdgeInsets.only(left: 5, bottom: 10, top: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        // expands: true,

                        // minLines: null,
                        maxLines: null,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(51000),
                        ],

                        cursorColor: Colors.teal,
                        style: TextStyle(color: Colors.black, fontSize: 22.0),

                        controller: widget.textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.teal),
                        ),
                        onChanged: (val) {
                          widget.typedMessage = val;
                          if (val.trim().length == 1 ||
                              val.trim().length == 0) {
                            setState(() {});
                          }
                        },
                        // focusNode: focusNode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.textEditingController.text.trim().length == 0)
              IconButton(
                icon: Icon(
                  Icons.attach_file_rounded,
                ),
                color: Colors.teal,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (cntx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text('Choose Type'),
                            content: Container(
                              height: 100,
                              child: Center(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                            icon: Icon(Icons.image_outlined),
                                            iconSize: 30,
                                            onPressed: () {
                                              Navigator.of(cntx).pop();
                                              Provider.of<InputAndNotificationProvider>(
                                                      context,
                                                      listen: false)
                                                  .getImageMessage(
                                                      widget.groupChatId,
                                                      '1',
                                                      context,
                                                      widget.id,
                                                      widget.docId,
                                                      widget.nickname);
                                            }),
                                        IconButton(
                                            icon: Icon(
                                                Icons.video_library_outlined),
                                            iconSize: 30,
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Provider.of<InputAndNotificationProvider>(
                                                      context,
                                                      listen: false)
                                                  .getImageMessage(
                                                      widget.groupChatId,
                                                      '2',
                                                      context,
                                                      widget.id,
                                                      widget.docId,
                                                      widget.nickname);
                                            })
                                      ],
                                    ),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceEvenly,
                                    //   children: [
                                    //     IconButton(
                                    //         icon: Icon(Icons.image_outlined),
                                    //         // iconSize: 50,
                                    //         onPressed: () {}),
                                    //     IconButton(
                                    //         icon: Icon(Icons.image_outlined),
                                    //         onPressed: () {})
                                    //   ],
                                    // )
                                  ],
                                ),
                              ),
                            ),
                          ));
                  // Provider.of<InputAndNotificationProvider>(context,
                  //         listen: false)
                  //     .getImageMessage(widget.groupChatId, '1', context,
                  //         widget.id, widget.docId, widget.nickname);
                },
                padding: EdgeInsets.all(0),
                iconSize: 20,
              ),
            // Button send message
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Container(
                //color: Colors.tealAccent,
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    size: 40,
                  ),
                  onPressed: () {
                    String stamp =
                        DateTime.now().millisecondsSinceEpoch.toString();
                        DBHelper.insert(
                              widget.groupChatId.replaceAll('-', '_'), {
                            'id': stamp,
                            'idFrom': widget.id,
                            'idTo': widget.docId,
                            'timestamp': stamp,
                            'content': widget.typedMessage,
                            'read': '1',
                            'type': '0'
                          });
                    try {
                      DocumentReference documentReference = Firestore.instance
                          .collection('messages')
                          .document(widget.groupChatId)
                          .collection(widget.groupChatId)
                          .document(stamp);

                      Firestore.instance.runTransaction((transaction) async {
                        if (widget.textEditingController.text.trim() != '') {
                  
                          

                          transaction.set(
                            documentReference,
                            {
                              'idFrom': widget.id,
                              'idTo': widget.docId,
                              'timestamp': stamp,
                              'content': widget.textEditingController.text,
                              'read': 1,
                              'type': '0'
                            },
                          ).whenComplete(() {
                            widget.typedMessage =
                                widget.textEditingController.text;
                            widget.textEditingController.clear();
                            setState((){});
                              
                            
                          });
                        }
                      });
                    } catch (error) {
                      print(error.toString());
                      Chat.of(context).setState(() {});
                      widget.textEditingController.clear();
                    }
                    // DBHelper.insert(
                    //           widget.groupChatId.replaceAll('-', '_'), {
                    //         'id': stamp,
                    //         'idFrom': widget.id,
                    //         'idTo': widget.docId,
                    //         'timestamp': stamp,
                    //         'content': widget.typedMessage,
                    //         'read': '1',
                    //         'type': '0'
                    //       });
                    print(
                        'button dabaya HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH');
                    print(DateTime.now().toIso8601String().toString());
                    Provider.of<InputAndNotificationProvider>(context,
                            listen: false)
                        .onSendMessage(
                            widget.textEditingController.text,
                            widget.id,
                            widget.docId,
                            context,
                            widget.groupChatId,
                            stamp,
                            widget.nickname,
                            '0');
                  },
                  color: Colors.teal,
                ),
              ),
              //color: Colors.white,
            ),
          ],
        ),
        width: double.infinity,
        //height: 50.0,
        decoration: BoxDecoration(
          // border: Border(
          //     top: BorderSide(color: Colors.tealAccent[200], width: 0.5)),
          color: Color.fromRGBO(236, 229, 221, 1),
        ),
      ),
    );
  }
}
