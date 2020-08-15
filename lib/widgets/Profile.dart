import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/homeprovider.dart';


class Profile extends StatelessWidget {
  final String uid;
  Profile(
    this.uid,
  );

  String photoUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: GestureDetector(
                    child: StreamBuilder<dynamic>(
            stream: Firestore.instance
                .collection('users')
                .document(uid)
                .snapshots(),
            builder: (context, snapshotForPhotoUrl) {
              if (snapshotForPhotoUrl.hasData) {
                var document = snapshotForPhotoUrl.data;
                photoUrl = document['photoUrl'];
                return photoUrl == null
                    ? CircleAvatar(
                        backgroundImage: AssetImage('assets/profile.jpg'))
                    : CachedNetworkImage(
                        imageUrl: photoUrl,
                        imageBuilder: (context, imageProvider) =>
                            CircleAvatar(
                              backgroundImage: imageProvider,
                            ));
              } else {
                return CircularProgressIndicator();
              }
            }),
            onTap: (){Provider.of<HomeProvider>(context,listen: false).showProfile(context, photoUrl);}
      ),
    );
  }
}