import 'package:alphachat/helpers/message_modal.dart';
import 'package:alphachat/screens/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactList extends StatefulWidget {
  const ContactList({this.contactUser, this.userUid});
  final Message contactUser;
  final String userUid;

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  bool _isInit = true;
  String uid;
  DocumentSnapshot document;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      //getDp(context);
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  Future getDp(BuildContext context) async {
    var result = await Firestore.instance
        .collection('users')
        .where('nickname',
            isEqualTo: widget.contactUser.id.replaceFirst('+91', ''))
        .getDocuments();
    document = result.documents[0];
    uid = result.documents[0].documentID;
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundImage: widget.contactUser.idFrom == null
            ? AssetImage('assets/profile.jpg')
            : CachedNetworkImageProvider(widget.contactUser.idFrom),
      ),
      title: Text(widget.contactUser.content),
      subtitle: Text(widget.contactUser.id.replaceFirst('+91', '')),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                    widget.contactUser.idTo,
                    widget.contactUser.idFrom,
                    widget.contactUser.content,
                    widget.userUid)));
      },
    );
  }
}
