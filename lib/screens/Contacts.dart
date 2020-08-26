import 'package:alphachat/providers/homeprovider.dart';
import 'package:alphachat/screens/add_contacts.dart';
import 'package:alphachat/widgets/contact_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contactprovider.dart';

class Contacts extends StatefulWidget {
  Contacts(this.user);
  final FirebaseUser user;

  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  @override
  Widget build(BuildContext context) {
    var _contactDocuments =
        Provider.of<ContactProvider>(context, listen: false).accountContacts;
    //print(Provider.of<ContactProvider>(context, listen: false).allContacts.first.phones.first.value);
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () {
      //       Provider.of<ContactProvider>(context, listen: false)
      //           .getContacts()
      //           .then((value) => setState(() {}));
      //       // Navigator.push(
      //       //     context,
      //       //     MaterialPageRoute(
      //       //       builder: (context) => AddContacts(user),
      //       //     ));
      //     },
      //     child: Icon(Icons.refresh)),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ContactProvider>(context, listen: false)
              .getContacts().then((value) => setState((){}));
          setState(() {});
          return;
        },
        child: ListView.builder(
          itemBuilder: ((context, index) => ContactList(
                number: _contactDocuments[index].phones.first.value,
                nickname: _contactDocuments[index].displayName,
                userUid: widget.user.uid,
              )),
          itemCount: Provider.of<ContactProvider>(context, listen: false)
              .accountContacts
              .length,
        ),
      ),
    );
  }
}
