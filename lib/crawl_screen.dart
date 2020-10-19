import 'dart:async';
import 'dart:convert';
import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/Json/Sku.dart';
import 'package:afri_shop/Json/crawl_sku.dart';
import 'package:afri_shop/Json/option.dart';
import 'package:afri_shop/cart_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'Json/User.dart';
import 'SuperBase.dart';
import 'description.dart';
import 'Authorization.dart';
import 'new_account_screen.dart';

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

class _Resolver extends StatefulWidget {
  final List<CrawlSku> list;
  final Map<String,dynamic> cart;
  final User Function() user;
  final void Function(User user) callback;

  const _Resolver({Key key, @required this.list,@required this.cart,@required this.user,@required this.callback}) : super(key: key);

  @override
  __ResolverState createState() => __ResolverState();
}

class __ResolverState extends State<_Resolver> with SuperBase {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
  }


  CrawlSku _selected;
  int _value = 1;

  bool _sending = false;

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
        child:
        Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
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
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              body: Center(
                                child: FadeInImage(
                                    image: CachedNetworkImageProvider(
                                        widget.cart['itemImg']??''),
                                    placeholder: defLoader,
                                    fit: BoxFit.contain),
                              ),
                            );
                          },
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
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
                                ).drive(Tween<Offset>(
                                    begin: Offset(0, -1.0), end: Offset.zero)),
                                child: child,
                              );
                            }
                          });
                    },
                    child: FadeInImage(
                        height: 70,
                        width: 70,
                        image: CachedNetworkImageProvider(widget.cart['itemImg']??''),
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
                            "\$${widget.cart['itemPrice']??'0.0'}",
                            style: TextStyle(
                                color: Color(0xffFE8206),
                                fontSize: 17,
                                fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Stock : ${_selected?.quantity ?? "--"}",
                            style: TextStyle(
                                color: Color(0xff999999).withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(_selected?.skuStr??"",
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
            RichText(
                text: TextSpan(
                    children: widget.list
                        .map((f) => WidgetSpan(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 8),
                              constraints: BoxConstraints(
                                  minWidth: 35),
                              margin: EdgeInsets.only(
                                  right: 7, bottom: 7),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(
                                      2),
                                  color: _selected?.skuStr ==
                                      f.skuStr
                                      ? color
                                      : Colors.transparent,
                                  border: Border.all(
                                      width: 1,
                                      color: _selected?.skuStr ==
                                          f.skuStr
                                          ? color
                                          : Colors.grey
                                          .shade500)),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selected = f;
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    '${f.skuStr}',
                                    style: TextStyle(
                                        color: Colors
                                            .grey.shade500,
                                        fontWeight: _selected?.skuStr ==
                                            f.skuStr
                                            ? FontWeight.w800
                                            : null),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )))
                        .toList())),

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
                            _value += _value <= (_selected?.quantity ?? 0) ? 1 : 0;
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
              child: _sending ? CupertinoActivityIndicator() : RaisedButton(
                onPressed: () {
                  if (_selected == null) {
                    platform.invokeMethod("toast", "Select descriptions above");
                    return;
                  }


                  if ((_selected.quantity ?? 0) <= 0) {
                    platform.invokeMethod("toast", "Out of Stock");
                    return;
                  }

                },
                child: Text(
                  "Add to cart",
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

class CrawlScreen extends StatefulWidget {
  final String url;
  final String title;
  final User Function() user;
  final void Function(User user) callback;

  const CrawlScreen(
      {Key key,
        @required this.url,
        @required this.callback,
        @required this.user,
        this.title})
      : super(key: key);

  @override
  _CrawlScreenState createState() => _CrawlScreenState();
}

class _CrawlScreenState extends State<CrawlScreen> with SuperBase {
  String webUrl;
  double progress = 0;
  bool _loading = false;
  bool _hasWeb = true;
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webUrl = widget.url;

    flutterWebviewPlugin.onUrlChanged.listen((url) {
      webUrl = url;
      loadCrawl(url);
    });
  }


  Future<User> awaitUser() async {
    User user = await Navigator.of(context).push<User>(CupertinoPageRoute(
        builder: (context) => AccountScreen(
          canPop: true, user: widget.user, callback: widget.callback,cartState: null,)));
    return user;
  }

  void addToCart() async {
    if( _cart == null ) {
      await loadCrawl(webUrl);
    }

    if( _cart == null ) return;

    setState(() {
      _hasWeb = false;
    });
    var user = widget.user();
    if (user == null) {
      platform.invokeMethod("toast", "Not signed in, sign in to continue");
      user = await awaitUser();
      if (widget.callback != null) {
        widget.callback(user);
      }
      if (user == null) {
        setState(() {
          _hasWeb = true;
        });
        return;
      }
      setState(() {});
    }
    print(json.encode(_cart));



    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => DescState(options: list,skus: skus,product: product,onAdd: sendCart,value: 1,joiner: ";",));




//    await showModalBottomSheet(
//        context: context,
//        backgroundColor: Colors.transparent,
//        isScrollControlled: true,
//        builder: (context) => _Resolver(cart: _cart,list: _skuList,callback: widget.callback,user: widget.user,));

    setState(() {
      _hasWeb = true;
    });
  }


  void sendCart(count,str,price){


    var map = {
      "itemSku":str,
      "itemPrice":price,
      "itemNum":count,
    };

    map.addAll(_cart);

    print(map);

    Navigator.pop(context);


    setState(() {
      _loading =true;
    });

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
          platform.invokeMethod("toast", "Product added to cart");
        } else {
          setState(() {

          });
          // platform.invokeMethod("toast", "${map['message']}");
        }
        print(source);
      },
      onEnd: () {
        setState(() {
          _loading = false;
        });
      },
      error: (source, url) {
        setState(() {
          _loading = false;
        });
        //platform.invokeMethod("toast", "$source");
      },
    );
  }

  Map<String,dynamic> _cart;
  Product product;

  List<Option> list = [];
  List<Sku> skus = [];

  Future<void> loadCrawl(String url) {
    print(url);
    setState(() {
      _loading = true;
    });
    return this.ajax(
        url: "spider/item/detail",
        method: "POST",
        map: {"targetUrl": url},
        server: true,
        onValue: (source, url) {
          print(url);
          var map = json.decode(source);
          var data = map['data'];
          print(source);
          if( data != null ) {
            print("prop set");
            Map<String, dynamic> gt = data['itemInfo'];
            List priceList = data['originalPriceList'] ?? [];
            if (priceList == null || priceList.isEmpty) {
              //platform.invokeMethod("toast", map['message']);
              return;
            }


            skus.clear();
            list.clear();
            _cart = null;
            product = null;


            gt.putIfAbsent("itemPrice", () => double.tryParse(data['price']));
            gt.putIfAbsent("itemCount", () => data['sellableQuantity'] ?? 0);
            gt.putIfAbsent("itemImg", () => gt['pic']);
            gt.putIfAbsent("itemTitle", () => gt['title']);

            product = Product.fromJson(gt);


            setState(() {
              _cart = gt;
            });
            var sku = (data['dynStock']['productSkuStockList'] as Iterable) ?? [];

            List<SubSku> sbs = [];
            var index = 0;
            sku.forEach((element) {
              (element['skuStr'] as String).split(";").where((element) => element.isNotEmpty).forEach((el) {
                sbs.add(SubSku(el,el));
              });

              double price = index < priceList.length ? double.tryParse(priceList[index]['price']) : 0.0;


              index++;

              skus.add(Sku(price,element['sellableQuantity'],element['skuStr'],sbs));
            });

            var xMap = (data['productPropSet'] as Map<String,dynamic>);
            print(xMap);


            xMap.forEach((key, value) {
              List<SubOption> subs = [];
              var _list = (value as Iterable);

              _list.forEach((el) {
                var prop = el['translate'] ?? el['propName'] ?? "";
                subs.add(SubOption(el['propId'],prop,prop));
              });

              list.add(Option(key,key,subs));
            });


          }

        },
        onEnd: (){
          setState(() {
            _loading =false;
          });
        },
       // error: (s, v) => platform.invokeMethod("toast", s)
    );
  }

  @override
  Widget build(BuildContext context) {
    return _hasWeb ? WebviewScaffold(
      url: webUrl,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:8.0),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: ()async{
                  setState(() {
                    _hasWeb = false;
                  });
                 await Navigator.push(context, CupertinoPageRoute(builder: (context)=>CartScreen(user: widget.user,callback: widget.callback,)));

                  setState(() {
                    _hasWeb = true;
                  });
                  },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 8),
                  child: Image.asset("assets/cart_.png", height: 26, width: 26),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Price"),
                  _cart == null ? Text("\$0.0") : Text("\$${_cart['itemPrice'] ?? 0.0}"),
                ],
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left:8.0),
                    child: _loading ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoActivityIndicator(),
                    ) : RaisedButton(
                      elevation: 0.0,
                      onPressed:addToCart,
                      child: Text("Add to afrishop cart"),
                      color: color,
                    ),
                  ))
            ],
          ),
        ),
      ),
      appBar: appBar,
    ) : Scaffold(
      appBar: appBar,
      body: Center(child: CupertinoActivityIndicator(),),
    );
  }

  Widget get appBar =>AppBar(
    leading: Navigator.canPop(context)
        ? IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.maybePop(context);
        })
        : null,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 40.0),
          child: Image.asset(
            "assets/afrishop_logo@3x.png",
            width: 70,
            fit: BoxFit.fitWidth,
          ),
        ),
        Text(
          widget.title ?? "Webview",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        Spacer(),
        IconButton(icon: Icon(Icons.refresh), onPressed: () {
          flutterWebviewPlugin.reload();
        })
      ],
    ),
  );
}
