import 'dart:async';
import 'dart:convert';

import 'package:afri_shop/Json/Category.dart';
import 'package:afri_shop/Json/Post.dart';
import 'package:afri_shop/Json/Poster.dart';
import 'package:afri_shop/Json/SubSubCategory.dart';
import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/Json/slide.dart';
import 'package:afri_shop/brands_list.dart';
import 'package:afri_shop/crawl_screen.dart';
import 'package:afri_shop/discover_description.dart';
import 'package:afri_shop/inside_category.dart';
import 'package:afri_shop/search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/Partial/TouchableOpacity.dart';
import 'package:afri_shop/description.dart';
import 'package:afri_shop/old_category.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Json/Brand.dart';
import '../SuperBase.dart';
import '../cart_page.dart';
import '../life_cycle.dart';

class SecondHomepage extends StatefulWidget {
  final GlobalKey<CartScreenState> cartState;
  final User Function() user;
  final void Function(User user) callback;

  const SecondHomepage(
      {Key key,
      @required this.cartState,
      @required this.user,
      @required this.callback})
      : super(key: key);

  @override
  SecondHomepageState createState() => SecondHomepageState();
}

class SecondHomepageState extends State<SecondHomepage> with SuperBase {
  Widget _brand(String title) {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("#", style: TextStyle(fontSize: 22, color: Color(0xfffbd858))),
          Text(
            title,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff4d4d4d)),
          ),
          Text("#", style: TextStyle(fontSize: 22, color: Color(0xfffbd858))),
        ],
      ),
    );
  }

  var _control = new GlobalKey<RefreshIndicatorState>();
  var focusNode = new FocusNode();

  List<Product> _items = [];
  List<String> _urls = [];

  int max;
  int current = 0;
  bool _loading = false;
  ScrollController _controller = new ScrollController();


  Future<void> showNewCouponDialog({bool show: false}) async {
    if (widget.user() == null) {
      _showMyDialog();
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog(
      context: context,
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: Center(
          // Aligns the container to center
          child: Container(
            // A simplified version of dialog.
            width: 300.0,
            height: 456.0,
            child: Column(
              children: [
                Container(
                  width: 300.0,
                  height: 240.0,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 140,
                        constraints: BoxConstraints(
                            minHeight: 240, minWidth: double.infinity),
                        margin: EdgeInsets.only(top: 130),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 30),
                            Text(
                              "Welcome to Afrishop!",
                              style: Theme.of(context)
                                  .textTheme
                                  .title
                                  .copyWith(fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Congratulations! You got \$100 coupon",
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/log_bg.png"),
                                fit: BoxFit.fitWidth)),
                        height: 150,
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 120,
                            width: 300.0,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                    AssetImage("assets/coupons-layer.png"),
                                    fit: BoxFit.fitWidth)),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "NEW REGISTERED USER",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'SF UI Display',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800),
                                              ),
                                              Text(
                                                "valide date. A Week",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    height: 1.6,
                                                    fontWeight: FontWeight.normal,
                                                    fontFamily: 'SF UI Display'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )),
                                Container(
                                  padding:
                                  EdgeInsets.all(10).copyWith(left: 65),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("\$100.0",
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'SF UI Display')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Container(
                    // width: 300.0,
                      height: 37,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 1.0),
                        child: RaisedButton(
                          onPressed: () => Navigator.pop(context),
                          color: color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          elevation: 0.0,
                          child: Text(
                            "OK",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      )),
                )
              ],
            ),
            // ),
          ),
        ),
      ),
    );
  }

  void goToTop() {
    _controller.animateTo(0.0, duration: Duration(milliseconds: 600), curve: Curves.easeIn);
  }

  Widget _row(Category category) {
    final style = TextStyle(
        color: Color(0xffe8c854),
        fontSize: 14.1,
        fontStyle: FontStyle.italic,
        fontFamily: 'FuturaBT-MediumItalic');
    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => OldCategory(
                  list: [category],
                  user: widget.user,
                  callback: widget.callback,
                  title: category?.name,
                )));
        widget.cartState.currentState?.refresh();
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(category.url)
          )
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this._loadBrands();
      navLink(show: true);
      _control.currentState?.show(atTop: true);
    });

    focusNode.addListener(() async {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        await Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => SearchScreen(
                      user: widget.user,
                      callback: widget.callback,
                    )));
        widget.cartState?.currentState?.refresh();
      }
    });

    WidgetsBinding.instance
        .addObserver(new LifecycleEventHandler(resumeCallBack: () {
      navLink();
      return Future.value();
    }));

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _refreshList(inc: true);
        //print("reached bottom ($current)");
      }
    });
  }

  void saveNetwork(String sharer) {
    this.ajax(
        url: "discover/networking/saveNetwork2",
        authKey: widget.user()?.token,
        server: true,
        method: "POST",
        data: FormData.fromMap(
            {"code": sharer, "network": widget.user()?.id}),
        onValue: (s, v) {
          print(s);
        },
        error: (s, v) {
          print(s);
        });
  }

  var _selected = false;
  var link;

  Future<void> navLink({bool show:false}) async {
    link = await platform.invokeMethod("deep-link");
    if (link != null) {
      showMd();

      var uri = Uri.dataFromString(link);
      var parameter = uri.queryParameters['code'];
      var productId = uri.queryParameters['id'];

      if ( productId != null) {
        _selected = false;
        return this.ajax(
            url:
                "itemStation/queryItemSku?itemId=$productId",
            error: (s,v)=>
            link = null,
            onValue: (source, url) async {
              var map = json.decode(source);
              if (map != null && map['data'] != null) {
                var data = map['data'];
                var pro = Product.fromJson(data['itemInfo'],
                    options: data['optionList'],det: data['itemDetail'],params: data['itemParam'],desc: data['itemDesc']);
                if( !_selected ) {
                  _selected = true;
                  link = null;
                  await Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) =>
                              Description(
                                  callback: widget.callback,
                                  user: widget.user,
                                  fromCode: parameter,
                                  product: pro)));
                  widget.cartState?.currentState?.refresh();
                }
              }
            });
      }
      return this.ajax(
          url: replacedUrl('$link'),
          absolutePath: true,
          server: true,
          error: (s,v)=> link = null,
          onValue: (source, url) async {
            var map = json.decode(source);
            if (map != null) {
              var post = Post.fromJson(map);
              post.sharer = parameter;
              if (widget.user() != null && post.sharer != null) {
                saveNetwork(post.sharer);
              }
              _pop = false;
              link = null;
              await Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => DiscoverDescription(
                          post: post,
                          user: widget.user,
                          fromLink: true,
                          likePost: (x) {},
                          delete: () {},
                          cartState: widget.cartState,
                          callback: widget.callback)));
              widget.cartState?.currentState?.refresh();
            }
          });
    }
    else if(show){
      showMd();
      Timer(Duration(seconds: 5), () => this.canPop());
    }
    return Future.value();
  }

  List<Poster> _posters = [];

  Future<void> _loadBrands() {
    return this.ajax(
        url: "home/middleColumn",
        auth: false,
        onValue: (source, url) {
          var data = json.decode(source);
          Iterable dx = data['data'];
          if( dx != null) {
            setState(() {
              for(var x in dx){
                if( x['postersList'] != null ){
                  Iterable _map2 = x['postersList'];
                  _posters = _map2.map((f) => Poster.fromJson(f)).toList();
                }
                if( x['storeStationList'] != null ){
                  Iterable _map = x['storeStationList'];
                  _brands = _map.map((f) => Brand.fromJson(f)).toList();
                }
                if( x['classificationList'] != null ){
                  Iterable _map0 = x['classificationList'];
                  _categories = _map0.map((f) => Category.fromJson(f)).toList();
                }
              }
            });
          }
        },
        error: (s, v) {
          print(s);
        });
  }

  List<Category> _categories = [];

