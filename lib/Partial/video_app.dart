import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../SuperBase.dart';

class VideoApp extends StatefulWidget {
  final String url;
  final String thumb;


  const VideoApp({Key key,@required this.url, this.thumb}) : super(key: key);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> with SuperBase {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.addListener((){
      setState(() {

      });
    });
  }

//  @override
//  Widget build(context){
//    return Center();
//  }

  bool get initialized => _controller.value.initialized;


  Widget get _video => initialized
      ? AspectRatio(
    aspectRatio: _controller.value.aspectRatio,
    child: VideoPlayer(_controller),
  )
      : Stack(
        children: [
          Center(
            child: Container( width: double.infinity,decoration:BoxDecoration(
    image:DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(widget.thumb ?? "")
    )
  ),child: FadeInImage(placeholder: defLoader,fit: BoxFit.cover, image: CachedNetworkImageProvider(widget.thumb ?? "")),),
          ),
          Positioned(child: Center(child: CupertinoActivityIndicator(radius: 30),))
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isPlaying || !_controller.value.initialized ? InkWell(onTap: (){
        setState(() {
          _controller.pause();
        });
      },child: _video) : Stack(
        children: [
          Center(child: _video),
          Positioned(child: Center(
            child: InkWell(onTap: () async{
              if( _controller.value.duration.inMilliseconds <= _controller.value.position.inMilliseconds && _controller.value.initialized )
              await _controller.seekTo(Duration.zero);
              setState(() {
                _controller.play();
              });
            },child: Icon(Icons.play_arrow,color: Colors.white54,size: 80,)),
          ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}