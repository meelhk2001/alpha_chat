import 'package:alphachat/providers/contactprovider.dart';

import '../screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Profile.dart';
import 'badge.dart';
import 'package:provider/provider.dart';
import '../providers/homeprovider.dart';

class HomeList extends StatelessWidget {
  final AsyncSnapshot<dynamic> readSnapshot;
  final dynamic document;
  final FirebaseUser user;
  final DocumentSnapshot contactDocument;
  HomeList(this.readSnapshot, this.document, this.user, this.contactDocument);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  margin: EdgeInsets.only(top: 5),
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.width * 0.13,
                  child: Profile(document.documentID)),
              InkWell(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.78,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${contactDocument['nickname'] ?? contactDocument.documentID}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 21),
                      ),
                      Text(
                        '${document['aboutMe'] ?? 'Hey, I am Alphabics User'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  print(' chatting with ${document.documentID}');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                              document.documentID,
                              document['photoUrl'],
                              contactDocument['nickname'],
                              user.uid)));
                },
                onLongPress: () {
                  Provider.of<HomeProvider>(context, listen: false)
                      .copy(context, contactDocument.documentID.toString());
                  var nickname = TextEditingController();
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('Enter nickname'),
                            content: TextField(
                              controller: nickname,
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                onPressed: () async {
                                  Provider.of<ContactProvider>(context,listen: false)
                                      .addContact(
                                          nickname.text,
                                          contactDocument.documentID,
                                          user.uid,
                                          context);
                                },
                                child: Text('Okey'),
                              ),
                            ],
                          ));
                },
              ),
              if (readSnapshot.data.documents.length != 0)
                Badge(readSnapshot.data.documents.length),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
