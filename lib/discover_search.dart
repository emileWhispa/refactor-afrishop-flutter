import 'dart:convert';

import 'package:afri_shop/Json/Post.dart';
import 'package:afri_shop/Partial/list_item.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'Json/history.dart';

class DiscoverSearch extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const DiscoverSearch({Key key, @required this.user, @required this.callback})
      : super(key: key);

  @override
  _DiscoverSearchState createState() => _DiscoverSearchState();
}

class _DiscoverSearchState extends State<DiscoverSearch> with SuperBase {
  bool _searching = false;
  List<History> _histories = [];

  TextEditingController _controller = new TextEditingController();

  var _list = <Post>[];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var data = (await prefs).get(historyLinkDiscover);
      if (data != null) {
        Iterable map = json.decode(data);
        setState(() {
          _histories = map.map((f) => History.fromJson(f)).toList();
        });
      }
    });
  }

  void addHistory(String query) {
    _histories
      ..removeWhere((f) => f.query == query)
      ..insert(0, new History(query, DateTime.now().toString()));
    save(historyLinkDiscover, _histories);
  }

  Future<void> _loadData(String query) {
    if( query.trim().isEmpty){
      setState(() {
        _list.clear();
      });
    }
    setState(() {
      addHistory(query);
      _searching = true;
    });


    return this.ajax(
        url: "discover/post/searchPost/${Uri.encodeComponent(query)}?pageNo=0&pageSize=50",
        server: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          Iterable iterable = json.decode(source);
          setState(() {
            _searching = false;
            _searched = true;
            _list = iterable.map((f) => Post.fromJson(f)).toList();
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

  bool _searched = false;


  Future<bool> _checkPage()async{
    if( _controller.text.isNotEmpty && _searched){
      setState(() {
        _searched = false;
        _controller.clear();
      });
    }else{
      Navigator.pop(context);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _checkPage,
      child: Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _checkPage)
              : null,
          title: Container(
            height: 35,
            child: TextFormField(
              onChanged: (s) => _text = s,
              onFieldSubmitted: _loadData,
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
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Image.asset("assets/search_v2.png", height: 24, width: 24),
                onPressed: () => this._loadData(_text))
          ],
        ),
        body: !_searched
            ? SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: <Widget>[
                      _histories.isEmpty
                          ? SizedBox.shrink()
                          : Text(
                        "Search History",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      _histories.isEmpty
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
                                    style:
                                    TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Column(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          "Confirm to delete all history",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15)),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(10.0),
                                                child: RaisedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context);
                                                  },
                                                  color: Colors.white,
                                                  padding:
                                                  EdgeInsets.all(
                                                      10),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                      side:
                                                      BorderSide(
                                                        color: Colors
                                                            .red,
                                                      ),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          6)),
                                                  elevation: 0.7,
                                                  child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 14,
                                                        color: Colors
                                                            .red),
                                                  ),
                                                ),
                                              )),
                                          Expanded(
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(10.0),
                                                child: RaisedButton(
                                                  onPressed:
                                                      () async {
                                                    Navigator.of(
                                                        context)
                                                        .pop();
                                                    (await prefs).remove(
                                                        historyLinkDiscover);
                                                    setState(() {
                                                      _histories
                                                          .clear();
                                                    });
                                                  },
                                                  color: color,
                                                  padding:
                                                  EdgeInsets.all(
                                                      10),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          6)),
                                                  elevation: 0.7,
                                                  child: Text(
                                                    "Confirm",
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 14),
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
                            Image.asset("assets/home_delete.png",
                                height: 16, width: 16),
                            Text("Clear all"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: RichText(
                    text: TextSpan(
                        children: _histories
                            .map((f) => WidgetSpan(
                            child: InkWell(
                                onTap: () {
                                  _controller.text = f.query;
                                  _loadData(f.query);
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
        ) : _list.isEmpty ? ListView(
          children: <Widget>[
            Container(margin: EdgeInsets.only(top: 70),child: Image.asset("assets/no_record.png",height:150)),
            Center(child: Text("No record",style: TextStyle(fontSize: 22),))
          ],
        ) : ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return ListItem(
                  post: _list[index],
                  user: widget.user,
                  likePost: (x) {},
                  delete: () {},
                  callback: widget.callback);
            }),
      ),
    );
  }
}
