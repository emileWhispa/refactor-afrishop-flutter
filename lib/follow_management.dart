import 'dart:convert';

import 'package:afri_shop/Partial/follow_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';
import 'discover_profile.dart';

class FollowManagement extends StatefulWidget {
  final User Function() user;
  final User Function() object;
  final void Function(User user) callback;
  final int index;

  const FollowManagement(
      {Key key,
      @required this.user,
      this.index: 0,
      @required this.object,
      @required this.callback})
      : super(key: key);

  @override
  _FollowManagementState createState() => _FollowManagementState();
}

class _FollowManagementState extends State<FollowManagement> with SuperBase {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _index = widget.index;
    WidgetsBinding.instance.addPostFrameCallback((_) => this.refresh());
  }

  void refresh() {
    key.currentState?.show(atTop: true);
  }

  Future<void> _refresh() {
    this.ajax(
        url: "discover/follow/listFollowing/${widget.user()?.id}",
        authKey: widget.object()?.token,
        onValue: (source, url) {
          Iterable map = jsonDecode(source);
          setState(() {
            _list1 = map.map((f) => User.fromJson2(f)).toList();
          });
        },
        error: (s, v) => print(s));
    return this.ajax(
        url: "discover/follow/listFollowers/${widget.user()?.id}",
        authKey: widget.object()?.token,
        onValue: (source, url) {
          Iterable map = jsonDecode(source);
          setState(() {
            _list0 = map.map((f) => User.fromJson2(f)).toList();
          });
        },
        error: (s, v) => print(s));
  }

  var key = new GlobalKey<RefreshIndicatorState>();

  List<User> _list0 = [];
  List<User> _list1 = [];

  List<User> get _list => _index == 0 ? _list0 : _list1;

  Widget _tit(int has, String title, GlobalKey key) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 17),
        decoration: has == _index
            ? BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.black, width: 4)))
            : null,
        child: Center(
          child: Text(
            title,
            maxLines: 1,
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _index = has;
        });
      },
    );
  }

  int _index = 0;

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
        title: Row(
          children: <Widget>[
            Expanded(child: _tit(0, "Followers", null)),
            Expanded(child: _tit(1, "Following", null)),
          ],
        ),
      ),
      body: RefreshIndicator(
        key: key,
        onRefresh: _refresh,
        child: Scrollbar(
          child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade300,
                    height: 1,
                  ),
              itemCount: _list.length,
              itemBuilder: (context, i) {
                var p = _list[i];
                return ListTileTheme(
                  style: ListTileStyle.drawer,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => DiscoverProfile(
                                    user: () => p,
                                    callback: widget.callback,
                                    object: widget.object,
                                  )));
                    },
                    leading: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider("${p.avatar}"),
                    ),
                    title: Text(
                      "${p.username}",
                      style: TextStyle(
                          fontFamily: 'DIN Alternate',
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${p?.slogan ?? "..."} ",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: FollowButton(
                      follower: widget.object(),
                      followed: p,
                      object: widget.object,
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
