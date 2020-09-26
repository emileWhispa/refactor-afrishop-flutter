import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/Partial/TouchableOpacity.dart';
import 'package:afri_shop/category_page.dart';
import 'package:afri_shop/description.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'Json/Brand.dart';
import 'Json/Category.dart';
import 'Json/User.dart';
import 'SuperBase.dart';
import 'cart_page.dart';
import 'old_category.dart';

enum CircleAlignment {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class QuarterCircle extends StatelessWidget {
  final CircleAlignment circleAlignment;
  final Color color;

  const QuarterCircle({
    this.color = Colors.grey,
    this.circleAlignment = CircleAlignment.topLeft,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRect(
        child: CustomPaint(
          painter: QuarterCirclePainter(
            circleAlignment: circleAlignment,
            color: color,
          ),
        ),
      ),
    );
  }
}

class QuarterCirclePainter extends CustomPainter {
  final CircleAlignment circleAlignment;
  final Color color;

  const QuarterCirclePainter({this.circleAlignment, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Gradient gradient = LinearGradient(colors: [
      Color(0xffd8c400),
      Color(0xfffdec4c),
      Color(0xfffdf287),
    ], begin: Alignment.centerLeft, end: Alignment.centerRight);
    final radius = min(size.height, size.width);
    final offset = circleAlignment == CircleAlignment.topLeft
        ? Offset(.0, .0)
        : circleAlignment == CircleAlignment.topRight
            ? Offset(size.width, .0)
            : circleAlignment == CircleAlignment.bottomLeft
                ? Offset(.0, size.height)
                : Offset(size.width, size.height);
    Rect rect = new Rect.fromCircle(
//      center: new Offset(165.0, 55.0),
//      radius: 180.0,
    );
    canvas.drawCircle(
        offset,
        radius,
        Paint()
          ..color = color
          ..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(QuarterCirclePainter oldDelegate) {
    return color == oldDelegate.color &&
        circleAlignment == oldDelegate.circleAlignment;
  }
}

class _Item {
  final String title;
  final String url;
  final double price;
  String itemSku;
  int items = 0;
  int id;
  String itemId;
  bool selected = false;

  _Item(this.price, this.title, this.url);

  _Item.fromJson(Map<String, dynamic> json)
      : title = json['itemName'],
        id = json['id'],
        itemId = json['itemId'],
        itemSku = json['itemSku'],
        price = json['discountPrice'],
        url = json['itemImg'];

  double get total => items * price;

  _Item.fromDb(Map<String, dynamic> json)
      : title = json['title'],
        id = json['id'],
        itemId = json['itemId'],
        items = json['items'],
        price = json['price'],
        url = json['url'];

  void dec() {
    if (items > 1) {
      items--;
    }
  }

  Map<String, dynamic> toMap() => {
        "items": items,
        "title": title,
        "itemId": itemId,
        "price": price,
        "url": url
      };
}

class Choice {
  final String name;
  final String address;

  Choice(this.name, this.address);
}

class ThirdHomepage extends StatefulWidget {
  final GlobalKey<CartScreenState> cartState;
  final User Function() user;
  final void Function(User user) callback;

  const ThirdHomepage(
      {Key key, @required this.cartState, @required this.user, this.callback})
      : super(key: key);

  @override
  ThirdHomepageState createState() => ThirdHomepageState();
}

class ThirdHomepageState extends State<ThirdHomepage> with SuperBase {
  Widget _brand(String title, {Color color: const Color(0xfffbd858)}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("#", style: TextStyle(fontSize: 22, color: color)),
          Text(
            title,
            style: TextStyle(fontSize: 25, color: Color(0xff4d4d4d)),
          ),
          Text("#", style: TextStyle(fontSize: 22, color: color)),
        ],
      ),
    );
  }

  var _control = new GlobalKey<RefreshIndicatorState>();

  List<Product> _products = [];
  List<String> _urls = [];

  User _user;

  void popUser(User user) {
    setState(() {
      _user = user;
    });
  }

