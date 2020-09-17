import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoMessage extends StatefulWidget {
  static _VideoMessageState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<_VideoMessageState>());
  final String path;
  VideoMessage(this.path);
  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    _controller = VideoPlayerController.file(File(widget.path));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.pause();
    super.initState();
    print('path path GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG = '+ widget.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  if (!_controller.value.isPlaying)
                    CircleAvatar(//minRadius: 8.5,
                    maxRadius: 25,
                        backgroundColor: Colors.teal,
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 50,
                          color: Colors.white,
                        ))
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
