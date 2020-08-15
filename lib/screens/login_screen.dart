import '../providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'loading.dart';
import '../providers/authprovider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phoneNumber;
  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if(_isInit){
      Provider.of<ChatProvider>(context,listen: false).list();
      Provider.of<AuthProvider>(context).getCurrentUser(context);
      
    }
    _isInit = false;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Provider.of<AuthProvider>(context).isLoading
        ? Loading()
        : Scaffold(
            body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  color: Colors.teal,
                  child: Center(
                    child: Text(
                      'Alphabics',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 90,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    cursorColor: Colors.teal,
                    decoration: InputDecoration(
                        hintText: 'Enter your 10-digit number',
                        hintStyle: TextStyle(color: Colors.teal)),
                    style: TextStyle(
                        fontSize: 20, letterSpacing: 1, color: Colors.teal),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => phoneNumber = val,
                  ),
                ),
                SizedBox(height: 30),
                Provider.of<AuthProvider>(context).loading
                    ? CircularProgressIndicator()
                    : FlatButton(
                        color: Colors.teal,
                        child: Text(
                          'Request OTP',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            Provider.of<AuthProvider>(context, listen: false)
                                .loadingTrue();
                            //_Provider.of<AuthProvider>(context).isLoading = false;
                          });
                          setState(() {});
                          String phone = '+91$phoneNumber';
                          Provider.of<AuthProvider>(context, listen: false)
                              .sendOtp(phone, context);
                        },
                      )
              ],
            ),
          ));
  }
}
