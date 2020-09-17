import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'contact_us.dart';
import 'package:image_cropper/image_cropper.dart';

class EditYourself extends StatefulWidget {
  final String uid;

  EditYourself(this.uid);

  @override
  _EditYourselfState createState() => _EditYourselfState();
}

class _EditYourselfState extends State<EditYourself> {
  var aboutMe = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  File avatarImageFile;
  String phoneNumber;
  String photoUrl =
      'https://4.bp.blogspot.com/-txKoWDBmvzY/XHAcBmIiZxI/AAAAAAAAC5o/wOkD9xoHn28Dl0EEslKhuI-OzP8_xvTUwCLcBGAs/s1600/2.jpg';
  String realPhotoUrl;
  SharedPreferences prefs;
  @override
  void initState() {
    readLocal();
    super.initState();
  }

  Future<void> readLocal() async {
    realPhotoUrl = photoUrl;
    prefs = await SharedPreferences.getInstance();
    aboutMe.text = prefs.getString('aboutMe') ?? 'Hey, I am Alphabics User';
    phoneNumber = prefs.getString('phoneNumber') ?? 'Number not available';
    //realPhotoUrl = prefs.getString('photoUrl') ?? photoUrl;
    setState(() {
      realPhotoUrl = prefs.getString('photoUrl') ?? photoUrl;
    });
  }

  Future<void> done(String aboutMe) async {
    await Firestore.instance
        .collection('users')
        .document(widget.uid)
        .setData({'aboutMe': aboutMe}, merge: true);
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('aboutMe', aboutMe);
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File cropped = await ImageCropper.cropImage(sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 50,
      compressFormat: ImageCompressFormat.jpg,
      androidUiSettings: AndroidUiSettings(
        backgroundColor: Colors.teal,
        statusBarColor: Colors.teal,
        toolbarColor: Colors.teal,
        toolbarTitle: 'Edit Your Profile Picture'

      )

      );
      setState(() {
        avatarImageFile = cropped;
        isLoading = true;
      });
    }
    await uploadFile();
    setState(() {
      isLoading = false;
    });
  }

  Future uploadFile() async {
    String fileName = widget.uid;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          realPhotoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(widget.uid)
              .updateData({'photoUrl': realPhotoUrl}).then((data) async {
            await prefs.setString('photoUrl', realPhotoUrl);
            setState(() {
              isLoading = false;
            });
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('settings'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () {
                done(aboutMe.text);
                Navigator.of(context).pop();
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              //SizedBox(height: 40),
              Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width ,
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : CachedNetworkImage(imageUrl: realPhotoUrl,fit: BoxFit.cover,)
                          // Image.network(
                          //     realPhotoUrl,
                          //     fit: BoxFit.cover,
                          //   ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width ,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                            color: Colors.black54,
                            child: IconButton(
                             
                              icon: Icon(
                                Icons.mode_edit,
                                color: Colors.white,
                              ),
                              onPressed: 
                                getImage
                              
                            )),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'About me',
                style: TextStyle(
                    fontSize: 30, color: Colors.teal, letterSpacing: 1.0),
              ),
              //SizedBox(height: 40),
              
              SizedBox(
                height: 10,
              ),
              TextField(
                maxLength: 51,
                minLines: 2,
                maxLines: 10,
                cursorColor: Colors.teal,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: 'Type about yourself...',
                  hintStyle: TextStyle(color: Colors.teal),
                ),
                controller: aboutMe,
              ),
              Text(
                phoneNumber,
                
                style: TextStyle(
                    fontSize: 20, color: Colors.teal, letterSpacing: 1.0),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton.icon(
                      color: Colors.teal,
                      label: Text(
                        'Log out',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _auth.signOut();
                        //DBHelper.delete('all');
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ));
                      }),
                      FlatButton.icon(
                      color: Colors.teal,
                      label: Text(
                        'Contact Us',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                      onPressed: () {
                      
                  
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactUs(),
                            ));
                      }),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
