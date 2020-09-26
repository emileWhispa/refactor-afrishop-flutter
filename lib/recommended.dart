import 'dart:convert';

import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/Json/hashtag.dart';
import 'Json/tag.dart';
import 'package:afri_shop/discover_description.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'Json/Post.dart';
import 'SuperBase.dart';
import 'account_screen.dart';
import 'view_tag_screen.dart';

class Recommended extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const Recommended({Key key, @required this.user, @required this.callback})
      : super(key: key);

  @override
  _RecommendedState createState() => _RecommendedState();
}

class _RecommendedState extends State<Recommended> with SuperBase {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this._refreshList());

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _refreshList(inc: true);
        print("reached bottom ($current)");
      }
    });
  }

  ScrollController _controller = new ScrollController();

  int max;
  int current = 0;
  List<String> _urls = [];

  List<Post> _list = [];

  void refresh() {
    _control.currentState?.show(atTop: true);
  }

  Future<void> loadPosts({bool inc: true}) {
    return this.ajax(
        url:
            "home/listPosts/recommend?userId=${widget.user()?.id ?? 0}&pageNo=$current&pageSize=12",
        authKey: widget.user()?.token,
        server: true,
        onValue: (source, url) {
          if (_urls.contains(url)) {
            return;
          }
          current += inc ? 1 : 0;
          _urls.add(url);
          Iterable map = json.decode(source);
          setState(() {
            var l = map.map((f) => Post.fromJson(f)).toList();
            _list..removeWhere((element) => l.any((el) => el.id == element.id))..addAll(l);
          });
        });
  }

  var _control = new GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshList({bool inc: true}) {
    _control.currentState?.show(atTop: true);

    _loadItems(inc: inc);
    return loadPosts();
  }

  var _currentUrl = "";

  Future<void> _loadItems({bool inc: false}) {
    if (max != null && current > max) {
      return Future.value();
    }
    return this.ajax(
        url: "home/listHashtags?pageNo=$current&pageSize=12",
        server: true,
        onValue: (source, url) {
          //print("Whispa sent requests ($current): $url");
          Iterable _map = json.decode(source);
          setState(() {
            var l = _map.map((f) => Hashtag.fromJson(f)).toList();
            _products..removeWhere((f) => l.any((element) => f.id == element.id))..addAll(l);
          });
        },
        onEnd: () {},
        error: (s, v) {
          print(" error vegan : $s");
        });
  }

  List<Hashtag> _products = [];

  @override
  Widget build(BuildContext context) {
    return buildPage;
  }

  Widget get buildPage {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Center(
                  child: InkWell(
                onTap: () {
                  if (widget.user() == null) return;
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ViewTagScreen(
                                user: widget.user,
                                callback: widget.callback,
                                likePost: (p) {},
                                delete: () {},
                                hashtag: _products[index],
                              )));
                },
                child: Container(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      "${_products[index].name}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DIN Alternate'),
                    )),
              ));
            },
            itemCount: _products.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshList,
            key: _control,
            child: StaggeredGridView.countBuilder(
              controller: _controller,
              padding: EdgeInsets.all(5),
              crossAxisCount: 4,
              itemCount: _list.length,
              itemBuilder: (BuildContext context, int index) {
                var pst = _list[index];
                return GestureDetector(
                  onTap: () async {
                    if (widget.user != null)
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => DiscoverDescription(
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
                                      deletePost(pst);
                                    },
                                    callback: widget.callback,
                                    url: CachedNetworkImageProvider(
                                        pst.bigImage),
                                  )));
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                          margin: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xffE0E0E0).withOpacity(0.6),
                                  offset: Offset(0.0, .35),
                                  //(x,y)
                                  blurRadius: 3.0,
                                  spreadRadius: 0.4),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    topRight: Radius.circular(5.0)),
                                child: FadeInImage(
                                    image: CachedNetworkImageProvider(
                                        pst.bigImage),
                                    fit: BoxFit.fitWidth,
                                    placeholder: defLoader),
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  child: Text(
                                    (pst.title ?? "").toUpperCase(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13, fontFamily: 'Asimov'),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 7, right: 5, left: 5),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundImage: defLoader,
                                        ),
                                      ),
                                      Text(
                                        '${pst.username}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Spacer(),
                                      Image(
                                        image:
                                            AssetImage("assets/small_like.png"),
                                        height: 16,
                                        width: 16,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          "${pst.likes}",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    ],
                                  )),
                            ],
                          ))),
                );
              },
              staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }
}
