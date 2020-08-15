import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullSceenImage extends StatelessWidget {
  final String imageUrl;
  FullSceenImage(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Details'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
              child: Container(
          width: MediaQuery.of(context).size.width,
          child: imageUrl==null ? 
        Image.asset('assets/profile.jpg')
         : CachedNetworkImage(imageUrl: imageUrl),),
      ),
    );
  }
}
