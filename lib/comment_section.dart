import 'dart:convert';

import 'package:afri_shop/Json/comment.dart';
import 'package:afri_shop/Partial/comment_item.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Post.dart';
import 'Json/User.dart';

class CommentSection extends StatefulWidget {
  final Post post;
  final User Function() user;
  final void Function(User user) callback;

  const CommentSection(
      {Key key,
      @required this.post,
      @required this.user,
      @required this.callback})
      : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> with SuperBase {
  TextEditingController _controller = new TextEditingController();

  List<Comment> _list = [];
  bool _sending = false;
  var _refKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this.refresh());
  }

  void refresh() {
    _refKey.currentState?.show(atTop: true);
  }

  Future<void> loadComments() {
    return this.ajax(
        url: "discover/comment/commentsByPostId/${widget.post?.id}?pageNo=0&pageSize=100",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          Iterable map = jsonDecode(source);
          setState(() {
            _list = map.map((f) => Comment.fromJson(f)).toList();
          });
        },
        error: (s, v) => print(s));
  }

  void sendComment() {
    if (_controller.text.trim().isEmpty || widget.user == null) return;
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "discover/comment/saveComment",
        authKey: widget.user()?.token,
        server: true,
        method: "POST",
        data: FormData.fromMap({
          "post": widget.post?.id,
          "userInfo": widget.user()?.id,
          "content": _controller.text
        }),
        onValue: (s, v) {
          _controller.clear();
          refresh();
        },
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.maybePop(context);
                })
            : null,
        title: Text("Comments"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              key: _refKey,
              onRefresh: loadComments,
              child: Scrollbar(
                child: ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (context, index) => CommentItem(
                        post: widget.post,
                        user: widget.user,
                        callback: widget.callback,
                        comment: _list[index])),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0 * 2),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                  height: 43,
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: "Add comment",
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5))),
                  ),
                )),
                _sending
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoActivityIndicator(),
                      )
                    : IconButton(icon: Icon(Icons.send), onPressed: sendComment)
              ],
            ),
          )
        ],
      ),
    );
  }
}
