import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:io';

class FullVideo extends StatefulWidget {
  final String path;
  FullVideo(this.path);

  @override
  _FullVideoState createState() => _FullVideoState();
}

class _FullVideoState extends State<FullVideo> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    Wakelock.enable();
    _controller = VideoPlayerController.file(File(widget.path));

    _initializeVideoPlayerFuture = _controller.initialize();
    //_controller.seekTo(Duration(seconds: widget.position));
    _controller.play();
    SystemChrome.setEnabledSystemUIOverlays([]);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onDoubleTap: () {},
          onTap: () {
            print(_controller.value.initialized.toString());
            setState(() {
              // If the video is playing, pause it.
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else if (_controller.value.position ==
                  _controller.value.duration) {
                // If the video is paused, play it.
                _controller.seekTo(Duration(microseconds: 1));
                _controller.play();
              } else {
                _controller.play();
              }
            });
          },
          child: Container(
            child: // Use a FutureBuilder to display a loading spinner while waiting for the
// VideoPlayerController to finish initializing.
                FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the VideoPlayer.
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_controller),
                        VideoProgressIndicator(

                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                              backgroundColor: Colors.white,
                              bufferedColor: Colors.orange[200],
                              playedColor: Colors.teal),
                        ),
                        _PlayPauseOverlay(controller: _controller,)
                      ],
                    ),
                  );
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return Center(child: CircularProgressIndicator(

                  ));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        // GestureDetector(
        //   onTap: () {
        //     controller.value.isPlaying ? controller.pause() : controller.play();
        //   },
        // ),
      ],
    );
  }
}