//  Future<void> _loadCategories() {
//    return this.ajax(
//        url: "goodsType/getGoodsTypeList",
//        onValue: (source, url) {
//          var data = json.decode(source);
//          Iterable _map = data['data'];
//          setState(() {
//            _categories = _map.map((f) => Category.fromJson(f)).toList();
//          });
//        });
//  }

  bool _pop = false;

  void canPop() {
    if (_pop && link == null) {
      Navigator.pop(context);
      _pop = false;
    }
  }

  void showMd() async {
    if (_pop) return;
    _pop = true;
    await showGeneralDialog(
        transitionDuration: Duration(milliseconds: 20),
        barrierDismissible: false,
        context: context,
        barrierColor: Colors.black12,
        pageBuilder: (context, _, __) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            content: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(7)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          );
        });
    _pop = false;
  }



  void handleNavigation(Poster poster) async {
    print(poster.posterType);
    print(poster.linkUrl);
    switch (poster.posterType) {
      case 0:
        {
          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => CrawlScreen(
                    url: poster.linkUrl,
                    user: widget.user,
                    callback: widget.callback,
                    title: poster.title,
                  )));
          break;
        }
//      case 1:{
//        await Navigator.push(
//            context,
//            CupertinoPageRoute(
//                builder: (context) => InsideCategory(
//                    category: SubSubCategory(
//                        poster.linkUrl, poster.title, poster.poster),
//                    user: widget.user,
//                    prefix: "goodsType/getItemStationList?categoryId",
//                    callback: widget.callback)));
//        break;
//      }
//      case 1:{
//        var list = poster.linkUrl.split(",");
//
//        if( list.isEmpty ) break;
//
//        var category = new Category(list.first,poster.title,poster.poster);
//        await Navigator.of(context).push(CupertinoPageRoute(
//            builder: (context) => OldCategory(
//              list: [category],
//              user: widget.user,
//              callback: widget.callback,
//              title: poster.title,
//            )));
//        break;
//      }
      case 3:
      case 1:
        {
          String prefix, three;
          if (poster.posterType == 3) {
            three = poster.linkUrl;
            prefix = "itemStation/queryItemsByLabel?label";
          } else {
            var list = poster.linkUrl.split(",");

            if (list.length < 3) break;

            three = list[2].trim();
            prefix = "itemStation/queryItemsByTypeThree?typeThreeId";

            if (three.isEmpty || three == "null") {
              three = list[1].trim();
              prefix = "itemStation/queryItemsByTypeTwo?typeTwoId";
            }

            if (three.isEmpty || three == "null") {
              three = list[0].trim();
              prefix = "goodsType/getItemStationList?categoryId";
            }
          }

          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => InsideCategory(
                      category:
                      SubSubCategory(three, poster.title, poster.poster),
                      user: widget.user,
                      prefix: prefix,
                      callback: widget.callback)));
          break;
        }
      case 2:
        {
          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => Description(
                      product: null,
                      user: widget.user,
                      itemId: poster.linkUrl,
                      callback: widget.callback)));
          break;
        }
    }

    widget.cartState.currentState?.refresh();
  }


  Future<void> _loadItems({bool inc: false}) {
    if (max != null && current > max) {
      return Future.value();
    }
    setState(() {
      _loading = true;
    });
    return this.ajax(
        url: "itemStation/queryAll?pageNum=$current&pageSize=12",
        auth: false,
        onValue: (source, url) {
          if (_urls.contains(url)) {
            return;
          }
          current += inc ? 1 : 0;
          _urls.add(url);
          Map<String, dynamic> _data = json.decode(source)['data'];
          Iterable _map = _data['content'];
          max = _data['totalPages'];
          setState(() {
            var lst = _map.map((f) => Product.fromJson(f)).toList();
            _items..removeWhere((element) => lst.any((x) => x.itemId == element.itemId))..addAll(lst);
          });
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
        },
        error: (s, v) {});
  }

  List<Brand> _brands = [];

  Future<void> _refreshList({bool inc: true}) async {
    _carouselState.currentState?._loadImages();
    await _loadBrands();
    //await _loadCategories();
    await _loadItems(inc: inc);
    canPop();
    return Future.value();
  }

  var _carouselState = new GlobalKey<__CarouselState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var _len = _items.length + 13;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          RefreshIndicator(
              key: _control,
              displacement: 80,
              child: Scrollbar(
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: _controller,
                      itemCount: _len,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: _Carousel(
                              key: _carouselState,
                                user: widget.user, callback: widget.callback,cartState: widget.cartState),
                          );
                        }

                        if (index == 1) {
                          return GridView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 3,
                                    mainAxisSpacing: 17,
                                    childAspectRatio: 3.5),
                            children:
                                List.generate(_categories.length, (index) {
                              return _row(_categories[index]);
                            }),
                          );
                        }

                        if (index == 2) {
                          return Container();
                        }

                        if (index == 3) {
                          return Container();
                        }

                        if (index == 4) {
                          return Container();
                        }

                        if (index == 5) {
                          return Container();
                        }

                        if (index == 6) {
                          return Container(
                            color: Colors.white,
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Column(
                              children: _posters
                                  .map((f) => GestureDetector(
                                        onTap: () async {
                                          handleNavigation(f);
                                        },
                                        child: FadeInImage(
                                          image: CachedNetworkImageProvider(
                                              f.poster),
                                          fit: BoxFit.cover,
                                          placeholder: defLoader,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          );
                        }

                        if (index == 7) {
                          return Container();
                        }

                        if (index == 8) {
                          return Container();
                        }

                        if (index == 9) {
                          return _brand("OTHER BRANDS");
                        }

                        if (index == 10) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(0xffFBD85A),
                            ),
                            child: Column(
                              children: <Widget>[
                                GridView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      _brands.length > 4 ? 4 : _brands.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 2.63 / 4,
                                          mainAxisSpacing: 0.0,
                                          crossAxisSpacing: 0),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () async {
                                        await Navigator.of(context).push(
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    CrawlScreen(
                                                      url: _brands[index]
                                                          .storeUrl,
                                                      user: widget.user,
                                                      callback: widget.callback,
                                                      title: _brands[index]
                                                          .storeName,
                                                    )));
                                        widget.cartState.currentState?.refresh();
                                      },
                                      child: Container(
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                              color: Color(0xffFBD85A)),
                                          child: FadeInImage(
                                            placeholder: defLoader,
                                            image: CachedNetworkImageProvider(
                                                _brands[index].itemImg1),
                                            fit: BoxFit.cover,
                                          )),
                                    );
                                  },
                                ),
                                TouchableOpacity(
                                    onTap: () async {
                                      await Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => BrandList(
                                                    user: widget.user,
                                                  )));

                                      widget.cartState.currentState?.refresh();
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 20),
                                      child: Center(
                                        child: Text("VIEW MORE"),
                                      ),
                                    ))
                              ],
                            ),
                          );
                        }

                        if (index == 11) {
                          return _brand("FOR YOU");
                        }

                        if (index == _len - 1) {
                          return Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 40, horizontal: 10),
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(),
                                )),
                          );
                        }

                        index = index - 12;

                        if (_items.length ~/ 3 < index) return Container();

                        return Row(
                          children: <Widget>[
                            Expanded(
                                child: _gridItem(
                                    "FASHION PLEATED TOP FRIEND",
                                    "https://images-na.ssl-images-amazon.com/images/I/51iYRa329DL._SL1024_.jpg",
                                    200,
                                    index: index,
                                    count: 0)),
                            Expanded(
                                child: _gridItem(
                                    "FASHION PLEATED TOP FRIEND",
                                    "https://s7d5.scene7.com/is/image/UrbanOutfitters/55958102_069_b?\$medium\$&qlt=80&fit=constrain",
                                    178,
                                    index: index,
                                    count: 1)),
                            Expanded(
                                child: _gridItem(
                                    "FASHION PLEATED TOP FRIEND",
                                    "https://lp2.hm.com/hmgoepprod?set=width[800],quality[80],options[limit]&source=url[https://www2.hm.com/content/dam/campaign-ladies-s01/februari-2020/1301a/1301-3x2-weekend-style-forerver.jpg]&scale=width[global.width],height[15000],options[global.options]&sink=format[jpg],quality[global.quality]",
                                    187,
                                    index: index,
                                    count: 2)),
                          ],
                        );
                      })),
              onRefresh: () {
                _refreshList();
                return Future.value();
              }),
          Positioned(
              child: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            width: double.infinity,
            height: 52,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/afrishop_logo@3x.png",
                    width: 75,
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    focusNode: focusNode,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0),
                        hintText: "I'm shopping for...",
                        hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            fontFamily: 'FuturaBT-MediumItalic',
                            color: Colors.grey),
                        filled: true,
                        focusColor: Colors.grey,
                        hoverColor: Colors.grey,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 16,
                              width: 16,
                              child: Image.asset("assets/search_app.png",
                                  height: 16, fit: BoxFit.fitHeight)),
                        ),
                        fillColor: Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(3))),
                  ),
                ))
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _gridItem(String title, String url, double price,
      {int count: 0, int index: 0}) {
    index = (index * 3) + count;
    return _items.length <= index
        ? Container()
        : TouchableOpacity(
            padding: EdgeInsets.all(5),
            onTap: () async {
              var _pro = _items[index];
              await Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => Description(
                        product: _pro,
                        user: widget.user,
                        callback: widget.callback,
                      )));
              widget.cartState.currentState?.refresh();
            },
             child: Container(
              height: 170,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Container(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: FadeInImage(
                      image: CachedNetworkImageProvider('${_items[index].url}'),
                      fit: BoxFit.cover,
                      placeholder: defLoader,
                    ),
                  )),
                  SizedBox(height: 5),
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '${_items[index].title}',
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
                          '\$${_items[index].price}',
                          style: TextStyle(
                              color: _items[index].hasOldPrice
                                  ? Color(0xffFE8206)
                                  : Color(0xffA9A9A9),
                              fontSize: 13,
                              fontWeight: FontWeight.w900),
                        ),
                        _items[index].hasOldPrice
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  '\$${_items[index].oldPrice}',
                                  style: TextStyle(
                                      color: Color(0xffA9A9A9),
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              )
                            : SizedBox.shrink()
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        '',
                        style: TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xff4D4D4D).withOpacity(0.5),
                            fontFamily: 'DIN Alternate Bold'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ))
                ],
              ),
            ),
          );
  }
}