  List<_Item> get _list => [
        _Item(30, "Woman in black dress",
            "https://www.urbasm.com/wp-content/uploads/2014/10/Diana-Retegan.jpg"),
        _Item(121, "Woman in black dress",
            "https://d23gkft280ngn0.cloudfront.net/thumb550/2019/11/7/Sherri-Hill-Sherri-Hill-53448-pink-45390.jpg"),
        _Item(67, "Woman in black dress",
            "https://pagani-co-nz.imgix.net/products/jersey-t-shirt-maxi-dress-navywhite-main-63156~1574999306.jpg?w=590&h=960&fit=crop&auto=format&bg=ffffff&s=c15e59309d37a69420f317dd27166841"),
        _Item(31, "Woman in black dress",
            "https://is4.revolveassets.com/images/p4/n/c/AXIS-WD409_V1.jpg"),
        _Item(90, "Woman in black dress",
            "https://s7d1.scene7.com/is/image/BHLDN/50827450_065_a?\$pdpmain\$"),
        _Item(63, "Woman in black dress",
            "https://www.forevernew.com.au/media/wysiwyg/megamenu/_AU_NZ/March_2020/Mega-Nav-01_2.jpg"),
        _Item(21, "Woman in black dress",
            "https://keimag.com.my/image/cache/cache/5001-6000/5302/main/bbf3-PYS_2306-2c-0-1-0-1-1-800x1200.jpg"),
        _Item(45, "Woman in black dress",
            "https://www.theclosetlover.com/sites/files/theclosetlover/productimg/201908/4-dsc05237.jpg"),
        _Item(30, "Woman in black dress",
            "https://photo.venus.com/im/18158145.jpg?preset=dept"),
        _Item(06, "Woman in black dress",
            "https://images.dorothyperkins.com/i/DorothyPerkins/DP07279213_M_1.jpg?\$w700\$&qlt=80"),
        _Item(17.6, "Woman in black dress",
            "https://media.thereformation.com/image/upload/q_auto:eco/c_scale,w_auto:breakpoints_100_1920_9_20:544/v1/prod/media/W1siZiIsIjIwMjAvMDEvMTMvMDAvMDkvNTgvNzQxNDk0MmItZDMxNy00Zjg0LTg0MTMtMGM0Yzk0NWM0MjJiL0NhcnJhd2F5LWRyZXNzLWl2b3J5LmpwZyJdXQ/Carraway-dress-ivory.jpg"),
        _Item(23.2, "Woman in black dress",
            "https://cdn.shopify.com/s/files/1/0412/3817/products/0I2A2081_bc866ac5-e45f-44b5-887e-c3cedb42e9f9_500x.jpg?v=1583300504"),
        _Item(34.78, "Woman in black dress",
            "https://xcdn.next.co.uk/COMMON/Items/Default/Default/Publications/G99/shotview/105/452-274s.jpg"),
        _Item(24.789, "Woman in black dress",
            "https://cdn-images.farfetch-contents.com/emilio-pucci-vahine-print-wrap-dress_14182344_25241451_480.jpg"),
        _Item(45.32, "Woman in black dress",
            "https://media.nastygal.com/i/nastygal/agg88820_red_xl?\$product_image_category_page_horizontal_filters_desktop\$"),
        _Item(21.90, "Woman in black dress",
            "https://s7d5.scene7.com/is/image/Anthropologie/4130647160022_009_b?\$an-category\$&qlt=80&fit=constrain"),
        _Item(82, "Woman in black dress",
            "https://gloimg.zafcdn.com/zaful/pdm-product-pic/Clothing/2016/07/27/goods-first-img/1493770024277473218.JPG"),
        _Item(76, "Woman in black dress",
            "https://cdn-images.farfetch-contents.com/emilio-pucci-heliconia-print-sequin-fringe-mini-dress_14182345_25241532_480.jpg"),
      ];

