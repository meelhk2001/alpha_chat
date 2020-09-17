import 'package:alphachat/helpers/db_helper.dart';
import 'package:alphachat/helpers/message_modal.dart';
import 'package:alphachat/widgets/contact_list.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
  void initState() {
    checkContact();
    super.initState();
  }

  bool _isInit = true;
  List<Contact> _contactDocuments;
  bool contactPermission = false;
  Future checkContact() async {
    await Permission.contacts.request();
    contactPermission = await Permission.contacts.isGranted;
    setState(() {});
    if (contactPermission) {
      _contactDocuments =
          Provider.of<ContactProvider>(context, listen: false).accountContacts;
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<ContactProvider>(context, listen: false)
          .getContacts()
          .then((value) => setState(() {}))
          .then((value) => setState(() {}))
          .then((value) => Provider.of<ContactProvider>(context, listen: false)
              .getContacts()
              .then((value) => setState(() {})))
          .then((value) => _isInit = false)
          .then((value) => setState(() {}));
    }
    
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          if (_isInit)
            Column(
              children: [
                SizedBox(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                ),
                LinearProgressIndicator(
                  semanticsLabel: 'Please Wait..',
                ),
                SizedBox(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                ),
                LinearProgressIndicator(
                  semanticsLabel: 'Please Wait..',
                ),
                SizedBox(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                ),
                LinearProgressIndicator(
                  semanticsLabel: 'Please Wait..',
                ),
                SizedBox(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                ),
                LinearProgressIndicator(
                  semanticsLabel: 'Please Wait..',
                ),
              ],
            ),
          RefreshIndicator(
            onRefresh: () async {
              await Provider.of<ContactProvider>(context, listen: false)
                  .getContacts()
                  .then((value) => setState(() {}));
              setState(() {});
              await Provider.of<ContactProvider>(context, listen: false)
                  .getContacts()
                  .then((value) => setState(() {}));
              setState(() {});
              return;
            },
            child: StreamBuilder<List<Message>>(
                stream: DBHelper.getAllItems('contacts'),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    snapshot.data
                        .sort((a, b) => a.content.compareTo(b.content));
                    return ListView.builder(
                      itemBuilder: ((context, index) => ContactList(
                            contactUser: snapshot.data[index],
                            userUid: widget.user.uid,
                          )),
                      itemCount:
                          Provider.of<ContactProvider>(context, listen: false)
                              .accountContacts
                              .length,
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ),
        ],
      ),
    );
  }
}
