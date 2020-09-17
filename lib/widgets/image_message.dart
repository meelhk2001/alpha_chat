import 'package:alphachat/helpers/db_helper.dart';
import 'package:alphachat/helpers/message_modal.dart';
import 'package:alphachat/screens/chat_screen.dart';
import 'package:alphachat/screens/full_screen.dart';
import 'package:alphachat/screens/photo_view.dart';
import 'package:alphachat/widgets/videoMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

class ImageMessage extends StatefulWidget {
  final BuildContext ctx;
  final String groupChatId;
  final Message document;
  // final BuildContext cntx;
  ImageMessage(
    this.ctx,
    this.groupChatId,
    this.document,
  );

  @override
  _ImageMessageState createState() => _ImageMessageState();
}

class _ImageMessageState extends State<ImageMessage> {
  @override
  void initState() {
    if (widget.document.content.contains('com.alpha.alphachat')) {
      setState(() {
        path = widget.document.content;
        complete = true;
      });
    } else {
      setState(() {
        complete = false;
      });
    }
    super.initState();
  }

  bool downloading = false;
  bool complete = false;
  double progress;
  String path;
  var dir;
  Future<void> downloadFile() async {
    String ext = widget.document.type[0] == '1' ? '.jpg' : '.mp4';
    Dio dio = Dio();
    dir = await Directory('/storage/emulated/0/Alphabics').create(recursive: true);
    try {
      await dio.download(widget.document.content,
          "${dir.path}/${widget.document.timestamp}$ext",
          onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
          progress = (rec / total);
        });
      });
    } catch (e) {
      downloading = false;
      print(e);
    }

    setState(() {
      path = "${dir.path}/${widget.document.timestamp}$ext";
      downloading = false;
      progress = 1;
      complete = true;
    });
    await DBHelper.insert(widget.groupChatId.replaceAll('-', '_'), {
      'id': widget.document.timestamp,
      'idFrom': widget.document.idFrom,
      'idTo': widget.document.idTo,
      'timestamp': widget.document.timestamp,
      'content': "${dir.path}/${widget.document.timestamp}$ext",
      'read': '0',
      'type': widget.document.type[0]
    });
    setState(() {});

    try {
      Firestore.instance
          .collection('messages')
          .document(widget.groupChatId)
          .collection(widget.groupChatId)
          .document(widget.document.timestamp)
          .updateData({
        'read': '0',
        'content': "${dir.path}/${widget.document.timestamp}$ext"
      });
      FirebaseStorage.instance
          .ref()
          .child(widget.groupChatId)
          .child(widget.document.type[0])
          .child(widget.document.timestamp)
          .delete();
    } catch (error) {
      print(error.toString());
    }
    Chat.of(widget.ctx).setState(() {});
    setState(() {});
    print("Download completed");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      child: InkWell(
          onTap: complete
              ? () {
                  widget.document.type[0] == '2'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullVideo(path)))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageView(path)));
                }
              : downloading
                  ? () {
                      Scaffold.of(context).hideCurrentSnackBar();
                      final snackBar = SnackBar(
                        content: Text('Already Downloading'),
                        action: SnackBarAction(
                          label: 'Ok',
                          onPressed: () {
                            Scaffold.of(context).hideCurrentSnackBar();
                          },
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  : () {
                      setState(() {
                        downloading = true;
                      });
                      Fluttertoast.showToast(
                          msg: 'Downloading', backgroundColor: Colors.teal);
                      downloadFile();
                    },
          child: complete
              ? widget.document.type[0] == '2'
                  ? FutureBuilder<Directory>(
                      future: Directory('/storage/emulated/0/Alphabics').create(recursive: true),
                      builder: (context, future) {
                        if (future.hasData) {
                          dir = future.data;
                          String ext =
                              widget.document.type[0] == '1' ? '.jpg' : '.mp4';
                          return VideoMessage(
                              "${dir.path}/${widget.document.timestamp}$ext");
                        } else {
                         return  CircularProgressIndicator();
                        }
                      })
                  : Image.file(
                      File(path),
                      fit: BoxFit.fill,
                    )
              : Stack(
                  children: [
                    Container(
                      height: 250,
                      child: Opacity(
                          opacity: 0.5,
                          child: widget.document.type[0] == '2'
                              ? Image.asset(
                                  'assets/lvideo.gif',
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  'assets/image.jpg',
                                  fit: BoxFit.fill,
                                )),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: downloading
                            ? Center(
                                child: CircularProgressIndicator(
                                value: progress,
                              ))
                            : CircleAvatar(
                                backgroundColor: Colors.white,
                                maxRadius: 30,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.cloud_download_outlined,
                                      color: Colors.teal,
                                    ),
                                    Text(
                                      widget.document.type.substring(1) + ' MB',
                                      style: TextStyle(color: Colors.teal),
                                    )
                                  ],
                                ),
                              )
                        // Text(
                        //     'Download',
                        //     style:
                        //         TextStyle(color: Colors.teal, fontSize: 30),
                        //   ),
                        )
                  ],
                )),
    );
  }
}
//download ? Center(child: CircularProgressIndicator()) : Text('Download'),
