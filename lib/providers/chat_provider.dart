import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mymessage.dart';
import '../widgets/yourmessage.dart';

class ChatProvider with ChangeNotifier {
  SharedPreferences prefs;
  String phoneNumber;
  String id;
  String groupChatId;
  List<dynamic> links;

  void readLocal(String docId) async {
    prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber');
    id = prefs.getString('id') ?? '';
    print('id ========================= '+ id.toString());
    print('docid ===================== '+ docId);
    if (id.hashCode <= docId.hashCode) {
      groupChatId = '$id-$docId';
    } else {
      groupChatId = '$docId-$id';
    }

    await Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': docId});
    var docs = await Firestore.instance.collection('links').document('links').get() ;
     links = docs.data['linkText'];
        
    notifyListeners();
  }

  Future<void>  list() async {
    
     //var document = 
     var docs = await Firestore.instance.collection('links').document('links').get() ;
     links = docs.data['linkText'];

  }

  Widget buildListMessage(String groupChatId, listMessage, scaffoldKey) {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(101)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.teal)));
                } else {
                  
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildChat(
                        index,
                        snapshot.data.documents[index],
                        index,
                        
                        listMessage,
                        scaffoldKey),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    //controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  Widget buildChat(
      int index, DocumentSnapshot document, int i, listMessage, scaffoldKey) {
    bool hyperlink = false;
    if (!document['content'].toString().contains(" ")) {
      links.forEach((element) {
        if (document['content'].toString().contains(element.toString())) {
          hyperlink = true;
        }
      });
    }

    if (document['idFrom'] == id) {
      // Right (my message)
      return MyMessage(
        hyperlink: hyperlink,
        groupChatId: groupChatId,
        document: document,
        id: id,
        index: index,
        listMessage: listMessage,
        scaffoldKey: scaffoldKey,
        //key: scaffoldKey,
      );
    } else {
     
      Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(document.documentID)
          .setData({'read': 0}, merge: true);

      return YourMessage(hyperlink: hyperlink, document: document,);
    }
  }
}