import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/input_and_notificationprovider.dart';

class Input extends StatelessWidget {
  Input(
      {@required this.textEditingController,
      @required this.typedMessage,
      // @required this.content,
      @required this.id,
      @required this.docId,
      @required this.phoneNumber,
      @required this.groupChatId});

  final TextEditingController textEditingController;
  String typedMessage, content, id, docId, phoneNumber, groupChatId;

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
                child: TextField(
                  // expands: true,

                  // minLines: null,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(51000),
                  ],

                  cursorColor: Colors.teal,
                  style: TextStyle(color: Colors.black, fontSize: 22.0),

                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.teal),
                  ),
                  onChanged: (val) {
                    typedMessage = val;
                  },
                  // focusNode: focusNode,
                ),
              ),
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
                    Provider.of<InputAndNotificationProvider>(context,listen: false)
                        .onSendMessage(
                      textEditingController.text,
                      id,
                      docId,
                      context,
                      groupChatId,
                    );
                    textEditingController.clear();
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
