import 'dart:convert';

import 'package:afri_shop/Json/hashtag.dart';
import 'package:afri_shop/Partial/list_item.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Post.dart';
import 'Json/User.dart';

class ViewTagScreen extends StatefulWidget {
  final Hashtag hashtag;
  final User Function() user;
  final void Function(Post post) likePost;
  final void Function(User user) callback;
  final void Function() delete;

  const ViewTagScreen(
      {Key key,
      @required this.hashtag,
      @required this.user,
      @required this.likePost,
      @required this.callback,
      @required this.delete})
      : super(key: key);

  @override
  _ViewTagScreenState createState() => _ViewTagScreenState();
}

class _ViewTagScreenState extends State<ViewTagScreen> with SuperBase {
  List<Post> _list = [];

  var _key = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _key.currentState?.show());
  }

  Future<void> _loadRelated() {
    return this.ajax(
        url: "discover/post/listPostsByHashtag/${Uri.encodeComponent(widget.hashtag.name)}?pageNo=0&pageSize=12",
        authKey: widget.user()?.token,
        server: true,
        onValue: (source, v) {
          Iterable map = json.decode(source);
          setState(() {
            _list = map.map((f) => Post.fromJson(f)).toList();
          });
        },
        error: (s, v) => print(s));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  Navigator.pop(context);
                })
            : null,
        title: Text("${widget.hashtag.name}"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: _key,
        onRefresh: _loadRelated,
        child: ListView.builder(
            itemCount: _list.length + 1,
            itemBuilder: (context, index) {
              index = index - 1;

              if (index < 0) {
                return Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 45,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${widget.hashtag.name}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                "${widget.hashtag.count} posts",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            RaisedButton(
                              onPressed: () {},
                              child: Text("Follow Hashtag"),
                              color: Colors.amber,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListItem(
                  post: _list[index],
                  user: widget.user,
                  likePost: widget.likePost,
                  delete: widget.delete,
                  callback: widget.callback);
            }),
      ),
    );
  }
}
