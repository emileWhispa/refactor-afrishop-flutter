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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'Json/Brand.dart';
import 'Json/Category.dart';
import 'Json/User.dart';
import 'SuperBase.dart';
import 'item.dart';
import 'cart_page.dart';

class Choice{
  final String name;
  final String address;

  Choice(this.name, this.address);
}

class SecondHomepage extends StatefulWidget {
  final GlobalKey<CartScreenState> cartState;
  final void Function(User user) callback;

  const SecondHomepage({Key key, @required this.cartState, this.callback}) : super(key: key);

  @override
  _SecondHomepageState createState() => _SecondHomepageState();
}

class _SecondHomepageState extends State<SecondHomepage> with SuperBase {
  Widget _brand(String title,{Color color:const Color(0xfffbd858)}) {
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

  int max;
  int current = 0;
  bool _loading = false;
  ScrollController _controller = new ScrollController();

  Widget _row(String title, String title2) {
    final style = TextStyle(
        color: Color(0xffe8c854), fontSize: 18, fontStyle: FontStyle.italic);
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
            padding: EdgeInsets.all(20),
            color: Color(0xff333333),
            child: Center(
                child: Text(
              title,
              style: style,
            )),
          )),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(left: 3),
            color: Color(0xff333333),
            child: Center(
              child: Text(
                title2,
                style: style,
              ),
            ),
          )),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this._loadBrands();
      this._loadCategories();
      this._refreshList(inc: true);
    });

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _refreshList(inc: true);
        print("reached bottom ($current)");
      }
    });
  }

  Future<void> _loadBrands() {
    return this.ajax(
        url: "listBrands",
        auth: false,
        onValue: (source, url) {
          Iterable _map = json.decode(source);
          setState(() {
            _brands = _map.map((f) => Brand.fromJson(f)).toList();
          });
        },
        error: (s, v) {
          print(s);
        });
  }

  Future<void> _loadCategories() {
    return this.ajax(
        url: "listCategories?page=0&size=8",
        auth: false,
        onValue: (source, url) {
          Iterable _map = json.decode(source);
          setState(() {
            _categories = _map.map((f) => Category.fromJson(f)).toList();
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
    setState(() {
      _loading = true;
    });
    return this.ajax(
        url:
            "listAllProducts?pageNo=$current&pageSize=12",
        auth: false,
        server: true,
        onValue: (source, url) {
          if (_urls.contains(url)) {
            return;
          }
          current += inc ? 1 : 0;
          _urls.add(url);
          //print("Whispa sent requests ($current): $url");
          Iterable _map = json.decode(source);
          setState(() {
            _products.addAll(_map.map((f) => Product.fromJson(f)).toList());
          });
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
        },
        error: (s, v) {
          print(" error vegan : $s");
        });
  }

  List<Brand> _brands = [];

  Future<void> _refreshList({bool inc: false}) {
    _control.currentState?.show(atTop: true);
    _loadBrands();
    _loadItems(inc: inc);

    return Future.value();
  }

  int _current = 0;

  List<String> get images => [
        "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/90094163_668596227229872_5716959898011183998_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=100&_nc_ohc=reIR9obOxqMAX-vleTp&oh=c9f7bce7a57c4489b669c6152bb46754&oe=5EA0FF58",
        "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/90094163_668596227229872_5716959898011183998_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=100&_nc_ohc=reIR9obOxqMAX-vleTp&oh=c9f7bce7a57c4489b669c6152bb46754&oe=5EA0FF58",
        "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/90085939_280835336244880_7349924919496944527_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=2uxLqlnLTgQAX8W8oKR&oh=48987b46f23db1aa0d1bb703c0821096&oe=5EA092F6",
        "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/87601194_534367677201075_7891038534720558185_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=103&_nc_ohc=LwRNdchHqo4AX-UHheM&oh=2cc2ece1e5c73f21db176edf5402270d&oe=5E9DC811",
        "https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/87217612_496685841234077_5209662721745286314_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=105&_nc_ohc=b4jtZZhqwysAX8wgeJn&oh=57f7f6bb9d340f6910a4078eaaa477b1&oe=5E9F1EC1"
      ];


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var _len = 1 + (_loading ? 13 : 12);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          RefreshIndicator(
              key: _control,
              displacement: 80,
              child: Scrollbar(
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 80),
                      controller: _controller,
                      itemCount: _len,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Stack(children: [
                            CarouselSlider.builder(
                              height: 230,
                              itemBuilder: (context, i) {
                                return Container(
                                  width: double.infinity,
                                  color: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                  child: i == 0
                                      ? Image.asset(
                                          "assets/home_banner@3x.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image(
                                          image:CachedNetworkImageProvider(images[i]),
                                          fit: BoxFit.fitWidth,
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
                                      width: 8.0,
                                      height: 8.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _current == index
                                              ? Color.fromRGBO(0, 0, 0, 0.9)
                                              : Color.fromRGBO(0, 0, 0, 0.4)),
                                    );
                                  }),
                                ))
                          ]);
                        }

                        if (index == 1) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: <Widget>[
                                GridView(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                  children: _categories.asMap().map((k,f)=>MapEntry(k, InkWell(
                                      onTap: (){
                                        Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>CategoryScreen()));
                                      },child:Container(
                                    child: Column(
                                      children: <Widget>[
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: k+1 == _categories.length ? color : Colors.grey,
                                          child: k+1 == _categories.length ? Icon(Icons.more_horiz) : null,
                                          backgroundImage: k+1 == _categories.length ? null : CachedNetworkImageProvider(f.url),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          f.name,
                                          style:
                                          TextStyle(fontSize: 12.5),
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  )))).values
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

                        if (index == 6) {
                          return Container(
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
                                                    image:
                                                    CachedNetworkImageProvider( _brands[index].itemImg1))),
                                          ),
                                        );
                                      }),
                                )
                              ],
                            ),
                          );
                        }

                        if (index == 3) {
                          return Container(height: 400,
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Column(
                                children: <Widget>[

                                  Expanded(flex:2,child: CachedNetworkImage(imageUrl:"https://instagram.fkgl2-1.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/p750x750/88276752_499840260642764_7350772599357048630_n.jpg?_nc_ht=instagram.fkgl2-1.fna.fbcdn.net&_nc_cat=108&_nc_ohc=YJkIuN6175YAX-TOp_m&oh=73ab09f82185538fe39d0dba857d03bb&oe=5E9CBF13",fit: BoxFit.cover,width: double.infinity)),
                                  Expanded(child: CachedNetworkImage(imageUrl:"https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s750x750/84469624_614160582759889_3703883138521319034_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=101&_nc_ohc=xmQx6_OOSNYAX996J2-&oh=f8327c464a2c53ca9adcb1a8829d65d7&oe=5EB44F1A",fit: BoxFit.cover,width: double.infinity))
                                ],
                              )),
                              //
                              Expanded(child: Column(children: <Widget>[
                                Expanded(child: CachedNetworkImage(imageUrl:"https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/e35/84332618_3269096726467681_4340622738987114260_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=101&_nc_ohc=r9vwGo9SF9IAX_I_7eq&oh=b905727add5ce6627aac11522acf29f0&oe=5E9DB962",fit: BoxFit.cover,width: double.infinity,)),
                                Expanded(child: CachedNetworkImage(imageUrl:"https://instagram.fkgl2-2.fna.fbcdn.net/v/t51.2885-15/e35/83199139_644795539628765_840347403361876644_n.jpg?_nc_ht=instagram.fkgl2-2.fna.fbcdn.net&_nc_cat=105&_nc_ohc=6qgLz5_NBCIAX-3uo9w&oh=cc6a7e59bde4ffa51ccda08aaadae459&oe=5EA92B14",fit: BoxFit.cover,width: double.infinity,)),
                                Expanded(child: CachedNetworkImage(imageUrl:"https://instagram.fkgl2-1.fna.fbcdn.net/v/t51.2885-15/e15/80889137_479341809671387_4517166186896271078_n.jpg?_nc_ht=instagram.fkgl2-1.fna.fbcdn.net&_nc_cat=111&_nc_ohc=V5Mr734x7t4AX9-YtCH&oh=f25734ae55b54c107b7b63af310c1772&oe=5EA81FE4",fit: BoxFit.cover,width: double.infinity,))
                              ],))
                            ],
                          ),);
                        }

                        if (index == 4) {
                          return Container();
                        }

                        if (index == 2) {
                          return _brand("NEW ARRIVALS");
                        }

                        if (index == 5) {
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
                          return _brand("HOT SALES");
                        }

                        if (index == _len - 1 && _loading) {
                          return Center(
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(),
                                )),
                          );
                        }

                        index = index - 12;

                        //if (_items.length ~/ 3 < index) return Container();

                        return StaggeredGridView.countBuilder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(5),
                          crossAxisCount: 4,
                          itemCount: _products.length,
                          itemBuilder: (BuildContext context, int index) => GestureDetector(
                            onTap: ()async{

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
                                            offset: Offset(0.0, .35), //(x,y)
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
                                          child: Image(
                                            image:CachedNetworkImageProvider(_products[index].url),
                                            fit: BoxFit.fitWidth,
                                            frameBuilder: (BuildContext context, Widget child,
                                                int frame, bool wasSynchronouslyLoaded) {
                                              if (frame == null)
                                                return Container(
                                                  height: 150,
                                                  child: Center(
                                                    child: CupertinoActivityIndicator(),
                                                  ),
                                                );
                                              return child;
                                            },
                                            loadingBuilder: (BuildContext context, Widget child,
                                                ImageChunkEvent loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                  height: 150,
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress
                                                          .expectedTotalBytes !=
                                                          null
                                                          ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes
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
                                              maxLines: 2,overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12),
                                            )),
                                        Padding(
                                            padding:
                                            EdgeInsets.only(bottom: 7, right: 5, left: 5),
                                            child: Text(
                                              '\$${_products[index].price}',
                                              style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700),
                                            )),
                                      ],
                                    ))),
                          ),
                          staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                          mainAxisSpacing: 2.0,
                          crossAxisSpacing: 2.0,
                        );
                      })),
              onRefresh: _refreshList),
          Positioned(
              child: Container(
            margin: EdgeInsets.only(top: 25),
            width: double.infinity,
            height: 58,
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
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0),
                        hintText: "I'm shopping for...",
                        filled: true,
                        prefixIcon: Icon(Icons.search),
                        fillColor: Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10))),
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
    return _products.length <= index
        ? Container()
        : TouchableOpacity(
            padding: EdgeInsets.all(5),
            onTap: () async {

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
                    child: Image(
                      image: CachedNetworkImageProvider('${_products[index].url}'),
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                  )),
                  SizedBox(height: 5),
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '${_products[index].title}',
                        style: TextStyle(
                            color: Color(0xff4d4d4d),
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        '\$${_products[index].price}',
                        style: TextStyle(color: Color(0xffCDCDCD)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ))
                ],
              ),
            ),
          );
  }
}