  int max;
  int current = 0;
  bool _loading = false;
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //this._loadBrands();
      this._loadCategories();
      this._refreshList(inc: true);
    });

    _controller.addListener(() {
      _topKey.currentState?.popColor(_controller.position.pixels);
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _refreshList(inc: true);
      }
    });
  }

  var _topKey = new GlobalKey<__TopStateState>();


  Future<void> _loadBrands() {
    return this.ajax(
        url: "home/middleColumn",
        auth: false,
        onValue: (source, url) {
          var data = json.decode(source);
          Iterable dx = data['data'];
          if( dx != null && dx.length > 2 ) {
            Iterable _map2 = data['data'][1]['postersList'];
            Iterable _map = data['data'][2]['storeStationList'];
            Iterable _map0 = data['data'][0]['classificationList'];
            setState(() {
//              _posters = _map2.map((f) => Poster.fromJson(f)).toList();
//              _brands = _map.map((f) => Brand.fromJson(f)).toList();
              _categories = _map0.map((f) => Category.fromJson(f)).toList();
            });
          }
        },
        error: (s, v) {
          print(s);
        });
  }

  Future<void> _loadCategories() {
    return this.ajax(
        url: "listCategories?page=0&size=100",
        auth: false,
        base2: true,
        onValue: (source, url) {
          Iterable _map = json.decode(source);
          setState(() {
            _categories = _map.map((f) => Category.fromJson2(f)).toList();
          });
        },
        error: (s, v) {
          print(s);
        });
  }

  List<Category> _categories = <Category>[];


  Future<void> _loadItems({bool inc: false}) {
    if (max != null && current > max) {
      return Future.value();
    }
    current += inc ? 1 : 0;
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
          _urls.add(url);
          Map<String, dynamic> _data = json.decode(source);
          Iterable _map = _data['data']['list'];
          max = _data['pages'];
          setState(() {
            _products.addAll(_map.map((f) => Product.fromJson(f)).toList());
          });
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
        },
        error: (s, v) {});
  }
  Widget get _containerX => Container(
        height: 400,
        child: Row(
          children: <Widget>[
            Expanded(
                child: Column(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: CachedNetworkImage(
                        imageUrl:
                            "https://instagram.fkgl2-1.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/p750x750/88276752_499840260642764_7350772599357048630_n.jpg?_nc_ht=instagram.fkgl2-1.fna.fbcdn.net&_nc_cat=108&_nc_ohc=YJkIuN6175YAX-TOp_m&oh=73ab09f82185538fe39d0dba857d03bb&oe=5E9CBF13",
                        fit: BoxFit.cover,
                        width: double.infinity)),
                Expanded(
                    child: CachedNetworkImage(
                        imageUrl:
                            "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/84469624_614160582759889_3703883138521319034_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=101&_nc_ohc=xmQx6_OOSNYAX996J2-&oh=f8327c464a2c53ca9adcb1a8829d65d7&oe=5EB44F1A",
                        fit: BoxFit.cover,
                        width: double.infinity))
              ],
            )),
            //
            Expanded(
                child: Column(
              children: <Widget>[
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl:
                      "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/e35/84332618_3269096726467681_4340622738987114260_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=101&_nc_ohc=r9vwGo9SF9IAX_I_7eq&oh=b905727add5ce6627aac11522acf29f0&oe=5E9DB962",
                  fit: BoxFit.cover,
                  width: double.infinity,
                )),
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl:
                      "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/e35/83199139_644795539628765_840347403361876644_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=105&_nc_ohc=6qgLz5_NBCIAX-3uo9w&oh=cc6a7e59bde4ffa51ccda08aaadae459&oe=5EA92B14",
                  fit: BoxFit.cover,
                  width: double.infinity,
                )),
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl:
                      "https://instagram.fkgl2-1.fna.fbcdn.net/v/t51.2885-15/e15/80889137_479341809671387_4517166186896271078_n.jpg?_nc_ht=instagram.fkgl2-1.fna.fbcdn.net&_nc_cat=111&_nc_ohc=V5Mr734x7t4AX9-YtCH&oh=f25734ae55b54c107b7b63af310c1772&oe=5EA81FE4",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ))
              ],
            ))
          ],
        ),
      );

  List<Brand> _brands = [];

  Future<void> _refreshList({bool inc: false}) {
    _control.currentState?.show(atTop: true);
    //_loadBrands();
    //
    _loadCategories();
    _loadItems(inc: inc);

    return Future.value();
  }

  Widget backCategory() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: <Widget>[
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            children: _categories
                .asMap()
                .map((k, f) => MapEntry(
                    k,
                    InkWell(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => CategoryScreen()));
                        },
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: k + 1 == _categories.length
                                    ? color
                                    : Colors.grey,
                                child: k + 1 == _categories.length
                                    ? Icon(Icons.more_horiz)
                                    : null,
                                backgroundImage: k + 1 == _categories.length
                                    ? null
                                    : CachedNetworkImageProvider(f.url),
                              ),
                              SizedBox(height: 7),
                              Text(
                                f.name,
                                style: TextStyle(fontSize: 12.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ))))
                .values
                .toList(),
          ),
