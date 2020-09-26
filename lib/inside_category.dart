import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:afri_shop/Json/Product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/SubSubCategory.dart';
import 'Json/User.dart';
import 'Partial/TouchableOpacity.dart';
import 'SuperBase.dart';
import 'description.dart';

class InsideCategory extends StatefulWidget {
  final SubSubCategory category;
  final User Function() user;
  final void Function(User user) callback;
  final String prefix;

  const InsideCategory(
      {Key key,
      @required this.category,
      @required this.user,
      @required this.callback,
      this.prefix: "itemStation/queryItemsByTypeTwo?typeTwoId"})
      : super(key: key);

  @override
  _InsideCategoryState createState() => _InsideCategoryState();
}

class _InsideCategoryState extends State<InsideCategory> with SuperBase {
  int max;
  int current = 0;
  bool _loading = false;
  int _index = 0;
  List<String> _urls = [];
  List<Product> _items = [];
  List<Product> _itemsUp = [];
  List<Product> _itemsDown = [];
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => this._loadItems(inc: true));
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadItems(inc: true);
      }
    });
  }

  Future<void> _loadItems({bool inc: false}) {
    if (max != null && current > max) {
      return Future.value();
    }
    current += inc ? 1 : 0;
    setState(() {
      _loading = true;
    });
    return this.ajax(
        url:
            "${widget.prefix}=${widget.category?.id}&pageNum=$current&pageSize=12",
        auth: false,
        server: true,
        onValue: (source, url) {
          if (_urls.contains(url)) {
            return;
          }
          _urls.add(url);
          //print("Whispa sent requests ($current): $url");
          Map<String, dynamic> _data = json.decode(source)['data'];
          Iterable _map = _data['content'];
          max = _data['totalPages'];
          setState(() {
            _items.addAll(_map.map((f) => Product.fromJson(f)).toList());
            _itemsUp = _items.toList();
            _itemsDown = _items.toList();
            _itemsUp.sort((f,c)=>c.price.compareTo(f.price));
            _itemsDown.sort((f,c)=>f.price.compareTo(c.price));
          });
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
        },
        error: (s, v) {
          print(s);
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
        title: Text("${widget.category?.name}".toUpperCase(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ProductList(
        items: _items,
        user: widget.user,
        controller: _controller,
        callback: widget.callback,
        loadData: _loadItems,
        itemsUp: _itemsUp,
        itemsDown: _itemsDown,
      ),
      bottomNavigationBar: _loading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoActivityIndicator(),
            )
          : null,
    );
  }
}

class ProductList extends StatefulWidget {
  final List<Product> items;
  final List<Product> itemsUp;
  final List<Product> itemsDown;
  final User Function() user;
  final ScrollController controller;
  final bool autoLoad;
  final void Function(User user) callback;
  final Future<void> Function() loadData;

  const ProductList(
      {Key key,
      @required this.items,
      @required this.user,
      @required this.controller,
      @required this.callback,
      @required this.loadData,@required this.itemsUp,@required this.itemsDown, this.autoLoad:false})
      : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> with SuperBase {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if( widget.autoLoad ) _key.currentState?.show(atTop: true);
    });
  }

  var _key = new GlobalKey<RefreshIndicatorState>();

  int _index = 0;

  bool _isUp = true;

  List<Product> get _list => _index == 0 ? widget.items : _isUp ? widget.itemsUp : widget.itemsDown;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
          margin: EdgeInsets.symmetric(vertical: 5),
          height: 47,
          child: Center(
            child: Row(
              children: <Widget>[
                Spacer(),
                InkWell(
                    onTap: () {
                      setState(() {
                        _index = 0;
                      });
                    },
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                child: Text(
                                  "New In",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Asimov',
                                      color: Color(0xff4D4D4D),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 3,
                              color: _index == 0
                                  ? Color(0xff4D4D4D)
                                  : Colors.white,
                            )
                          ],
                        ))),
                Container(
                  width: 50,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        _index = 1;
                        _isUp = !_isUp;
                      });
                    },
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "Price Up",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Asimov',
                                          color: Color(0xff4D4D4D),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Container(
                                      height: 45,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Spacer(),
                                            Image.asset(
                                              'assets/arrow_up.png',
                                              width: 8,
                                              height: 5,
                                              color: _index == 1 && !_isUp
                                                  ? color
                                                  : Color(0xffCCCCCC),
                                            ),
                                            SizedBox(height: 3),
                                            Image.asset(
                                              'assets/arrow_down.png',
                                              width: 8,
                                              height: 5,
                                              color: _index == 1 && _isUp
                                                  ? color
                                                  : Color(0xffCCCCCC),
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 3,
                              color: _index == 1
                                  ? Color(0xff4D4D4D)
                                  : Colors.white,
                              margin: EdgeInsets.only(right: 20),
                            )
                          ],
                        ))),
                Spacer(),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            key: _key,
            onRefresh: widget.loadData,
            child: GridView.builder(
              controller: widget.controller,
              itemCount: _list.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.4 / 4,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0),
              itemBuilder: (context, index) {
                var _pro = _list[index];
                return TouchableOpacity(
                  padding: EdgeInsets.all(5),
                  onTap: () async {
                    await Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => Description(
                            user: widget.user,
                            callback: widget.callback,
                            product: _pro)));
                  },
                  child: Container(
                    height: 170,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Container(
                          constraints:
                              BoxConstraints(minWidth: double.infinity),
                          child: FadeInImage(
                            image: CachedNetworkImageProvider(
                                '${_pro.url}'),
                            fit: BoxFit.cover,
                            placeholder: defLoader,
                          ),
                        )),
                        SizedBox(height: 5),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              '${_pro.title}',
                              style: TextStyle(
                                  color: Color(0xff4d4d4d),
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '\$${_pro.price}',
                              style: TextStyle(color: Color(0xffCDCDCD)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
