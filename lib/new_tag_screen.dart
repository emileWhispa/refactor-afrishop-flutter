import 'dart:convert';

import 'package:afri_shop/SuperBase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'Json/hashtag.dart';

class NewTagScreen extends StatefulWidget {
  final List<Hashtag> selected;
  final User Function() user;

  const NewTagScreen({Key key, this.selected,@required this.user}) : super(key: key);

  @override
  _NewTagScreenState createState() => _NewTagScreenState();
}

class _NewTagScreenState extends State<NewTagScreen> with SuperBase {
  List<Hashtag> _tags = [];
  List<Hashtag> _selected = [];
  bool _searching = false;
  var _key = new GlobalKey<RefreshIndicatorState>();
  TextEditingController _controller = new TextEditingController();
  bool _creating = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selected = (widget.selected ?? []).toList();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _key.currentState?.show());
  }

  Future<void> _loadHashTags({String query: ""}) {
    setState(() {
      _searching = query.isNotEmpty;
    });
    return this.ajax(
        url: query.isEmpty
            ? "home/listHashtags?pageNo=0&pageSize=50"
            : "searchHashtags/${Uri.encodeComponent(query)}?pageNo=0&pageSize=50",
        authKey: widget.user()?.token,
        server: query.isNotEmpty,
        onValue: (source, url) {
          Iterable map = jsonDecode(source);
          setState(() {
            _tags = map.map((f) => Hashtag.fromJson(f)).toList();
            _tags.forEach(
                (f) => f.selected = _selected.any((x) => x.id == f.id));
          });
        },
        onEnd: () {
          setState(() {
            _searching = false;
          });
        });
  }

  void _create() {
    setState(() {
      _creating = true;
    });
    this.ajax(
        url: "saveHashTag",
        authKey: widget.user()?.token,
        server: true,
        method: "POST",
        data: FormData.fromMap({"name": "#${_controller.text}"}),
        onValue: (source, url) => _loadHashTags(query: _controller.text),
        onEnd: () {
          setState(() {
            _creating = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.maybePop(context);
                })
            : null,
        title: Text(
          "Add Tags",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.pop(context, _selected);
              },
              child: Text("Submit"))
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            height: 55,
            child: TextFormField(
              controller: _controller,
              onFieldSubmitted: (s) => _loadHashTags(query: s),
              decoration: InputDecoration(
                  filled: true,
                  hintText: "Please enter the label to search",
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searching ? CupertinoActivityIndicator() : null,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(4)),
                  fillColor: Colors.grey.shade200),
            ),
          ),
          _selected.isNotEmpty
              ? SizedBox.shrink()
              : SizedBox(
                  height: 10,
                ),
          _selected.isNotEmpty
              ? Container(
                  height: 100,
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: _selected.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CircleAvatar(
                                    child: Text("#"),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "${_selected[index].name}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                )
              : SizedBox.shrink(),
          Expanded(
              child: Container(
            color: Colors.white.withOpacity(0.7),
            child: RefreshIndicator(
              key: _key,
              onRefresh: _loadHashTags,
              child: Scrollbar(
                child: _tags.isEmpty && _controller.text.isNotEmpty
                    ? ListView(
                        padding: EdgeInsets.all(40),
                        children: <Widget>[
                          Container(
                            child: ListTileTheme(
                              style: ListTileStyle.drawer,
                              child: ListTile(
                                leading: Text(
                                  "#",
                                  style: TextStyle(fontSize: 30),
                                ),
                                title: Text("${_controller.text}"),
                                subtitle: Text("0 posts"),
                                trailing: _creating
                                    ? CupertinoActivityIndicator()
                                    : RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                      side: BorderSide(
                                          color: Color(0xffFEE606)
                                      )
                                  ),
                                  color: Colors.yellow.shade100,
                                        onPressed: _create,
                                        child: Text("Create"),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _tags.length + 1,
                        itemBuilder: (context, index) {
                          index = index - 1;

                          if (index < 0) {
                            return Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("Recommended Tags"));
                          }

                          var tag = _tags[index];

                          return Container(
                            color: tag.selected ? Colors.grey.shade200 : null,
                            child: ListTileTheme(
                              style: ListTileStyle.drawer,
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    if (tag.selected) {
                                      tag.selected = false;
                                      _selected
                                          .removeWhere((f) => f.id == tag.id);
                                    } else {
                                      if (_selected.length > 8) {
                                        platform.invokeMethod("toast",
                                            "Maximun number of tags is 9");
                                        return;
                                      }

                                      tag.selected = true;
                                      _selected.add(tag);
                                    }
                                  });
                                },
                                leading: Text(
                                  "#",
                                  style: TextStyle(fontSize: 30),
                                ),
                                title: Text("${tag.name}"),
                                subtitle: Text("${tag.count} posts"),
                              ),
                            ),
                          );
                        }),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