//                                SizedBox(height: 18),
//                                Row(
//                                  children: [
//                                    Choice("Cosmetics", "https://shatelcosmetics.com/wp-content/uploads/2017/06/cosmetic-png-1.png"),
//                                    Choice("Electronics", "https://ksassets.timeincuk.net/wp/uploads/sites/54/2019/03/Xiaomi-Mi-9-front-angled-top-left-1024x683.jpg"),
//                                    Choice("Hair", "https://main-cdn.grabone.co.nz/goimage/fullsize/6c0f1cd498157e4d7352f3600f29c6f90cc9c80b.jpg"),
//                                    Choice("View all", "https://shatelcosmetics.com/wp-content/uploads/2017/06/cosmetic-png-1.png"),
//                                  ]
//                                      .map((f) => Expanded(
//                                              child: GestureDetector(
//                                                onTap: (){
//                                                    Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>CategoryScreen()));
//                                                },
//                                                child: Container(
//                                                  child: Column(
//                                                    children: <Widget>[
//                                                      CircleAvatar(
//                                                        backgroundColor: f.name == "View all" ? color : Colors.grey,
//                                                        radius: 30,
//                                                        backgroundImage: f.name == "View all" ? null : CachedNetworkImageProvider(f.address),
//                                                        child: f.name == "View all"
//                                                            ? Icon(Icons.more_horiz)
//                                                            : null,
//                                                      ),
//                                                      SizedBox(height: 7),
//                                                      Text(
//                                                        f.name,
//                                                        style:
//                                                        TextStyle(fontSize: 12.5),
//                                                        maxLines: 1,
//                                                        overflow:
//                                                        TextOverflow.ellipsis,
//                                                      )
//                                                    ],
//                                                  ),
//                                                ),
//                                              )))
//                                      .toList(),
//                                ),
        ],
      ),
    );
  }

  int _current = 0;

  List<String> get images => [
        "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/90094163_668596227229872_5716959898011183998_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=100&_nc_ohc=reIR9obOxqMAX-vleTp&oh=c9f7bce7a57c4489b669c6152bb46754&oe=5EA0FF58",
        "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/90094163_668596227229872_5716959898011183998_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=100&_nc_ohc=reIR9obOxqMAX-vleTp&oh=c9f7bce7a57c4489b669c6152bb46754&oe=5EA0FF58",
        "https://user-images.githubusercontent.com/1459805/59846820-12672e80-938b-11e9-8fa6-b331b7db331d.png",
        "https://user-images.githubusercontent.com/1459805/59846818-12672e80-938b-11e9-8184-5f7bfe66f1a2.png",
        "https://user-images.githubusercontent.com/1459805/60091808-a19b8a00-976f-11e9-9cc7-576ca05c2442.png"
      ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var _len = _products.length + (_loading ? 13 : 13);
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
                          return Stack(children: [
                            CarouselSlider.builder(
                              height: 250,
                              itemBuilder: (context, i) {
                                return Container(
                                  width: double.infinity,
                                  color: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                  child: i == 0
                                      ? Image.asset(
                                          "assets/home_banner.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image(
                                          image: CachedNetworkImageProvider(
                                              images[i]),
                                          fit: BoxFit.cover,
                                          frameBuilder: (BuildContext context,
                                              Widget child,
                                              int frame,
                                              bool wasSynchronouslyLoaded) {
                                            if (frame == null)
                                              return Container(
                                                height: double.infinity,
                                                child: Center(
                                                  child:
                                                      CupertinoActivityIndicator(),
                                                ),
                                              );
                                            return child;
                                          },
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                                height: double.infinity,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes
                                                        : null,
                                                  ),
                                                ));
                                          },
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
                                  children:
                                      List.generate(images.length, (index) {
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
                          ]);
                        }

                        if (index == 1) {
                          return Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10)
                                    .copyWith(top: 15),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text(
                                      "Categories",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                    InkWell(
                                      onTap: () {
//                                        Navigator.of(context).push(
//                                            CupertinoPageRoute(
//                                                builder: (context) =>
//                                                    CategoryScreen()));
                                      },
                                      child: Text(
                                        "View all",
                                        style:
                                            TextStyle(color: Color(0xfff78900)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 165,
                                margin: EdgeInsets.only(bottom: 10),
                                child: GridView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(7),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1 / 2),
                                  children: _categories
                                      .asMap()
                                      .map((k, f) => MapEntry(
                                          k,
                                          Card(
                                            child: InkWell(
                                                onTap: () async {
                                                  await Navigator.of(context).push(CupertinoPageRoute(
                                                      builder: (context) => OldCategory(
                                                        list: [f],
                                                        user: widget.user,
                                                        callback: widget.callback,
                                                        title: f?.name,
                                                      )));
                                                  widget.cartState.currentState?.refresh();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage:
                                                            CachedNetworkImageProvider(
                                                                f.url),
                                                      ),
                                                      Expanded(
                                                          child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 4),
                                                        child: Text(
                                                          f.name,
                                                          style: TextStyle(
                                                              fontSize: 12.5),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ))
                                                    ],
                                                  ),
                                                )),
                                          )))
                                      .values
                                      .toList(),
                                ),
                              )
                            ],
                          );
                        }

                        if (index == 6) {
                          return Container();
                        }

                        if (index == 3) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Color(0xfffff7a8),
                            ),
                            height: 200,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  width: 170,
                                  height: 170,
                                  child: QuarterCircle(
                                    circleAlignment: CircleAlignment.topLeft,
                                  ),
                                ),
                                Positioned(
                                  child: Container(
                                    width: double.infinity,
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                  child: Text(
                                                "Flash sales",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              )),
                                              InkWell(
                                                child: Text(
                                                  "See all",
                                                  style: TextStyle(
                                                      color: Colors.deepOrange),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                            child: ListView.builder(
                                                padding: EdgeInsets.symmetric(
                                                        horizontal: 20)
                                                    .copyWith(bottom: 10),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: _list.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        right: 10),
                                                    padding: EdgeInsets.all(1),
                                                    width: 130,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Expanded(
                                                            child: Stack(
                                                          children: <Widget>[
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              child: Image(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: double
                                                                      .infinity,
                                                                  frameBuilder: (context,
                                                                          child,
                                                                          frame,
                                                                          was) =>
                                                                      frame ==
                                                                              null
                                                                          ? Container(
                                                                              width: 130,
                                                                              child: Center(
                                                                                child: CupertinoActivityIndicator(),
                                                                              ),
                                                                            )
                                                                          : child,
                                                                  image: CachedNetworkImageProvider(
                                                                      _list[index]
                                                                          .url)),
                                                            ),
                                                            Positioned(
                                                              child: Container(
                                                                child: Text(
                                                                  "-37%",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10),
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .deepOrange,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4)),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(3),
                                                              ),
                                                              right: 0,
                                                              top: 0,
                                                            )
                                                          ],
                                                        )),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5,
                                                                  left: 7),
                                                          child: Text(
                                                            "9,056 RWF",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5,
                                                                  left: 7),
                                                          child: Row(
                                                            children:
                                                                List.generate(5,
                                                                    (index) {
                                                              return Icon(
                                                                Icons
                                                                    .star_border,
                                                                size: 14,
                                                                color: Colors
                                                                    .black,
                                                              );
                                                            }),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                })),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }

                        if (index == 4) {
//                          return Container(
//                            margin: EdgeInsets.symmetric(vertical: 10),
//                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Padding(
//                                  padding: const EdgeInsets.all(8.0),
//                                  child: Text(
//                                    "Brands",
//                                    style: TextStyle(
//                                        fontSize: 16,
//                                        fontWeight: FontWeight.bold,
//                                        color: Colors.black),
//                                  ),
//                                ),
//                                Container(height: 160,color: color,)
//                              ],
//                            ),
//                          );
                        return Container();
                        }

                        if (index == 2) {
                          return Container();
                        }

                        if (index == 5) {
//                          return Container(
//                            margin: EdgeInsets.symmetric(vertical: 10),
//                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Padding(
//                                  padding: const EdgeInsets.all(8.0),
//                                  child: Text(
//                                    "New Arrivals",
//                                    style: TextStyle(
//                                        fontSize: 16,
//                                        fontWeight: FontWeight.bold,
//                                        color: Colors.black),
//                                  ),
//                                ),
//                                Container(height: 160,color: color,)
//                              ],
//                            ),
//                          );
                          return Container();
                        }

                        if (index == 7) {
                          return Container();
                        }

                        if (index == 8) {
                          return Container();
                        }

                        if (index == 9) {
                          return Container();
                        }

                        if (index == 10) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(0xffffe707),
                            ),
                          );
                        }

                        if (index == 11) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Hot sales",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          );
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


                        //if (_items.length ~/ 3 < index) return Container();


                        index = index - 12;

                        if (_products.length ~/ 2 < index) return Container();

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                          ],
                        );