class _Carousel extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;
  final GlobalKey<CartScreenState> cartState;

  const _Carousel({Key key, @required this.user, @required this.callback,@required this.cartState})
      : super(key: key);

  @override
  __CarouselState createState() => __CarouselState();
}

class __CarouselState extends State<_Carousel> with SuperBase {
  List<Slide> images = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this._loadImages());
  }

  void _loadImages() {
    this.ajax(
        url: "startPage/img?version=$version",
        onValue: (source, url) {
          print(url);
          Iterable iterable = json.decode(source)['data'];
          setState(() {
            images = iterable.map((f) => Slide.fromJson(f)).toList();
          });
        });
  }

  int _current = 0;


  void handleNavigation(Slide slide) async {
    print(slide.imgType);
    print(slide.linkUrl);
    switch (slide.imgType) {
      case 0:
        {
          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => CrawlScreen(
                    url: slide.linkUrl,
                    user: widget.user,
                    callback: widget.callback,
                    title: slide.imgName,
                  )));
          break;
        }

//      case 1:{
//        var list = slide.linkUrl.split(",");
//
//        if( list.isEmpty ) break;
//
//        var category = new Category(list.first,slide.imgName,slide.image);
//        await Navigator.of(context).push(CupertinoPageRoute(
//            builder: (context) => OldCategory(
//              list: [category],
//              user: widget.user,
//              callback: widget.callback,
//              title: slide.imgName,
//            )));
//        break;
//      }
      case 3:
      case 1:
        {
          String prefix, three;
          if (slide.imgType == 3) {
            three = slide.linkUrl;
            prefix = "itemStation/queryItemsByLabel?label";
          } else {
            var list = slide.linkUrl.split(",");

            if (list.length < 3) break;

            three = list[2].trim();
            prefix = "itemStation/queryItemsByTypeThree?typeThreeId";

            if (three.isEmpty || three == "null") {
              three = list[1].trim();
              prefix = "itemStation/queryItemsByTypeTwo?typeTwoId";
            }

            if (three.isEmpty || three == "null") {
              three = list[0].trim();
              prefix = "goodsType/getItemStationList?categoryId";
            }
          }

          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => InsideCategory(
                      category:
                      SubSubCategory(three, slide.imgName, slide.image),
                      user: widget.user,
                      prefix: prefix,
                      callback: widget.callback)));
          break;
        }
      case 2:
        {
          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => Description(
                      product: null,
                      itemId: slide.linkUrl,
                      user: widget.user,
                      callback: widget.callback)));
          break;
        }
    }

    widget.cartState.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return images.isEmpty
        ? Image(
            image: defLoader,
            fit: BoxFit.cover,
            height: 460,
          )
        : Stack(children: [
            CarouselSlider.builder(
              height: 460,
              autoPlayInterval: Duration(seconds: 3),
              pauseAutoPlayOnTouch: Duration(minutes: 10),
              itemBuilder: (context, i) {
                var sl = images[i];
                return GestureDetector(
                  onTap: ()=>this.handleNavigation(sl),
                  child: Container(
                    width: double.infinity,
                    child: FadeInImage(
                      image: CachedNetworkImageProvider(sl.image ?? ''),
                      placeholder: defLoader,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              itemCount: images.length,
              autoPlay: true,
              aspectRatio: 2.0,
              viewportFraction: 1.1,
              onPageChanged: (index) {
                setState(() {
                  _current = index;
                });
              },
            ),
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      width: 10.0,
                      height: 2.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                          color: _current == index
                              ? color
                              : Color.fromRGBO(0, 0, 0, 0.4)),
                    );
                  }),
                ))
          ]);
  }
}