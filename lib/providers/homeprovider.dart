import 'package:alphachat/screens/full_screen_image.dart';
import 'package:alphachat/widgets/home_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeProvider with ChangeNotifier {
  Future<bool> onExitPress(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () =>
                    SystemNavigator.pop(), //Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  showProfile(BuildContext context, String photoUrl) {
    showDialog(
        context: context,
        builder: (context) => GestureDetector(
              child: AlertDialog(
                titlePadding: EdgeInsets.all(0),
                contentPadding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                content: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: photoUrl == null
                        ? Image.asset('assets/profile.jpg')
                        : CachedNetworkImage(imageUrl: photoUrl)),
              ),
              onTap: () {
                Navigator.pop(context);
                if(photoUrl != null){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullSceenImage(photoUrl),
                    ));
                }
              },
            ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot contactDocument,
      int index, FirebaseUser user) {
    String groupChatId;
    if (contactDocument['id'] == user.uid) {
      return Container();
    } else {
      return StreamBuilder<dynamic>(
          stream: Firestore.instance
              .collection('users')
              .document(contactDocument['id'])
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData) {
              var document = snapshots.data;
              if (user.uid.hashCode <= document.documentID.hashCode) {
                groupChatId = '${user.uid}-${document.documentID}';
              } else {
                groupChatId = '${document.documentID}-${user.uid}';
              }
              return StreamBuilder<dynamic>(
                  stream: Firestore.instance
                      .collection('messages')
                      .document(groupChatId)
                      .collection(groupChatId)
                      .where('read', isEqualTo: 1)
                      .where('idFrom', isEqualTo: '${document.documentID}')
                      .snapshots(),
                  builder: (context, readSnapshot) {
                    if (readSnapshot.hasData) {
                      return HomeList(
                          readSnapshot, document, user, contactDocument);
                    } else {
                      return Container();
                    }
                  });
            } else {
              return Container(
                child: Text('Add Contacts'),
              );
            }
          });
    }
  }

  void copy(BuildContext context, String content) {
    Fluttertoast.showToast(
      msg: 'Contect Details Copied',
      backgroundColor: Colors.teal,
    );
    Clipboard.setData(ClipboardData(text: content));
  }
}
