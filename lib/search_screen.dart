import 'dart:convert';

import 'package:afri_shop/Json/history.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/description.dart';
import 'package:afri_shop/inside_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Product.dart';
import 'Json/User.dart';

class SearchScreen extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const SearchScreen({Key key, @required this.user, @required this.callback})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SuperBase {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadRecommended();
      loadHistories();
    });
  }

  List<Product> _list = [];
  List<Product> _listFuzzy = [];
  List<Product> _listUp = [];
  List<Product> _listDown = [];
  List<History> _histories = [];
  List<String> _recommended = [];

  TextEditingController _controller = new TextEditingController();

  bool _searching = false;
  bool _searched = false;

  void addHistory(String query) {
    if (_histories.any((element) => element.query == query)) return;
    _histories
      ..removeWhere((f) => f.query == query)
      ..insert(0, new History(query, DateTime.now().toString()));
    //save(historyLink, _histories);

    this.ajax(
        url: "search/save",
        authKey: widget.user()?.token,
        auth: true,
        server: true,
        method: "POST",
        map: {"searchKeywords": query, "userId": widget.user()?.id},
        onValue: (source, url) {
          print(source);
        });
  }

  String _searchUrl;

  void loadHistories() {
    this.ajax(
        url: "search/getRecords",
        authKey: widget.user()?.token,
        auth: true,
        error: (s,v)=>print(s),
        onValue: (source, url) {
          setState(() {
            _searchUrl = url;
            _histories = ((jsonDecode(source)['data'] ?? []) as Iterable)
                .map((e) => History.fromJson(e))
                .toList();
          });
          print(source);
        });
  }

  void loadRecommended() {
    this.ajax(
        url: "itemStation/queryHotRecommended",
        onValue: (source, url) {
          var map = json.decode(source);
          Iterable _data = map['data'];
          setState(() {
            _recommended = _data.map((f) => f.toString()).toList();
          });
        },
        error: (s, v) => print(s));
  }

  int _inc = 1;

  Future<void> _loadData(String query,
      {bool fuzzy: false, bool addHistory: true, int inc: 1}) {
    setState(() {
      _inc = inc;
      if (query.isEmpty) {
        _listFuzzy.clear();
        _list.clear();
        _listUp.clear();
        _listDown.clear();
      } else
        _searching = !fuzzy;
    });

    if (query.isEmpty) return Future.value();

    if (!fuzzy && addHistory) {
      this.addHistory(query);
    }

    return this.ajax(
        url:
            "itemStation/searchItems?name=${Uri.encodeComponent(query)}&pageNum=1&pageSize=50",
        server: true,
        onValue: (source, url) {
          print(url);
          var dx = json.decode(source)['data'];
          if (dx == null || _inc != inc) return;
          Iterable iterable = dx['content'];
          setState(() {
            if (_controller.text.isEmpty) return;
            if (fuzzy) {
              _listFuzzy = iterable.map((f) => Product.fromJson(f)).toList();
              return;
            }
            _listFuzzy = [];
            _searching = false;
            _list = iterable.map((f) => Product.fromJson(f)).toList();
            _listUp = _list.toList();
            _listDown = _list.toList();
            _searched = true;
            _listUp.sort((v, c) => c.price.compareTo(v.price));
            _listDown.sort((v, c) => v.price.compareTo(c.price));
          });
        },
        error: (s, v) => print(s),
        onEnd: () {
          setState(() {
            _searching = false;
          });
        });
  }

  var _text = "";

  Future<bool> _checkPage() async {
    if (_controller.text.isNotEmpty && _searched) {
      setState(() {
        _searched = false;
        _listFuzzy.clear();
        _controller.clear();
      });
    } else {
      Navigator.pop(context);
    }

    return false;
  }

  void _deleteAll() async {
    Navigator.of(context).pop();
    (await prefs).remove(historyLink);
    (await prefs).remove(_searchUrl??"");
    var ids = _histories.map((e) => e.id).toList();
    setState(() {
      _deleting = true;
    });

    this.ajax(
        url: "search/deleteRecords",
        method: "DELETE",
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        jsonData: jsonEncode(ids),
        onValue: (source, url) {
          var mp = jsonDecode(source);
          if (mp['code'] == 1) {
            platform.invokeMethod("toast", "success");
            setState(() {
              _histories.clear();
            });
          }else{
            print(source);
            print(url);
          }
        },
        error: (s,v){
          print(s);
          print(v);
        },
        onEnd: () {
          setState(() {
            _deleting = false;
          });
        });
  }

  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _checkPage,
      child: Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios), onPressed: _checkPage)
              : null,
          title: Container(
            height: 35,
            child: TextFormField(
              onChanged: (s) {
                _text = s;
                _loadData(s, fuzzy: true, inc: ++_inc);
              },
              onFieldSubmitted: (s) => _loadData(s, inc: ++_inc),
              controller: _controller,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  hintText: "Search",
                  suffixIcon: _searching ? CupertinoActivityIndicator() : null,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(6))),
            ),
          ),
          actions: <Widget>[
            IconButton(
                icon:
                    Image.asset("assets/search_v2.png", height: 24, width: 24),
                onPressed: () => this._loadData(_text, inc: ++_inc))
          ],
        ),
        body: _listFuzzy.isNotEmpty
            ? ListView.builder(
                itemCount: _listFuzzy.length,
                itemBuilder: (context, index) {
                  var p = _listFuzzy[index];
                  return ListTile(
                    onTap: () {
                      _controller.text = p.title;
                      _loadData(p.title, addHistory: true, inc: ++_inc);
                    },
                    title: Text("${p.title}"),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade300,
                    ),
                  );
                })
            : !_searched
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              "Hot & Sales",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: RichText(
                              text: TextSpan(
                                  children: _recommended
                                      .map((f) => WidgetSpan(
                                          child: InkWell(
                                              onTap: () {
                                                _controller.text = f;
                                                _loadData(f, inc: ++_inc);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "$f",
                                                  style: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                              ))))
                                      .toList()),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              children: <Widget>[
                                _histories.isEmpty
                                    ? SizedBox.shrink()
                                    : Text(
                                        "Search History",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                Spacer(),
                                _deleting
                                    ? CupertinoActivityIndicator()
                                    : _histories.isEmpty
                                        ? SizedBox.shrink()
                                        : InkWell(
                                            onTap: () async {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      contentPadding:
                                                          EdgeInsets.all(5),
                                                      title: Text(
                                                        "Confirm To Delete",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                              "Confirm to delete all history",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      15)),
                                                          Row(
                                                            children: <Widget>[
                                                              Expanded(
                                                                  child:
                                                                      Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  color: Colors
                                                                      .white,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  shape: RoundedRectangleBorder(
                                                                      side: BorderSide(
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      borderRadius: BorderRadius.circular(6)),
                                                                  elevation:
                                                                      0.7,
                                                                  child: Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ),
                                                              )),
                                                              Expanded(
                                                                  child:
                                                                      Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      _deleteAll,
                                                                  color: color,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6)),
                                                                  elevation:
                                                                      0.7,
                                                                  child: Text(
                                                                    "Confirm",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                              )),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Image.asset(
                                                    "assets/home_delete.png",
                                                    height: 16,
                                                    width: 16),
                                                Text("Clear all"),
                                              ],
                                            ),
                                          )
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: RichText(
                              text: TextSpan(
                                  children: _histories
                                      .map((f) => WidgetSpan(
                                          child: InkWell(
                                              onTap: () {
                                                _controller.text = f.query;
                                                _loadData(f.query, inc: ++_inc);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text("${f.query}",
                                                    style: TextStyle(
                                                        color: Colors.orange)),
                                              ))))
                                      .toList()),
                            ),
                          ),
                          SizedBox(
                            height: 90,
                          )
                        ],
                      ),
                    ),
                  )
                : _list.isEmpty
                    ? ListView(
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(top: 70),
                              child: Image.asset("assets/no_record.png",
                                  height: 150)),
                          Center(
                              child: Text(
                            "No record",
                            style: TextStyle(fontSize: 22),
                          ))
                        ],
                      )
                    : ProductList(
                        items: _list,
                        user: widget.user,
                        controller: null,
                        loadData: () async {
                          //await _loadData(_text);
                          return Future.value();
                        },
                        callback: widget.callback,
                        itemsDown: _listDown,
                        itemsUp: _listUp,
                      ),
      ),
    );
  }
}
