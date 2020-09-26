import 'dart:convert';

import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SelectProduct extends StatefulWidget {
  @override
  _SelectProductState createState() => _SelectProductState();
}

class _SelectProductState extends State<SelectProduct> with SuperBase {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => this._refreshList(inc: true));
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
  bool _loading = false;
  List<String> _urls = [];

  var _control = new GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshList({bool inc: true}) {
    _control.currentState?.show(atTop: true);

    return _loadItems(inc: inc);
  }

  Future<void> _loadItems({bool inc: false}) {
    if (max != null && current > max) {
      return Future.value();
    }
    setState(() {
      _loading = true;
    });
    return this.ajax(
        url: "itemStation/queryAll?pageNo=$current&pageSize=12",
        auth: false,
        onValue: (source, url) {
          current += inc ? 1 : 0;
          if (_urls.contains(url)) {
            return;
          }
          current += inc ? 1 : 0;
          _urls.add(url);
          //print("Whispa sent requests ($current): $url");
          Iterable _map = json.decode(source)['data']['list'];
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


  List<Product> _products = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
            Navigator.maybePop(context);
          }) : null,
          title: Column(
            children: <Widget>[
              Text("Select product"),
              Text("${_products.where((f)=>f.selected).length} selected",style: TextStyle(fontFamily: 'Futura',fontSize: 12,color: Colors.grey),)
            ],
          ),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(onPressed: (){
              Navigator.pop(context,_products.where((f)=>f.selected).toList());
            }, child: Text("Select",style: TextStyle(fontWeight: FontWeight.bold),))
          ],
        ),
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
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        pro.selected = !pro.selected;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: pro.selected ?  Colors.grey.shade200.withOpacity(0.6) : null ,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          pro.selected ? Stack(
                            children: <Widget>[
                              img,
                              Positioned(top: 0,bottom: 0,left: 0,right: 0,child: Center(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      border: pro.selected ? null : Border.all(color: Colors.grey),
                                      shape: BoxShape.circle, color: pro.selected ? color : Colors.white),
                                  child: Padding(
                                    padding: EdgeInsets.all(pro.selected ? 2.0 : 11),
                                    child: pro.selected
                                        ? Icon(
                                      Icons.check,
                                      size: 30.0,
                                      color: Colors.black,
                                    )
                                        : SizedBox.shrink(),
                                  ),
                                ),
                              ),)
                            ],
                          ) : img,
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
        ));
  }
}
