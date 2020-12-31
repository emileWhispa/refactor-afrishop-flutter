import 'dart:convert';
import 'dart:io';

import 'package:afri_shop/Json/Post.dart';
import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/Json/choice.dart';
import 'package:afri_shop/Json/position.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/description.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageMap extends StatefulWidget {
  final ImageProvider provider;
  final Choice choice;
  final List<Position> positions;
  final User Function() user;
  final void Function(User user) callback;
  final void Function(Position position) firstTaped;
  final Post post;
  final bool allowTap;

  const ImageMap(
      {Key key,
      @required this.provider,
      this.positions,
      this.choice,
      this.allowTap: true,
      @required this.user,
      @required this.callback,
      this.firstTaped,
      this.post})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new ImageMapState();
  }
}

class ImageMapState extends State<ImageMap> with SuperBase {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void populate(Position position) {
    widget.positions?.forEach((f) {
      if (position.x == f.x && position.y == f.y) {
        f.tagName = position.tagName;
      }
    });
  }

  void onTapDown(BuildContext context, TapDownDetails details) async {
    //print('${details.globalPosition}');
    if (widget.allowTap) {
      final RenderBox box = context.findRenderObject();
      final Offset localOffset = box.globalToLocal(details.globalPosition);
      var pro = await showModalBottomSheet<Product>(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return _GetProducts();
          });
      if (pro == null) return;
      setState(() {
        var position = Position(localOffset.dx, localOffset.dy, pro.title, pro);
        widget.choice?.list?.add(position);
        if( widget.firstTaped != null ){
          widget.firstTaped(position);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTapDown: (TapDownDetails details) => onTapDown(context, details),
      child: new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Hack to expand stack to fill all the space. There must be a better
            // way to do it.
            new Container(
              color: Colors.white,
              child: FadeInImage(
                placeholder: defLoader,
                image: widget.provider,
                fit: BoxFit.cover,
              ),
            ),
          ]..addAll(widget.positions.map((f) => new Positioned(
                child: GestureDetector(
                  onTapDown: (s) async {
                    if (widget.firstTaped != null)
                      widget.firstTaped(f);
                    else {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  Description(
                                    post: widget.post,
                                    product: f.product,
                                    user: widget.user,
                                    callback: widget.callback,
                                  )));
                    }
                  },
                  child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            "assets/dot.png",
                            height: 15,
                            width: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Image.asset("assets/cart_.png",
                                height: 15, width: 15),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new Text(
                                '${f.getTagName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
                left: f.x,
                top: f.y,
              )))),
    );
  }
}

class _GetProducts extends StatefulWidget {
  @override
  __GetProductsState createState() => __GetProductsState();
}

class __GetProductsState extends State<_GetProducts> with SuperBase {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => this._refreshList(inc: true));
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _refreshList(inc: true);
      }
    });
  }

  ScrollController _controller = new ScrollController();

  int max;
  int current = 0;
  List<String> _urls = [];
  List<Product> _products = [];

  var _control = new GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshList({bool inc: true}) {
    _control.currentState?.show(atTop: true);

    return _text.isEmpty ? _loadItems() : _loadData(_text);
  }

  Future<void> _loadItems() {
    setState(() {});
    return this.ajax(
        url: "itemStation/queryAll?pageNo=$current&pageSize=12",
        auth: false,
        onValue: (source, url) {
          if (_urls.contains(url)) {
            return;
          }
          current++;
          _urls.add(url);
          //print("Whispa sent requests ($current): $url");
          Iterable _map = json.decode(source)['data']['content'];
          setState(() {
            _products.addAll(_map.map((f) => Product.fromJson(f)).toList());
          });
        },
        onEnd: () {
          setState(() {});
        },
        error: (s, v) {
          print(" error vegan : $s");
        });
  }

  bool _searching = false;

  Future<void> _loadData(String query) {
    setState(() {
      _searching = true;
    });

    return this.ajax(
        url:
            "itemStation/searchItems?name=${Uri.encodeComponent(query)}&pageNum=0&pageSize=50",
        server: true,
        onValue: (source, url) {
          if (_urls.contains(url)) {
            return;
          }
          current++;
          _urls.add(url);
          Iterable _map = json.decode(source)['data']['content'];
          setState(() {
            _products = _map.map((f) => Product.fromJson(f)).toList();
          });
        },
        error: (s, v) => print(s),
        onEnd: () {
          setState(() {
            _searching = false;
          });
        });
  }

  var _text = "";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 80),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(6), topLeft: Radius.circular(6))),
      child: Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })
              : null,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Container(
            height: 35,
            child: TextFormField(
              onChanged: (s) => _text = s,
              onFieldSubmitted: _loadData,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _searching ? CupertinoActivityIndicator() : null,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  hintText: "Search",
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(6))),
            ),
          ),
          actions: <Widget>[
            IconButton(
                icon: Image.asset("assets/search_v2.png",
                    height: 24, width: 24, color: Colors.white),
                onPressed: () => this._loadData(_text))
          ],
        ),
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: _refreshList,
          key: _control,
          child: ListView.builder(
              itemCount: _products.length,
              controller: _controller,
              padding: EdgeInsets.all(15),
              itemBuilder: (context, index) {
                var pro = _products[index];
                var img = FadeInImage(
                  height: 100,
                  width: 100,
                  image: CachedNetworkImageProvider('${_products[index].url}'),
                  fit: BoxFit.cover,
                  placeholder: defLoader,
                );
                return Card(
                  elevation: 1.0,
                  color: Colors.white.withOpacity(0.7),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        pro.selected = !pro.selected;
                        Navigator.maybePop(context, pro);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: pro.selected
                          ? Colors.grey.shade200.withOpacity(0.6)
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          pro.selected
                              ? Stack(
                                  children: <Widget>[
                                    img,
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          margin: EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              border: pro.selected
                                                  ? null
                                                  : Border.all(
                                                      color: Colors.grey),
                                              shape: BoxShape.circle,
                                              color: pro.selected
                                                  ? color
                                                  : Colors.white),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                pro.selected ? 2.0 : 11),
                                            child: pro.selected
                                                ? Icon(
                                                    Icons.check,
                                                    size: 30.0,
                                                    color: Colors.black,
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : img,
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _products[index].title,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 7),
                                  child: Text(
                                    '\$${_products[index].price}',
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                ),
                                Row(
                                  children: List.generate(6, (index) {
                                    return index == 5
                                        ? Expanded(
                                            child: Text(
                                            "${_products[index].count} orders",
                                            textAlign: TextAlign.end,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ))
                                        : Icon(
                                            Icons.star_border,
                                            color: Colors.amber,
                                            size: 15,
                                          );
                                  }),
                                ),
                              ],
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
