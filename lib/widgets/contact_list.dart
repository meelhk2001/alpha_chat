import 'package:alphachat/screens/chat_screen.dart';
import 'package:alphachat/widgets/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactList extends StatefulWidget {
  const ContactList({this.nickname, this.number, this.userUid});
  final String nickname;
  final String number;
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
      getDp(context);
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  Future getDp(BuildContext context) async {
    var result = await Firestore.instance
        .collection('users')
        .where('nickname', isEqualTo: widget.number.replaceFirst('+91', ''))
        .getDocuments();
    document = result.documents[0];
    uid = result.documents[0].documentID;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:Profile(uid),
      title: Text(widget.nickname),
      subtitle: Text(widget.number.replaceFirst('+91', '')),
      onTap: () {
        getDp(context).then((value) => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(document.documentID,
                    document['photoUrl'], widget.nickname, widget.userUid))));
      },
    );
  }
}
