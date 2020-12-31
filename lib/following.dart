import 'dart:convert';

import 'package:afri_shop/Json/Post.dart';
import 'cart_page.dart';
import 'new_account_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'Partial/list_item.dart';
import 'SuperBase.dart';

class Following extends StatefulWidget {
  final bool wrap;
  final User Function() user;
  final void Function(User user) callback;
  final GlobalKey<CartScreenState> cartState;

  const Following(
      {Key key,
      this.wrap: false,
      @required this.user,
      @required this.callback,
      @required this.cartState})
      : super(key: key);

  @override
  FollowingState createState() => FollowingState();
}

class FollowingState extends State<Following> with SuperBase {
  var refreshKey = new GlobalKey<RefreshIndicatorState>();

  ScrollController _controller = new ScrollController();

  bool _loadingMore = false;

  void goToTop() {
    _controller.animateTo(0.0,
        duration: Duration(milliseconds: 600), curve: Curves.easeIn);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this.loadPosts());
    _controller.addListener(() async {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        setState(() {
          _loadingMore = true;
        });
        await loadPosts(willReset: false);
        setState(() {
          _loadingMore = false;
        });
      }
    });
  }

  List<Post> _list = [];
  var _currentUrl = "";

  void refresh({bool reset: false}) {
    refreshKey.currentState?.show(atTop: true);
  }

  int current = 0;
  List<String> _urls = [];

  String get homeUrl => widget.user() == null
      ? "home/listPosts/recommend"
      : "discover/post/listPosts";

  Future<void> loadPosts({bool willReset: true}) {
    if (willReset) {
      current = 0;
    }
    return this.ajax(
        url:
            "$homeUrl?pageNo=$current&pageSize=12&${widget.user()?.id != null ? "userId=${widget.user()?.id}" : ""}",
        authKey: widget.user()?.token,
        error: (s, v) => print(s),
        onValue: (source, url) {
          if (willReset) {
            _urls.clear();
            _list.clear();
          }
          if (_urls.contains(url)) {
            return;
          }
          current += 1;
          _urls.add(url);
          Iterable map = json.decode(source);
          setState(() {
            var ls = map.map((f) => Post.fromJson(f)).toList();
            _list
              ..removeWhere((element) => ls.any((el) => el.id == element.id))
              ..addAll(ls);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return  buildPage;
  }

  Widget get buildPage {
    // TODO: implement build
    return RefreshIndicator(
      key: refreshKey,
      onRefresh: loadPosts,
      child: ListView.builder(
          shrinkWrap: true,
          controller: _controller,
          physics: widget.wrap
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          itemCount: _list.length + 1,
          itemBuilder: (context, index) {
            if (_list.length <= index) {
              return Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: _loadingMore
                          ? CircularProgressIndicator()
                          : SizedBox.shrink(),
                    )),
              );
            }
            var pst = _list[index];

            return ListItem(
              post: pst,
              user: widget.user,
              likePost: (status) {
                pst.liked = status.liked;
                pst.likes = status.likes;
                save(_currentUrl, _list);
              },
              delete: () {
                setState(() {
                  _list.remove(pst);
                });
                save(_currentUrl, _list);
                deletePost(pst, widget.user()?.token);
              },
              callback: widget.callback,
              cartState: widget.cartState,
            );
          }),
    );
  }
}
