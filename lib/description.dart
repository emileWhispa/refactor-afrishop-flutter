import 'dart:convert';
import 'dart:math';

import 'package:afri_shop/complete_order.dart';
import 'package:afri_shop/new_account_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/Partial/ReviewItem.dart';
import 'package:afri_shop/ReviewScreen.dart';
import 'package:afri_shop/cart_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

import 'Coupon.dart';
import 'Json/Post.dart';
import 'Json/Sku.dart';
import 'Json/User.dart';
import 'Json/option.dart';
import 'Json/order.dart';
import 'Json/Review.dart';
import 'Partial/TouchableOpacity.dart';
import 'SuperBase.dart';

class Description extends StatefulWidget {
  final Order order;
  final Product product;
  final Review review;
  final Post post;
  final String fromCode;
  final User Function() user;
  final String itemId;
  final void Function(User user) callback;

  const Description(
      {Key key,
      @required this.product,
      @required this.user,
      @required this.callback,
      this.order,
      this.post,
      this.fromCode,
      this.review,
      this.itemId})
      : super(key: key);

  @override
  _DescriptionState createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> with SuperBase {
  Widget _tit(int has, String title, GlobalKey key) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: has == _index
            ? BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.black, width: 4)))
            : null,
        child: Center(
          child: Text(
            title,
            maxLines: 1,
            style: TextStyle(
                fontSize: 15,
                fontFamily: 'SF UI Display',
                fontWeight: has == _index ? FontWeight.w800 : null),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _index = has;
          if (key == null)
            _controller.animateTo(0,
                duration: Duration(seconds: 2), curve: Curves.easeInCubic);
          else
            Scrollable.ensureVisible(key?.currentContext ?? context,
                curve: Curves.linear, duration: Duration(milliseconds: 500));
        });
      },
    );
  }

  int _index = 0;

  Database database;
  Product _newProduct;
  int _current = 0;
  ScrollController _controller = new ScrollController();
  int score = 5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (product != null) {
        this.open();
        this.loadComments();
      }
      _loadRecommended();
      this.loadDetails();
      var list = await getProductsFav();
      setState(() {
        this._list = list;
      });
    });

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadRecommended(inc: true);
        //print("reached bottom ($current)");
      }
    });
  }

  Product get product => _newProduct ?? widget.product;

  String get itemId => product?.itemId ?? widget.itemId;

  List<Product> _recommended = [];
  List<String> _urls = [];
  int current = 0;
  var _loading2 = false;
  bool _ended = false;

  void _loadRecommended({bool inc: false}) {
    current += inc ? 1 : 0;
    setState(() {
      _loading2 = true;
    });
    this.ajax(
        url:
            "itemStation/getRecommendItems?itemId=$itemId&pageNum=$current&pageSize=20",
        onValue: (source, url) {
          if (_urls.contains(url)) {
            return;
          }
          _urls.add(url);
          var map = jsonDecode(source);
          if (map['code'] == 1) {
            var data = map['data'];
            setState(() {
              var l2 = (data['content'] as Iterable)
                  .map((e) => Product.fromJson(e))
              .where((element) => element.enableFlag == null || element.enableFlag == 1)
                  .toList();
              _ended = l2.length < 20;

              _recommended
                ..removeWhere(
                    (el) => l2.any((element) => element.itemId == el.itemId))
                ..addAll(l2);
            });
          }
        },
        onEnd: () {
          setState(() {
            _loading2 = true;
          });
        });
  }

  List<Product> _list = [];
  List<Review> _listReview = [];

  var _refreshKey = new GlobalKey<RefreshIndicatorState>();

  bool get hasFavorite => _list.any((f) => f.itemId == itemId);

  void _goToCart({Product product}) {
    Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => CartScreen(
              user: widget.user,
              product: product,
              callback: widget.callback,
            )));
  }

  void giveLike() {
    this.ajax(
        url:
            "shopify/giveLike/${widget.review.id}/${widget.user()?.id}/$itemId",
        server: true,
        onValue: (s, v) {
          print(s);
        },
        error: (s, v) => print(s));
  }

  bool get _processing => _sending || _loading;

  Future<void> waitUserCheck() async {
    var _user = widget.user();
    if (_user == null) {
      _user = await Navigator.of(context).push(CupertinoPageRoute<User>(
          builder: (context) => AccountScreen(
                canPop: true,
                user: widget.user,
                callback: widget.callback,
                cartState: null,
              )));
      if (widget.callback != null && _user != null) widget.callback(_user);
      setState(() {});
    }
    return Future.value();
  }

  var _loading = false;

  Future<void> loadDetails({bool loading: false}) {
    setState(() {
      _loading = loading;
    });
    return this.ajax(
        url: "itemStation/queryItemSku?itemId=$itemId",
        auth: false,
        onValue: (source, url) {
          print(url);
          var map = json.decode(source);
          if (map != null && map['data'] != null) {
            var data = map['data'];
            setState(() {
              score = data['score'] is int
                  ? data['score']
                  : data['score'] is double
                      ? (data['score'] as double).toInt()
                      : 0;
              _newProduct = Product.fromJson(data['itemInfo'],
                  options: data['optionList'],
                  det: data['itemDetail'],
                  params: data['itemParam'],
                  desc: data['itemDesc']);
            });
            if (_popRequested) {
              openCart(continueToCart: _continueToCart);
              _popRequested = false;
            }
          }
        },
        error: (source, url) {
          print(source);
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
        });
  }

  Future<void> loadComments() {
    return this.ajax(
        url:
            "shopify/querycomments?itemId=$itemId&pageNum=0&pageSize=10${widget.user() != null ? "&userId=${widget.user()?.id}" : ""}",
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          print(source);
          var map = json.decode(source);
          Iterable iterable = map['data']['content'];
          setState(() {
            _listReview =
                iterable.map((json) => Review.fromJson(json)).toList();
          });
        });
  }

  void open() async {}

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    database?.close();
  }

  var _popRequested = false;

  var _selected = false;

  void _checkMoreTrans() {
    if (widget.post != null) {
      saveVisited(widget.post);
    }
    if (widget.fromCode != null) {
      product.fromCode = widget.fromCode;
      saveVisitedProduct(product);
    }
  }

  void buyItNow(Map<String, dynamic> map) async {
    if (_selected) return;

    _selected = true;

    var payUrl =
        "itemId=${Uri.encodeComponent(itemId)}&itemSku=${Uri.encodeComponent(product?.size)}&itemPrice=${Uri.encodeComponent('${product?.price ?? 0.0}')}&itemNum=${_newProduct.items ?? 1}";

    await this.ajax(
        url: "order/payNow?$payUrl",
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          print(source);
          var d = json.decode(source);
          if (d != null && d['code'] == 1) {
            _checkMoreTrans();
            Order order = Order.fromJson(d['data']);
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => CompleteOrder(
                          user: widget.user,
                          list: order.itemList,
                          callback: widget.callback,
                          order: order,
                          payNowParams: payUrl,
                        )));
          } else {
            platform.invokeMethod("toast", d['message']);
          }
        },
        error: (s, v) => platform.invokeMethod("toast", s),
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });

    _selected = false;
  }

  void addToCart({bool continueToCart: false}) async {
    if (widget.user() == null) {
      platform.invokeMethod("toast", "Not signed in, sign in to continue");
      User user = await awaitUser();
      if (widget.callback != null) {
        widget.callback(user);
      }
      if (user == null) {
        return;
      }
      setState(() {});
    }
    setState(() {
      _sending = true;
    });
    var map = {
      "stationId": product?.itemId,
      "itemId": product?.itemId,
      "shopId": product?.itemId,
      "itemTitle": product?.title,
      "itemPrice": product?.price ?? 0.0,
      "stationType": 1,
      "itemNum": product.items ?? 1,
      "itemImg": product.url,
      "itemSku": "${product.size}",
      "shopName": "afrishop",
      "shopUrl": "blue",
      "itemSourceId": "blue",
    };

    print(map);

    if (continueToCart) {
      buyItNow(map);
      return;
    }

    this.ajax(
      url: "cart",
      method: "POST",
      map: map,
      server: true,
      auth: true,
      authKey: widget.user()?.token,
      onValue: (source, url) {
        var map = json.decode(source);
        if (map['code'] == 1) {
          _checkMoreTrans();
          if (continueToCart) {
            print(source);
            _goToCart(product: _newProduct);
          }
          platform.invokeMethod('logAddToCartEvent', <String, dynamic>{
            'contentData': product.title,
            'contentId': "${product.itemId}",
            'contentType': "1",
            'currency': 'USD',
            'price': product.discountPrice
          });
          platform.invokeMethod("toast", "Product added to cart");
          setState(() {
            widget.user()?.cartCount += product.items;
          });
        } else {
          platform.invokeMethod("toast", "${map['message']}");
        }
        print(source);
      },
      onEnd: () {
        setState(() {
          _sending = false;
        });
      },
      error: (source, url) {
        print(source);
        platform.invokeMethod("toast", "$source");
      },
    );
  }

  var _sending = false;

  var _continueToCart = false;

  void openCart({bool continueToCart: false}) async {
    if (_newProduct == null) {
      _popRequested = true;
      _continueToCart = continueToCart;
      await loadDetails(loading: true);
      if (!_popRequested) return;
      _popRequested = false;
    }

    if (_newProduct == null) return;

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return DescState(
              value: product?.items ?? 1,
              size: product?.size,
              continueToCart: continueToCart,
              product: product,
              skus: _newProduct?.sku ?? [],
              options: _newProduct?.options ?? [],
              onAdd: (value,img , size, price) async {
                _newProduct.items = value;
                _newProduct.size = size;
                _newProduct.price = price;
                _newProduct.url = img;
                _newProduct.updateItem(database);

                setState(() {
                  Navigator.of(context).pop();
                  addToCart(continueToCart: continueToCart);
                });
              });
        });
  }

  Future<User> awaitUser() async {
    User user = await Navigator.of(context).push<User>(CupertinoPageRoute(
        builder: (context) => AccountScreen(
              canPop: true,
              user: widget.user,
              callback: widget.callback,
              cartState: null,
            )));
    return user;
  }

  var _productKey = new GlobalKey();
  var _detailKey = new GlobalKey();
  var _reviewKey = new GlobalKey();

  final double _appBarHeight = 356.0;

  Widget get app => PreferredSize(
        preferredSize: Size.fromHeight(46.0),
        child: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Row(
            children: <Widget>[
              Expanded(child: _tit(0, "Product", _productKey)),
              Expanded(child: _tit(1, "Details", _detailKey)),
              Expanded(child: _tit(2, "Reviews", _reviewKey)),
            ],
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Image.asset("assets/forwarding.png",
                    height: 24, width: 24, color: Colors.black),
                onPressed: () {
                  Share.share(
                      '${server000}product_detail?pid=$itemId${widget.user() != null ? "&code=${widget.user().code}" : ""}');
                })
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return product == null
        ? Scaffold(
            appBar: app,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: app,
            body: SingleChildScrollView(
              controller: _controller,
              child: Column(
                children: <Widget>[
                  Container(
                    key: _productKey,
                    child: _newProduct != null && _newProduct.images.isNotEmpty
                        ? Stack(children: <Widget>[
                            CarouselSlider.builder(
                                height: _appBarHeight + 10,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 2),
                                pauseAutoPlayOnTouch: Duration(seconds: 2),
                                itemCount: _newProduct.images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _current = index;
                                  });
                                },
                                viewportFraction: 1.1,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: double.infinity,
                                    height: _appBarHeight,
                                    color: Colors.primaries[Random()
                                        .nextInt(Colors.primaries.length)],
                                    child: FadeInImage(
                                        height: _appBarHeight,
                                        image: CachedNetworkImageProvider(
                                            _newProduct.images[index]),
                                        fit: BoxFit.cover,
                                        placeholder: defLoader),
                                  );
                                }),
                            Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                      _newProduct.images.length, (index) {
                                    return Container(
                                      width: 20.0,
                                      height: 3.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                          color: _current == index
                                              ? color
                                              : Color.fromRGBO(0, 0, 0, 0.4)),
                                    );
                                  }),
                                ))
                          ])
                        : FadeInImage(
                            height: 300,
                            width: double.infinity,
                            image:
                                CachedNetworkImageProvider(widget.product.url),
                            placeholder: defLoader,
                            fit: BoxFit.cover),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            children: <Widget>[
                              Text(
                                '\$${product.price}',
                                style: TextStyle(
                                    color: Color(0xffFE8206),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900),
                              ),
                              product.hasOldPrice
                                  ? Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      child: Text(
                                        '\$${product.oldPrice}',
                                        style: TextStyle(
                                            color: Color(0xffA9A9A9),
                                            fontSize: 15,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                    )
                                  : SizedBox.shrink()
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            '${product.title}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'SF UI Text'),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            '${product.title}',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: List.generate(
                                5,
                                (index) => Image.asset(
                                      'assets/${index <= score ? 'star' : 'star_border'}.png',
                                      height: 24,
                                      width: 24,
                                    )).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Select Variation Size",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'SF UI Text'),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                                size: 15,
                              )
                            ],
                          ),
                          onTap: openCart,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) => CouponScreen(
                                      user: widget.user,
                                    )));
                          },
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Coupons",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'SF UI Text'),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                                size: 15,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    key: _reviewKey,
                    margin:
                        EdgeInsets.symmetric(vertical: 5).copyWith(bottom: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Row(children: [
                            Text(
                              "Reviews",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'SF UI Text'),
                            ),
                            Spacer(),
                            Text(
                              "View all",
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 15),
                            ),
                          ]),
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) => ReviewScreen(
                                      list: _newProduct?.reviews ?? [],
                                      user: widget.user,
                                      callback: widget.callback,
                                      product: widget.product,
                                      order: widget.order,
                                    )));
                          },
                        ),
                        SizedBox(height: 15),
                        Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.all(10),
                                itemCount: _listReview.length > 3
                                    ? 3
                                    : _listReview.length,
                                itemBuilder: (context, index) {
                                  return ReviewItem(
                                    review: _listReview[index],
                                    user: widget.user,
                                    product: widget.product,
                                    callback: widget.callback,
                                  );
                                })),
                      ],
                    ),
                  ),
                  Container(
                    key: _detailKey,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding:
                        EdgeInsets.symmetric(vertical: 20).copyWith(top: 5),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "Detail",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: (product?.infos ?? [])
                                  .map((e) => Container(
                                        margin:
                                            EdgeInsets.only(bottom: 9, top: 10),
                                        child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: "${e.paramName} : ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  TextSpan(
                                                      text:
                                                          "\n${e.paramValue}"),
                                                ],
                                                style: TextStyle(
                                                    color: Colors.black87))),
                                      ))
                                  .toList(),
                            ),
                          ),
                          Column(
                            children: (product?.images2 ?? [])
                                    ?.map((f) => FadeInImage(
                                          image: CachedNetworkImageProvider(f),
                                          placeholder: defLoader,
                                          fit: BoxFit.fitWidth,
                                          width: double.infinity,
                                        ))
                                    ?.toList() ??
                                [],
                          ),
                        ]),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                            child: Text(
                          "You may like",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'SF UI Text'),
                        )),
                        SizedBox(height: 10),
                        GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 3.1 / 4,
                                    crossAxisSpacing: 7),
                            itemCount: _recommended.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var _pro = _recommended[index];
                              return TouchableOpacity(
                                padding: EdgeInsets.all(0),
                                onTap: () async {
                                  await Navigator.of(context)
                                      .pushReplacement(CupertinoPageRoute(
                                          builder: (context) => Description(
                                                product: _pro,
                                                user: widget.user,
                                                callback: widget.callback,
                                              )));
                                  //widget.cartState.currentState?.refresh();
                                },
                                child: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Container(
                                        constraints: BoxConstraints(
                                            minWidth: double.infinity),
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
                                                fontFamily: 'Asimov',
                                                color: Color(0xff4d4d4d),
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              '\$${_pro.price}',
                                              style: TextStyle(
                                                  color: _pro.hasOldPrice
                                                      ? Color(0xffFE8206)
                                                      : Color(0xffA9A9A9),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                            _pro.hasOldPrice
                                                ? Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    child: Text(
                                                      '\$${_pro.oldPrice}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xffA9A9A9),
                                                          fontSize: 11,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                    ),
                                                  )
                                                : SizedBox.shrink()
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                                fontSize: 10,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Color(0xff4D4D4D)
                                                    .withOpacity(0.5),
                                                fontFamily:
                                                    'DIN Alternate Bold'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            }),
                        Center(
                          child: _loading2 && !_ended
                              ? Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: CircularProgressIndicator(),
                                )
                              : SizedBox.shrink(),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(-1.2, -0.5),
                        blurRadius: 3.8)
                  ]),
              child: SafeArea(
                bottom: true,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  child: _processing
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoActivityIndicator(),
                        )
                      : Row(
                          children: <Widget>[
                            InkWell(
                              onTap: _goToCart,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: Stack(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Image.asset("assets/cart_.png",
                                          height: 26, width: 26),
                                    ),
                                    Positioned(
                                      top: 2,
                                      left: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(1.8),
                                        child: Center(
                                          child: Text(
                                            "${widget.user()?.cartCount ?? 0}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8.5),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                child: InkWell(
                                  onTap: () async {
                                    if (widget.user() == null) {
                                      platform.invokeMethod("toast",
                                          "Not signed in, sign in to continue");
                                      User user = await awaitUser();
                                      if (widget.callback != null) {
                                        widget.callback(user);
                                      }
                                      if (user == null) {
                                        return;
                                      }
                                      setState(() {});
                                    }

                                    if (hasFavorite) {
                                      setState(() {
                                        _list.removeWhere(
                                            (f) => f.itemId == product.itemId);
                                      });
                                      platform.invokeMethod("toast",
                                          "Product removed from favorites");
                                      saveFavoriteList(_list);
                                    } else {
                                      setState(() {
                                        _list.add(product);
                                        saveFavorite(product);
                                      });
                                      platform.invokeMethod("toast",
                                          "Product added to favorites");
                                    }
                                  },
                                  child: hasFavorite
                                      ? Icon(
                                          Icons.favorite,
                                          color: Color(0xffffe707),
                                          size: 25,
                                        )
                                      : Image.asset(
                                          "assets/favourite.png",
                                          height: 32,
                                          width: 32,
                                        ),
                                )),
                            InkWell(
                              child: Container(
                                child: Text(
                                  "Add To Cart",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xff272626)),
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0xffffe707).withOpacity(0.2),
                                    border: Border.all(
                                        color: Color(0xffffe707), width: 1.5),
                                    borderRadius: BorderRadius.circular(5)),
                                padding: EdgeInsets.all(7),
                                margin: EdgeInsets.symmetric(horizontal: 6),
                              ),
                              onTap: () async {
                                openCart();
                              },
                            ),
                            Expanded(
                                child: Container(
                              height: 32,
                              child: RaisedButton(
                                elevation: 0.0,
                                child: Text(
                                  "Buy It Now",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                onPressed: () {
                                  openCart(continueToCart: true);
                                },
                                color: Color(0xffffe707),
                                padding: EdgeInsets.all(0),
                              ),
                            ))
                          ],
                        ),
                ),
              ),
            ),
          );
  }
}

