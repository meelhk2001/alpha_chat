import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final int data;
  Badge(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.059,
      height: MediaQuery.of(context).size.width*0.059,
      child: CircleAvatar(
        backgroundColor: Colors.teal,
        child: Text(data.toString(), style: TextStyle(fontSize: 19, color: Colors.white), ),
      ),
    );
  }
}