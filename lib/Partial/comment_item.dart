import 'dart:convert';

import 'package:afri_shop/Json/Post.dart';
import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/Json/comment.dart';
import 'package:afri_shop/Json/reply.dart';
import 'package:afri_shop/Partial/NowBuilder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../SuperBase.dart';
import '../discover_profile.dart';

class CommentItem extends StatefulWidget {
  final Post post;
  final Comment comment;
  final User Function() user;
  final void Function(User user) callback;

  const CommentItem(
      {Key key,
      @required this.post,
      @required this.user,
      @required this.callback,
      @required this.comment})
      : super(key: key);

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> with SuperBase {
  List<Reply> _list = [];
  TextEditingController _controller = new TextEditingController();

  bool _sending = false;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      this._loadReplies();
      var liked = (await prefs).containsKey(_likeUrl);
      setState(() {
        _liked = liked;
      });
    });
  }

  String get _likeUrl => "coment-like-${widget.comment?.id}";

  void _likeComment() {
    _liked = !_liked;
    setState(() {
      widget.comment.likes += _liked ? 1 : -1;
    });

    this.ajax(
        url: "discover/comment/like/saveCommentLike/$_liked",
        authKey: widget.user()?.token,
        server: true,
        method: "POST",
        data: FormData.fromMap({
          "comment": widget.comment?.id,
          "userInfo": widget.user()?.id,
        }),
        onValue: (source, url) async {
          if (_liked)
            saveVal(_likeUrl, "liked");
          else
            (await prefs).remove(_likeUrl);
          setState(() {});
        });
  }

  void _loadReplies() {
    this.ajax(
        url:
            "discover/replies/RepliesByCommentId/${widget.comment?.id}?pageNo=0&pageSize=50",
        authKey: widget.user()?.token,
        server: true,
        onValue: (source, url) {
          setState(() {
            _list = (json.decode(source) as Iterable)
                .map((f) => Reply.fromJson(f))
                .toList();
          });
        },
        error: (s, v) => print(s));
  }

  void saveReply() {
    if (widget.user() == null || _controller.text.trim().isEmpty) return;

    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "discover/replies/saveReply",
        server: true,
        authKey: widget.user()?.token,
        method: "POST",
        data: FormData.fromMap({
          "comment": widget.comment?.id,
          "userInfo": widget.user()?.id,
          "content": _controller.text
        }),
        onValue: (source, url) {
          Reply reply = Reply.fromJson(json.decode(source));
          setState(() {
            _controller.clear();
            widget.comment.replies++;
            _list.add(reply);
          });
        },
        onEnd: () {
          setState(() {
            _sending = false;
          });
        },
        error: (s, v) => print(s));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: InkWell(
            onTap: () {
              if (widget.post.user == null) return;
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => DiscoverProfile(
                          user: () => widget.comment.user,
                          object: widget.user,
                          callback: widget.callback)));
            },
            child: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider("${widget.comment.user?.avatar}"),
            )),
        title: Text("${widget.comment.user?.username}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NowBuilder(
                date: widget.comment.dateTime,
                style: TextStyle(
                    color: Color(0xffCCCCCC),
                    fontSize: 12,
                    fontFamily: 'Futura')),
            SizedBox(height: 10),
            Text("${widget.comment.content}"),
            SizedBox(height: 4),
            Row(
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      controller: _controller,
                                      onFieldSubmitted: (s) => this.saveReply(),
                                      decoration: InputDecoration.collapsed(
                                          hintText: "Add reply here"),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      saveReply();
                                    },
                                    child: Icon(
                                      Icons.send,
                                      size: 18,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 3.0),
                    child: Image(
                      image: AssetImage("assets/comments.png"),
                      width: 21,
                      height: 21,
                    ),
                  ),
                ),
                Text(
                  "${widget.comment.replies}",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontFamily: 'DIN Alternate'),
                ),
                InkWell(
                  onTap: _likeComment,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 3.0),
                    child: Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      color: Color(0xffffe707),
                    ),
                  ),
                ),
                Text(
                  "${widget.comment.likes}",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontFamily: 'DIN Alternate'),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    Share.share("${widget.comment.content}");
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                    child: Image(
                      image: AssetImage("assets/forwarding.png"),
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                IconButton(
                    icon: Image(
                      image: AssetImage("assets/btnicon_more.png"),
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {})
              ],
            ),
            _list.isEmpty
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(color: Color(0xffFAFAFA)),
                    child: Column(
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: "${_list.first.user?.username}",
                                style: TextStyle(
                                    color: Color(0xffF2CC24),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              WidgetSpan(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "${_list.first.content}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              )),
                            ],
                          ),
                        ),
                        _list.length > 1
                            ? InkWell(
                                onTap: _showDialog,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 4),
                                  child: Text(
                                    "View more replies(${_list.length - 1})",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
            _sending ? CupertinoActivityIndicator() : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    "${widget.comment.content}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  centerTitle: true,
                ),
                body: ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    var _reply = _list[index];
                    return ListTileTheme(
                      style: ListTileStyle.drawer,
                      child: ListTile(
                        leading: InkWell(
                            onTap: () {
                              if (_reply.user == null) return;
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => DiscoverProfile(
                                          user: () => _reply.user,
                                          object: widget.user,
                                          callback: widget.callback)));
                            },
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  "${_reply.user?.avatar}"),
                            )),
                        title: Text("${_reply.user?.username}"),
                        subtitle: Text("${_reply.content}"),
                      ),
                    );
                  },
                ),
              );
            }));
  }
}
