import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ImageView extends StatelessWidget {
  ImageView(this.url);
  final String url;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Stack(

        children: [
          Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),)),
         PhotoView(imageProvider: FileImage(File(url)))
        ],
      ),
    );
  }
}