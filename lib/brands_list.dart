import 'dart:convert';

import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/crawl_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Brand.dart';
import 'Json/User.dart';
import 'inside_category.dart';

class BrandList extends StatefulWidget {
  final User Function() user;

  const BrandList({Key key, @required this.user}) : super(key: key);

  @override
  _BrandListState createState() => _BrandListState();
}

class _BrandListState extends State<BrandList> with SuperBase {
  int page = 1;
  ScrollController _controller = new ScrollController();
  var _key = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _key.currentState?.show(atTop: true);
    });
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _key.currentState?.show(atTop: true);
      }
    });
  }

  List<String> _urls = [];

  Future<void> _loadBrands() {
    return this.ajax(
        url: "store/?pageNum=$page&pageSize=12",
        onValue: (source, url) {
          if (_urls.contains(url)) {
            return;
          }

          //print("Whispa sent requests ($current): $url");
          Map<String, dynamic> _data = json.decode(source);
          Iterable _map = _data['data']['content'];
          setState(() {
            _urls.add(url);
            page++;
            _brands.addAll(_map.map((f) => Brand.fromJson(f)).toList());
          });
        },error: (s,v)=>print(s));
  }

  List<Brand> _brands = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text("Brands", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Color(0xffF4F4F4),
      body: RefreshIndicator(
        key: _key,
        onRefresh: _loadBrands,
        child: ListView.builder(
            controller: _controller,
            itemCount: _brands.length,
            itemBuilder: (context, index) {
              var br = _brands[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.6)),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: EdgeInsets.only(left: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => CrawlScreen(
                              url:
                                  br.storeUrl,
                              user: widget.user,
                          title: br.storeName,
                            )));
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        "${br.storeName}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      Container(
                          height: 100,
                          width: 100,
                          child: Image(
                            image: CachedNetworkImageProvider(
                               br.storeImg),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ))
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