//                        return StaggeredGridView.countBuilder(
//                          shrinkWrap: true,
//                          physics: NeverScrollableScrollPhysics(),
//                          padding: EdgeInsets.all(5),
//                          crossAxisCount: 4,
//                          itemCount: _products.length,
//                          itemBuilder: (BuildContext context, int index) =>
//                              GestureDetector(
//                            onTap: () async {
//                              await Navigator.of(context)
//                                  .push(CupertinoPageRoute(
//                                      builder: (context) => Description(
//                                            product: _products[index],
//                                            user: widget.user,
//                                            callback: widget.callback,
//                                          )));
//                              widget.cartState.currentState?.loadItems();
//                            },
//                            child: ClipRRect(
//                                borderRadius: BorderRadius.circular(8.0),
//                                child: Container(
//                                    margin: EdgeInsets.all(2.0),
//                                    decoration: BoxDecoration(
//                                      borderRadius: BorderRadius.circular(5.0),
//                                      color: Colors.white,
//                                      boxShadow: [
//                                        BoxShadow(
//                                            color: Color(0xffE0E0E0)
//                                                .withOpacity(0.6),
//                                            offset: Offset(0.0, .35),
//                                            //(x,y)
//                                            blurRadius: 3.0,
//                                            spreadRadius: 0.4),
//                                      ],
//                                    ),
//                                    child: Column(
//                                      crossAxisAlignment:
//                                          CrossAxisAlignment.start,
//                                      children: <Widget>[
//                                        ClipRRect(
//                                          borderRadius: BorderRadius.only(
//                                              topLeft: Radius.circular(5.0),
//                                              topRight: Radius.circular(5.0)),
//                                          child: Image(
//                                            image: CachedNetworkImageProvider(
//                                                _products[index].url),
//                                            fit: BoxFit.fitWidth,
//                                            frameBuilder: (BuildContext context,
//                                                Widget child,
//                                                int frame,
//                                                bool wasSynchronouslyLoaded) {
//                                              if (frame == null)
//                                                return Container(
//                                                  height: 150,
//                                                  child: Center(
//                                                    child:
//                                                        CupertinoActivityIndicator(),
//                                                  ),
//                                                );
//                                              return child;
//                                            },
//                                            loadingBuilder:
//                                                (BuildContext context,
//                                                    Widget child,
//                                                    ImageChunkEvent
//                                                        loadingProgress) {
//                                              if (loadingProgress == null)
//                                                return child;
//                                              return Container(
//                                                  height: 150,
//                                                  child: Center(
//                                                    child:
//                                                        CircularProgressIndicator(
//                                                      value: loadingProgress
//                                                                  .expectedTotalBytes !=
//                                                              null
//                                                          ? loadingProgress
//                                                                  .cumulativeBytesLoaded /
//                                                              loadingProgress
//                                                                  .expectedTotalBytes
//                                                          : null,
//                                                    ),
//                                                  ));
//                                            },
//                                          ),
//                                        ),
//                                        Padding(
//                                            padding: EdgeInsets.symmetric(
//                                                vertical: 5, horizontal: 5),
//                                            child: Text(
//                                              _products[index].title,
//                                              maxLines: 2,
//                                              overflow: TextOverflow.ellipsis,
//                                              style: TextStyle(fontSize: 12),
//                                            )),
//                                        Padding(
//                                            padding: EdgeInsets.only(
//                                                bottom: 7, right: 5, left: 5),
//                                            child: Text(
//                                              '\$${_products[index].price}',
//                                              style: TextStyle(
//                                                  fontSize: 12,
//                                                  fontWeight: FontWeight.w700),
//                                            )),
//                                      ],
//                                    ))),
//                          ),
//                          staggeredTileBuilder: (int index) =>
//                              new StaggeredTile.fit(2),
//                          mainAxisSpacing: 2.0,
//                          crossAxisSpacing: 2.0,
//                        );
                      })),
              onRefresh: _refreshList),
          Positioned(
              child: _TopState(
            key: _topKey,
            list: _categories,
            goCart: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => CartScreen(user: widget.user)));
            },
          ))
        ],
      ),
    );
  }

  Widget get _brandX => Container(
        color: color,
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            _brand("OUR BRANDS"),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 10),
              height: 110,
              color: color,
              child: ListView.builder(
                  itemCount: _brands.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(4),
                      child: Container(
                        height: 30,
                        width: 83,
                        margin: EdgeInsets.only(right: 7),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(1.0, 1.0),
                                  //(x,y)
                                  blurRadius: 2.0,
                                  spreadRadius: 0.4),
                            ],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    _brands[index].itemImg1))),
                      ),
                    );
                  }),
            )
          ],
        ),
      );

  Widget _gridItem(String title, String url, double price,
      {int count: 0, int index: 0}) {
    index = (index * 2) + count;

    return _products.length <= index
        ? Container()
        : Container(
      constraints: BoxConstraints(minHeight: 220),
          child: GestureDetector(
      onTap: () async {
          var _pro = _products[index];
          await Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => Description(
                product: _pro,
                user: widget.user,
                callback: widget.callback,
              )));
          widget.cartState.currentState?.refresh();
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
                        color: Color(0xffE0E0E0)
                            .withOpacity(0.6),
                        offset: Offset(0.0, .35),
                        //(x,y)
                        blurRadius: 3.0,
                        spreadRadius: 0.4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          topRight: Radius.circular(5.0)),
                      child: Image(
                        image: CachedNetworkImageProvider(
                            _products[index].url),
                        fit: BoxFit.fitWidth,
                        frameBuilder: (BuildContext context,
                            Widget child,
                            int frame,
                            bool wasSynchronouslyLoaded) {
                          if (frame == null)
                            return Container(
                              height: 150,
                              child: Center(
                                child:
                                CupertinoActivityIndicator(),
                              ),
                            );
                          return child;
                        },
                        loadingBuilder:
                            (BuildContext context,
                            Widget child,
                            ImageChunkEvent
                            loadingProgress) {
                          if (loadingProgress == null)
                            return child;
                          return Container(
                              height: 150,
                              child: Center(
                                child:
                                CircularProgressIndicator(
                                  value: loadingProgress
                                      .expectedTotalBytes !=
                                      null
                                      ? loadingProgress
                                      .cumulativeBytesLoaded /
                                      loadingProgress
                                          .expectedTotalBytes
                                      : null,
                                ),
                              ));
                        },
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Text(
                          _products[index].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        )),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: 7, right: 5, left: 5),
                        child: Text(
                          '\$${_products[index].price}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        )),
                  ],
                ))),
    ),
        );
