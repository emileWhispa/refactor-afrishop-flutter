import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:afri_shop/Partial/TouchableOpacity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Category.dart';
import 'Json/SubCategory.dart';
import 'SuperBase.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with AutomaticKeepAliveClientMixin, SuperBase {
  List<SubCategory> _subCategories = [];

  List<Category> _categories = [];

  var _refreshControlOne = new GlobalKey<RefreshIndicatorState>();
  var _refreshControlTwo = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this._refreshControlOne.currentState?.show(atTop: true));
  }

  Future<void> _loadCategories() {
    return this.ajax(
        url: "listCategories?page=0&size=20",
        onValue: (source, url) {
          Iterable _map = json.decode(source);
          setState(() {
            _categories = _map.map((f) => Category.fromJson(f)).toList();
            if (_categories.isNotEmpty) _loadSubCategories(_categories.first);
          });
        });
  }

  Future<void> _loadProducts() {
    if (_active == null) return Future.value();
    _refreshControlTwo.currentState?.show(atTop: true);
    return this.ajax(
        url: "listSubCategoryByCategory/${_active.id}",
        onValue: (source, url) {
          Iterable _map = json.decode(source);
          setState(() {
            _subCategories = _map.map((f) => SubCategory.fromJson(f)).toList();
          });
        });
  }

  Future<void> _loadSubCategories(Category category) {
    _active = category;
    return _loadProducts();
  }

  Category _active;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    // var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    //final double itemHeight = (size.height) / 1.50;
    //final double itemWidth = size.width / 2;
    return Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          title: Text("Category page"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: () {})
          ],
        ),
        body: Row(children: [
          Container(
            width: 110,
            child: RefreshIndicator(
                child: ListView.builder(
                    itemCount: _categories.length + 1,
                    itemBuilder: (context, index) {
                      index = index - 1;
                      if (index < 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 17.5, horizontal: 5),
                          child: Text(
                            "Recommended",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                        );
                      }
                      return TouchableOpacity(
                        child: Container(
                          color: const Color(0xffefeeee),
                          margin: EdgeInsets.symmetric(vertical: 1),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Text(
                            _categories[index].name,
                            style: TextStyle(color: Color(0xff9c9a9a)),
                          ),
                        ),
                        onTap: () {
                          _loadSubCategories(_categories[index]);
                        },
                      );
                    }),
                onRefresh: _loadCategories),
          ),
          Expanded(
              child: RefreshIndicator(
                  child: Scrollbar(
                      child: ListView(
                    children: <Widget>[

                      Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Recommended",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          Text(
                            " ${_active?.name ?? ""}",
                            style: Theme.of(context).textTheme.subtitle.copyWith(color: color),
                          )
                        ],
                      )),
                      _grid(_subCategories),
                      Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Hot items",
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              Text(
                                " ${_active?.name ?? ""}",
                                style: Theme.of(context).textTheme.subtitle.copyWith(color: color),
                              )
                            ],
                          )),
                      _grid(_subCategories),

                  Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Suggested",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          Text(
                            " ${_active?.name ?? ""}",
                            style: Theme.of(context).textTheme.subtitle.copyWith(color: color),
                          )
                        ],
                      )),
                      _grid(_subCategories)
                    ],
                  )),
                  onRefresh: _loadProducts))
        ]));
  }

  Widget _grid(List<SubCategory> _list) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(6),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3.3 / 4,
            crossAxisSpacing: 4.0,
            //childAspectRatio: (itemWidth / itemHeight),
            mainAxisSpacing: 4.0),
        itemCount: _list.length,
        itemBuilder: (context, index) {
          var item = _list[index];
          return TouchableOpacity(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => DetailScreen(
                        key: UniqueKey(),
                        category: item,
                      )));
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Container(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: CachedNetworkImage(
                    imageUrl: item.url,
                    fit: BoxFit.cover,
                    placeholder: (context, str) => Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                )),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      item.name,
                      style: TextStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ))
              ],
            ),
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
