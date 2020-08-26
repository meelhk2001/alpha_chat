import 'package:alphachat/screens/Contacts.dart';

import 'Home_Screen.dart';
import 'add_contacts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/Profile.dart';
import 'edit_yourself.dart';
import 'package:provider/provider.dart';
import '../providers/homeprovider.dart';

class TabsScreen extends StatefulWidget {
  final FirebaseUser user;
  final String phoneNumber;
  TabsScreen(this.user, this.phoneNumber);
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Provider.of<HomeProvider>(context, listen: false).onExitPress(context);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leadingWidth: 68,
            leading: Profile(widget.user.uid),
            centerTitle: true,
            title: Text('Alphabics'),
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.settings,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditYourself(widget.user.uid)));
                  }),
            ],
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.chat_sharp,
                  ),
                  text: 'Chats',
                ),
                Tab(
                  icon: Icon(
                    Icons.contacts_sharp,
                  ),
                  text: 'Contacts',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Home(widget.user, widget.phoneNumber),
              Contacts(widget.user)
            ],
          ),
        ),
      ),
    );
  }
}