//    TouchableOpacity(
//      padding: EdgeInsets.all(5),
//      onTap: () async {
//        var _pro = _products[index];
//        await Navigator.of(context).push(CupertinoPageRoute(
//            builder: (context) => Description(
//              product: _pro,
//              user: widget.user,
//              callback: widget.callback,
//            )));
//        widget.cartState.currentState?.refresh();
//      },
//      child: Container(
//        height: 170,
//        child: Column(
//          mainAxisSize: MainAxisSize.max,
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: [
//            Expanded(
//                child: Container(
//                  constraints: BoxConstraints(minWidth: double.infinity),
//                  child: FadeInImage(
//                    image: CachedNetworkImageProvider('${_items[index].url}'),
//                    fit: BoxFit.cover,
//                    placeholder: defLoader,
//                  ),
//                )),
//            SizedBox(height: 5),
//            Padding(
//                padding: EdgeInsets.all(5),
//                child: Text(
//                  '${_items[index].title}',
//                  style: TextStyle(
//                      fontFamily: 'Asimov',
//                      color: Color(0xff4d4d4d),
//                      fontSize: 12,
//                      fontWeight: FontWeight.normal),
//                  maxLines: 1,
//                  overflow: TextOverflow.ellipsis,
//                )),
//            Padding(
//                padding: EdgeInsets.symmetric(horizontal: 5),
//                child: Text(
//                  '\$${_items[index].price}',
//                  style: TextStyle(
//                      fontSize: 13,
//                      color: Color(0xff4D4D4D).withOpacity(0.5),
//                      fontFamily: 'DIN Alternate Bold'),
//                  maxLines: 1,
//                  overflow: TextOverflow.ellipsis,
//                )),
//            Padding(
//                padding: EdgeInsets.symmetric(horizontal: 5),
//                child: Text(
//                  '',
//                  style: TextStyle(
//                      fontSize: 10,
//                      decoration: TextDecoration.lineThrough,
//                      color: Color(0xff4D4D4D).withOpacity(0.5),
//                      fontFamily: 'DIN Alternate Bold'),
//                  maxLines: 1,
//                  overflow: TextOverflow.ellipsis,
//                ))
//          ],
//        ),
//      ),
//    );
  }
}

