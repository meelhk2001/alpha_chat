import 'package:alphachat/helpers/db_helper.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactProvider with ChangeNotifier {
  // Contact newContact = Contact(displayName: 'yey',phones: [Item(label: 'yey',value: '9549468990')]);

  List<Contact> allContacts;
  List<Contact> accountContacts = [];
  Future getContacts() async {
    var iterableContacts = await ContactsService.getContacts();
    allContacts = iterableContacts.toList();
    allContacts.forEach((element) => checkAccount(element));
    notifyListeners();
    // accountContacts.add(allContacts[allContacts.indexWhere((element) => checkAccount(element)==true)]);
  }

  Future checkAccount(Contact contact) async {
    for (int i = 0; i < contact.phones.length; i++) {
      QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('nickname',
              isEqualTo:
                  contact.phones.elementAt(i).value.replaceFirst('+91', ''))
          .getDocuments();
      if (result.documents.length != 0 && !accountContacts.contains(contact)) {
        accountContacts.removeWhere(
            (element) => element.displayName == contact.displayName);
            DBHelper.insert('contacts', {
              'id': contact.phones.elementAt(i).value.replaceFirst('+91', ''),
              'content':contact.displayName,
                            'idFrom': result.documents[0]['photoUrl'],
                            'idTo': result.documents[0].documentID,
                            'timestamp': 'nothing',
                            'read': '0',
                            'type':'0'
            });
        accountContacts.add(contact);
      }
    }
    notifyListeners();
  }

  Future addContact(
      String name, String number, String uid, BuildContext context) async {
    if (name != null) {
      await Firestore.instance
          .collection('users')
          .document(uid)
          .collection('contacts')
          .document(number)
          .updateData({
        'nickname': name,
      });
      Navigator.pop(context);
      //Navigator.of(context).pop();
      //textEditingController.clear();
      //nickname.clear();
      Iterable<Item> _item = [Item(label: 'Alphabics', value: number)];
      Contact newContact = Contact(givenName: name,
          displayName: name, phones: _item);
      ContactsService.addContact(newContact);
      notifyListeners();
    }
  }
}
