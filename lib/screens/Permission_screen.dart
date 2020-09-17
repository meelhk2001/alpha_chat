import 'package:flutter/material.dart';

class PermissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
              'Please Provide Camera, Storage & Contact Permissions then Restart The App',
              style: TextStyle(fontSize: 30, color: Colors.teal),
              overflow: TextOverflow.visible,
              )
              ),
    );
  }
}