class _TopState extends StatefulWidget {
  final String id;
  final void Function() goCart;
  final List<Category> list;

  const _TopState({Key key, this.id, this.goCart,@required this.list}) : super(key: key);

  @override
  __TopStateState createState() => __TopStateState();
}

class __TopStateState extends State<_TopState> {
  var _index = 0;

  Color get fColor => _color == Colors.black38 ? Colors.white : Colors.black38;

  Color _color = Colors.black38;

  void popColor(double pixel) {
    if (pixel > 100 && _color == Colors.black38) {
      setState(() {
        _color = Colors.white;
      });
    } else if (pixel <= 100 && _color != Colors.black38) {
      setState(() {
        _color = Colors.black38;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: _color == Colors.black38 ? null : _color,
              gradient: _color == Colors.black38
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.black38, Colors.black12])
                  : null),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
              .copyWith(top: 25),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    height: 50,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        style: TextStyle(color: _color),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            hintText: "I'm shopping for...",
                            hintStyle: TextStyle(color: _color),
                            filled: true,
                            prefixIcon: Icon(Icons.search),
                            fillColor: fColor,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(50))),
                      ),
                    ),
                  )),
                  InkWell(
                    onTap: widget.goCart,
                    child: Icon(
                      Icons.shopping_cart,
                      color: fColor,
                    ),
                  ),
                ],
              ),
              Container(
                height: 27,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  children: List.generate(widget.list.length, (index) {
                    return InkWell(
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 12)
                                  .copyWith(top: 0),
                          decoration: _index == index
                              ? BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: fColor, width: 2.5)))
                              : null,
                          child: Text(
                            "${widget.list[index].name}",
                            style: TextStyle(
                                color: fColor, fontWeight: FontWeight.bold),
                          )),
                      onTap: () {
                        setState(() {
                          _index = index;
                        });
                      },
                    );
                  }),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
