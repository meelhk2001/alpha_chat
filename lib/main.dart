import 'package:alphachat/providers/contactprovider.dart';

import 'providers/input_and_notificationprovider.dart';

import 'providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/login_screen.dart';
import 'providers/authprovider.dart';
import './providers/homeprovider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: AuthProvider()),
      ChangeNotifierProvider.value(value: HomeProvider()),
      ChangeNotifierProvider.value(value: ChatProvider()),
      ChangeNotifierProvider.value(value: InputAndNotificationProvider()),
      ChangeNotifierProvider.value(value: ContactProvider())
      ],
      child: MaterialApp(
        title: 'Alphabics',
        theme: ThemeData(
          primaryColor: Colors.teal,
          accentColor: Colors.teal,
        ),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
