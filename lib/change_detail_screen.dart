import 'dart:convert';

import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/change_detail_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';

class NetworkScreen extends StatefulWidget {
  final User Function() user;

  const NetworkScreen({Key key, @required this.user}) : super(key: key);

  @override
  _NetworkScreenState createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> with SuperBase {
  var _key = new GlobalKey<RefreshIndicatorState>();
  List<User> _list = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _key.currentState?.show());
  }

  Future<void> _loadNetworks() {
    return this.ajax(
        url:
            "discover/networking/networksByUserId/${widget.user()?.id}?pageNo=0&pageSize=50",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          print(url);
          Iterable map = json.decode(source);
          setState(() {
            _list = map.map((f) => User.fromJson2(f)).toList();
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
            "My Networks",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true),
      body: RefreshIndicator(
        key: _key,
        onRefresh: _loadNetworks,
        child: Scrollbar(
          child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, index) {
                var _user = _list[index];
                return InkWell(
                  onTap: () {
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    margin: EdgeInsets.only(bottom: 6),
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: _user?.avatar == null ? defLoader : CachedNetworkImageProvider(_user.avatar),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text("${_user?.username}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
//                                    Text("\$${_user.networkAmountStr}",
//                                        style: TextStyle(
//                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text(
                                      "${_user?.slogan ?? "..."}",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
