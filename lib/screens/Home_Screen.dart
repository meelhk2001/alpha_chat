import 'edit_yourself.dart';
import '../helpers/db_helper.dart';
import 'add_contacts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/homeprovider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/Profile.dart';
import 'package:sqflite/sqflite.dart' as sql;

class Home extends StatelessWidget {
  final FirebaseUser user;
  final String phoneNumber;
  Home(this.user, this.phoneNumber);
  String photoUrl;

  @override
  Widget build(BuildContext context) {
    //DBHelper.delete('messages');
    return 
      
      Container(
        child: StreamBuilder<dynamic>(
          stream: Firestore.instance
              .collection('users')
              .document(user.uid)
              .collection(
                'contacts'
              )
               .orderBy('order', descending: true)
              .snapshots(),
          builder: (context, contactSnapshot) {
            if (!contactSnapshot.hasData) {
              
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              );
            } else {
              return ListView.builder(
                //padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) =>
                    Provider.of<HomeProvider>(context).buildItem(context,
                        contactSnapshot.data.documents[index], index, user),
                itemCount: contactSnapshot.data.documents.length,
              );
            }
          },
        ),
      );
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () {
      //       Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => AddContacts(user),
      //           ));
      //     },
      //     child: Icon(Icons.add_call)),
    
  }
}
