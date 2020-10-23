import 'package:afri_shop/Json/Picture.dart';
import 'package:afri_shop/Partial/image_map.dart';
import 'package:afri_shop/Partial/video_app.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Post.dart';
import 'Json/User.dart';

class TagPreview extends StatefulWidget {
  final Post post;
  final User Function() user;
  final int initialPage;
  final void Function(User user) callback;

  const TagPreview(
      {Key key,
      @required this.post,
      @required this.user,
      @required this.callback,
      this.initialPage: 0})
      : super(key: key);

  @override
  _TagPreviewState createState() => _TagPreviewState();
}

class _TagPreviewState extends State<TagPreview> with SuperBase {
  PageController _controller;

  var _index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _index = widget.initialPage;
    _controller = new PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          PageView.builder(
              controller: _controller,
              onPageChanged: (index){
                setState(() {
                  _index = index;
                });
              },
              itemCount: widget.post.pictures.length,
              itemBuilder: (context, index) {
                var pc = widget.post.pictures[index];
                return pc.isImage ? ImageMap(
                    provider: CachedNetworkImageProvider(pc.image),
                    positions: pc.products,
                    post: widget.post,
                    allowTap: false,
                    user: widget.user,
                    callback: widget.callback) : VideoApp(url: pc.image,thumb: pc.thumb,);
              }),
          Positioned(
              bottom: 15,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.post.pictures
                    .asMap()
                    .map((v, f) => MapEntry(
                        v,
                        Container(
                          height: 10,
                          width: 10,
                          margin: EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                              color: v == _index ? color : Colors.black38,
                              shape: BoxShape.circle),
                        )))
                    .values
                    .toList(),
              ))
        ],
      ),
    );
  }
}
