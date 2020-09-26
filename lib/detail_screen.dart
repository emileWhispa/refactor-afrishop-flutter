import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Product.dart';
import 'Json/SubCategory.dart';
import 'SuperBase.dart';
import 'description.dart';

class DetailScreen extends StatefulWidget {
  final SubCategory category;

  const DetailScreen({Key key, @required this.category}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SuperBase {
  List<Product> _products = [];
  var _control = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshList());
  }

  Future<void> _refreshList() {
    _control.currentState?.show(atTop: true);
    return this.ajax(
        url: "listProductsByCategory?categoryId=${widget.category?.id}&pageNo=0&pageSize=30",
        onValue: (source, url) {
          Iterable _map = json.decode(source);
          setState(() {
            _products = _map.map((json) => Product.fromJson(json)).toList();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.category.name),
          elevation: 2.0,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: () {})
          ],
          bottom: PreferredSize(
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Best match"),
                  )),
                  IconButton(icon: Icon(Icons.dashboard), onPressed: () {}),
                  IconButton(icon: Icon(Icons.filter), onPressed: () {})
                ],
              ),
              preferredSize: Size.fromHeight(45)),
        ),
        body: RefreshIndicator(
            key: _control,
            child: Scrollbar(
                child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      return Card(
                          elevation: 1.0,
                          child:InkWell(
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => Description(
                                    key: UniqueKey(),
                                    product: _products[index],
                                  )));
                            },
                            child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CachedNetworkImage(
                                  height: 100,
                                  width: 100,
                                  imageUrl: '${_products[index].url}',
                                  fit: BoxFit.cover,
                                  placeholder: (context, i) => Center(
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 7),
                                        child: Text(
                                          '\$${_products[index].price}',
                                          style:
                                              Theme.of(context).textTheme.title,
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(6, (index) {
                                          return index == 5
                                              ? Expanded(
                                                  child: Text(
                                                  "60 orders",
                                                  textAlign: TextAlign.end,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))
                                              : Icon(
                                                  Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 15,
                                                );
                                        }),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5),
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Text(
                                              "Free shipping",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(Icons.more_vert)
                                        ],
                                      )
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                      );
                    })),
            onRefresh: _refreshList));
  }
}
