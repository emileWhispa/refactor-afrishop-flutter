import 'dart:convert';

import 'package:afri_shop/Partial/NowBuilder.dart';
import 'package:afri_shop/withdraw_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Bonus.dart';
import 'Json/User.dart';
import 'SuperBase.dart';

class BonusDetailList extends StatefulWidget {
  final User Function() user;

  const BonusDetailList({Key key, @required this.user}) : super(key: key);

  @override
  _BonusDetailListState createState() => _BonusDetailListState();
}

class _BonusDetailListState extends State<BonusDetailList> with SuperBase {
  List<Bonus> _todayList = []; 

  ScrollController _controller = new ScrollController();
  var _key = new GlobalKey<RefreshIndicatorState>();
  User _user;
  List<String> _urls = [];
  bool _loading = false;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _key.currentState?.show());
    _controller.addListener(() async {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        setState(() {
          _loading = true;
        });
        await fetchBonuses();
        setState(() {
          _loading = false;
        });
      }
    });
  }

  Future<void> fetchUser() {
    return this.ajax(
        url: "user/userById/${widget.user()?.id}",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          var js = json.decode(source);
          setState(() {
            _user = User.fromJson2(js);
          });
        });
  }

  Future<void> fetchBonuses() async {
    fetchUser();
    return this.ajax(
        url:
        "discover/bonus/list/bonus/${widget.user()?.id}?pageNo=$_current&pageSize=50",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          if (!_urls.contains(url)) {
            _current++;
            _urls.add(url);
          }
          Iterable map = json.decode(source);
          setState(() {
            var list = map.map((f) => Bonus.fromJson(f)).toList();
            _todayList
              ..removeWhere((f) => list.any((fx) => fx.id == f.id))
              ..addAll(list);
          });
        },
        onEnd: () {});

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
        title: Text("Change details"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: _key,
        onRefresh: fetchBonuses,
        child: Scrollbar(
          child: ListView.builder(
              controller: _controller,
              itemCount: _todayList.length + 1,
              itemBuilder: (context, index) {

                if (index == _todayList.length) {
                  return Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 40, horizontal: 10),
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: _loading
                              ? CircularProgressIndicator() : SizedBox.shrink(),
                        )),
                  );
                }

                var bonus = _todayList[index];
                return Container(
                  decoration: BoxDecoration(color: Colors.white),
                  margin: EdgeInsets.only(bottom: 6),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: bonus.withDraw
                            ? Image.asset(
                          "assets/withdraw.png",
                          height: 25,
                          width: 25,
                          color: Colors.red,
                        )
                            : null,
                        backgroundImage: bonus.withDraw
                            ? null
                            : bonus.url == null
                            ? defLoader
                            : CachedNetworkImageProvider(bonus.url),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${bonus.title}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                TextStyle(fontWeight: FontWeight.bold),
                              ),
                              NowBuilder(date: bonus.dateTime),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "${bonus.amountStr}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                  bonus.withDraw ? Colors.red : null),
                            ),
                            Text(
                              bonus.pendingStatus,
                              style: TextStyle(
                                  color: bonus.status
                                      ? Colors.green
                                      : Colors.grey),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      )
    );
  }
}
