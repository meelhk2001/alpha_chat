import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../screens/Home_Screen.dart';
import 'package:sqflite/sqflite.dart' as sql;

class AuthProvider with ChangeNotifier {
  var loading = false;
  String otp;
  String dbPath;
  var isLoading = false;
  AuthCredential credential;
  String phoneNumber;
  FirebaseUser user;
  final String photoUrl =
      'https://4.bp.blogspot.com/-txKoWDBmvzY/XHAcBmIiZxI/AAAAAAAAC5o/wOkD9xoHn28Dl0EEslKhuI-OzP8_xvTUwCLcBGAs/s1600/2.jpg';
  SharedPreferences prefs;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FirebaseUser currentUser;
  FirebaseAuth _auth = FirebaseAuth.instance;

  //get current user function starts from here ................................
  Future<void> getCurrentUser(BuildContext context) async {
    try {
       dbPath = await sql.getDatabasesPath();
      isLoading = true;
      notifyListeners();
      user = await FirebaseAuth.instance.currentUser();
      if (user != null) {
        prefs = await SharedPreferences.getInstance();
        phoneNumber = prefs.getString('phonenumber');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(user,phoneNumber),
            ));
      } else {
        isLoading = false;
        notifyListeners();
        return;
      }
    } catch (error) {
      isLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  //From here send otp function starts..............................................
  Future<void> sendOtp(String phone, BuildContext context) async {
    phoneNumber = phone.replaceFirst('+91', '');
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: (AuthCredential authCredential) {
            otpVerify(authCredential, _auth, context);
            notifyListeners();
          },
          verificationFailed: null,
          codeSent: (String verificationId, [int forceResendingToken]) {
            loading = false;
            notifyListeners();
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                      title: Text("Enter SMS Code"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              otp = val;
                            },
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        loading
                            ? CircularProgressIndicator()
                            : FlatButton(
                                child: Text("Done"),
                                textColor: Colors.white,
                                color: Colors.teal,
                                onPressed: () async {
                                  loading = true;
                                  notifyListeners();
                                  FirebaseAuth auth = FirebaseAuth.instance;

                                  credential = PhoneAuthProvider.getCredential(
                                      verificationId: verificationId,
                                      smsCode: otp);
                                  otpVerify(credential, auth, context);
                                })
                      ],
                    ));
          },
          codeAutoRetrievalTimeout: null);
    } catch (error) {
      loading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  //From here otp verify function starts..............................................
  Future<void> otpVerify(AuthCredential credential, FirebaseAuth auth,
      BuildContext context) async {
    FirebaseUser firebaseUser =
        (await auth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        var token = await _firebaseMessaging
            .getToken(); ////////////////////////////////Notifications
        await Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname':phoneNumber,
          'photoUrl': null,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
          'contacts': null,
          'aboutMe': 'Hey, I am Alphabics user',
          'token': token
        });
        // Write data to local
        currentUser = firebaseUser;
        prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setString('phonenumber', phoneNumber);
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
        await prefs.setString('phoneNumber', phoneNumber);
      } else {
        // Write data to local
        var token = await _firebaseMessaging.getToken();
        await Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .updateData({'token': token});
        prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setString('phonenumber', phoneNumber);
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
        await prefs.setString('phoneNumber', phoneNumber);
      }
      Fluttertoast.showToast(msg: "Sign in success");

      loading = false;
      isLoading = false;
      notifyListeners();

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(firebaseUser,phoneNumber),
          )
          );
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");

      isLoading = false;
      loading = false;
      notifyListeners();
    }
  }
  void loadingTrue(){
    loading = true;
    notifyListeners();
  }
  String get phone {
    return phoneNumber;
  }
}