class DescState extends StatefulWidget {
  final Product product;
  final int value;
  final bool continueToCart;
  final String size;
  final List<Sku> skus;
  final List<Option> options;
  final String joiner;
  final void Function(int value,String img, String size, double price) onAdd;

  const DescState(
      {Key key,
      @required this.product,
      this.onAdd,
      this.value: 1,
      @required this.skus,
      this.size,
      this.continueToCart: false,
      @required this.options,
      this.joiner: ";"})
      : super(key: key);

  @override
  _DescStateState createState() => _DescStateState();
}

class _DescStateState extends State<DescState> with SuperBase {
  int _value = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('=-=-=-=-==-=-=-=-=');
    widget.options.map((e) => print(e));

    _value = widget.value;
  }

  void showImage() {
    showGeneralDialog(
        context: context,
        barrierColor: Colors.black12.withOpacity(0.6),
        // background color
        barrierDismissible: true,
        // should dialog be dismissed when tapped outside
        barrierLabel: "Dialog",
        // label for barrier
        transitionDuration: Duration(milliseconds: 400),
        // how long it takes to popup dialog after button click
        pageBuilder: (_, __, ___) {
          return Center(
            child: FadeInImage(
                image: CachedNetworkImageProvider(img),
                placeholder: defLoader,
                fit: BoxFit.contain),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          var wasCompleted = false;
          if (animation.status == AnimationStatus.completed) {
            wasCompleted = true;
          }

          if (wasCompleted) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          } else {
            return SlideTransition(
              position: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ).drive(Tween<Offset>(begin: Offset(0, -1.0), end: Offset.zero)),
              child: child,
            );
          }
        });
  }

  Iterable<Sku> get iterable =>
      widget.skus.where((element) => widget.options.every(
          (op) => element.list.any((sub) => sub.description == op.selected)));

  Iterable<Sku> imgIterable(SubOption option) =>
      widget.skus.where((element) => element.list.any(
          (sub) => sub.description == option.optiionSpecies && element.hasImg));


  bool hasImgIterable(SubOption option) => imgIterable(option).isNotEmpty;

  bool hasImgIterables(List<SubOption> option,SubOption _option) => "" == option.fold<String>(getImgIterable(_option), (previousValue, element) => previousValue != getImgIterable(element) ? "" : getImgIterable(element) );

  String getImgIterable(SubOption option) =>
      imgIterable(option).fold("", (previousValue, element) => element.image);

  double get price => iterable.isEmpty
      ? widget.product.price
      : iterable.fold(0.0, (previousValue, element) => 0.0 + element.price);

  String get _img =>
      iterable.fold("", (previousValue, element) => element.image);

  String get img => _img == null || _img.isEmpty || iterable.isEmpty
      ? widget.product.url
      : _img;

  int get count => iterable.isEmpty
      ? widget.product.count
      : iterable.fold(0, (previousValue, element) => element.count);

  Widget getText(SubOption f, Option fx) => Center(
        child: Text(
          '${f.optiionSpecies}',
          style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight:
                  fx.selected == f.optiionSpecies ? FontWeight.w800 : null),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(10).copyWith(top: 14),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: showImage,
                    child: FadeInImage(
                        height: 70,
                        width: 70,
                        image: CachedNetworkImageProvider(img),
                        placeholder: defLoader,
                        fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "\$$price",
                        style: TextStyle(
                            color: Color(0xffFE8206),
                            fontSize: 17,
                            fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Stock : $count",
                        style: TextStyle(
                            color: Color(0xff999999).withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                          widget.options
                              .map((f) =>
                                  '${f.categoryName} : ${f.selected ?? '---'}')
                              .join("   "),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0xff999999).withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
                GestureDetector(
                    child: Icon(Icons.close, color: Colors.grey.shade400),
                    onTap: () => Navigator.pop(context))
              ],
            ),
            SizedBox(height: 15),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.options
                  .map((fx) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text("${fx.categoryName}",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            RichText(
                                text: TextSpan(
                                    children: fx.list
                                        .map((f) => WidgetSpan(
                                                child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8),
                                                  constraints: BoxConstraints(
                                                      minWidth: 35),
                                                  margin: EdgeInsets.only(
                                                      right: 7, bottom: 7),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      color: fx.selected ==
                                                              f.optiionSpecies
                                                          ? color
                                                          : Colors.transparent,
                                                      border: Border.all(
                                                          width: 1,
                                                          color: fx.selected ==
                                                                  f
                                                                      .optiionSpecies
                                                              ? color
                                                              : Colors.grey
                                                                  .shade500)),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        fx.selected =
                                                            f.optiionSpecies;

                                                        if (count < _value)
                                                          _value = count;
                                                      });
                                                    },
                                                    child: hasImgIterable(f) && (hasImgIterables(fx.list,f) || fx.list.length == 1)
                                                        ? Row(children: [
                                                            FadeInImage(
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  defLoader,
                                                              image: CachedNetworkImageProvider(
                                                                  getImgIterable(
                                                                      f)),
                                                              height: 20,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          4.0),
                                                              child: getText(
                                                                  f, fx),
                                                            )
                                                          ])
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        2),
                                                            child:
                                                                getText(f, fx),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            )))
                                        .toList())),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Text("PCS.", style: TextStyle()),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 1.5),
                      borderRadius: BorderRadius.circular(3)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        child: Container(
                          color: Colors.grey.shade300,
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          child: new Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () => setState(() {
                          _value -= _value > 1 ? 1 : 0;
                        }),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '$_value',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          color: Colors.grey.shade300,
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          child: new Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            _value += _value <= count ? 1 : 0;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  if (widget.options.any((f) => f.selected == null)) {
                    platform.invokeMethod("toast", "Select descriptions above");
                    return;
                  }
                  if (count <= 0) {
                    platform.invokeMethod("toast", "Out of Stock");
                    return;
                  }
                  if (_value <= 0) {
                    platform.invokeMethod("toast", "Invalid quantity");
                    return;
                  }
                  if (count < _value) {
                    platform.invokeMethod("toast", "Quantity not available");
                    return;
                  }
                  if (widget.onAdd != null) {
                    widget.onAdd(
                        _value,
                        img,
                        widget.options
                            .map((f) => f.selected)
                            .join(widget.joiner),
                        price);
                  }
                },
                child: Text(
                  widget.continueToCart ? "Buy It Now" : "Add to cart",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                elevation: 0.0,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
