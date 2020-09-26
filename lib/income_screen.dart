import 'dart:convert';

import 'package:afri_shop/Partial/NowBuilder.dart';
import 'package:afri_shop/withdraw_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Bonus.dart';
import 'Json/User.dart';
import 'SuperBase.dart';

class IncomeScreen extends StatefulWidget {
  final User Function() user;

  const IncomeScreen({Key key, @required this.user}) : super(key: key);

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> with SuperBase {
  int _selected = 0;
  double _today = 0.0;
  double _currentMonth = 0.0;
  double _prevMonth = 0.0;
  int _current = 0;
  int _current1 = 0;
  int _current2 = 0;
  List<Bonus> _todayList = [];
  List<Bonus> _currentMonthList = [];
  List<Bonus> _prevMonthList = [];

  List<Bonus> get _bonusList => _selected == 0
      ? _todayList
      : _selected == 1 ? _currentMonthList : _prevMonthList;
  ScrollController _controller = new ScrollController();
  var _key = new GlobalKey<RefreshIndicatorState>();
  User _user;
  List<String> _urls = [];
  bool _loading = false;

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
          if( js['code'] == 1 ) {
            setState(() {
              _user = User.fromJson2(js['data']);
            });
          }
        });
  }

  Future<void> fetchBonuses() async {
    fetchUser();
    this.ajax(
        url:
            "discover/bonus/list/bonus/${widget.user()?.id}/today?pageNo=$_current&pageSize=50",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          if (!_urls.contains(url)) {
            _current++;
            _urls.add(url);
          }
          var map = json.decode(source);
          Iterable js = map['list'];
          setState(() {
            _today = map['total'];
            var list = js.map((f) => Bonus.fromJson(f)).where((element) => !element.withDraw).toList();
            _todayList
              ..removeWhere((f) => list.any((fx) => fx.id == f.id))
              ..addAll(list);
          });
        },
        onEnd: () {});
    this.ajax(
        url:
            "discover/bonus/list/bonus/${widget.user()?.id}/prevMonth?pageNo=$_current1&pageSize=50",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          if (!_urls.contains(url)) {
            _current1++;
            _urls.add(url);
          }
          var map = json.decode(source);
          Iterable js = map['list'];
          setState(() {
            _prevMonth = map['total'];
            var list = js.map((f) => Bonus.fromJson(f)).where((element) => !element.withDraw).toList();
            _prevMonthList
              ..removeWhere((f) => list.any((fx) => fx.id == f.id))
              ..addAll(list);
          });
        },
        onEnd: () {});
    return this.ajax(
        url:
            "discover/bonus/list/bonus/${widget.user()?.discoverId}/currentMonth?pageNo=$_current2&pageSize=50",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          if (!_urls.contains(url)) {
            _current2++;
            _urls.add(url);
          }
          var map = json.decode(source);
          Iterable js = map['list'];
          setState(() {
            _currentMonth = map['total'];
            var list = js.map((f) => Bonus.fromJson(f)).where((element) => !element.withDraw).toList();
            _currentMonthList
              ..removeWhere((f) => list.any((fx) => fx.id == f.id))
              ..addAll(list);
          });
        },
        onEnd: () {});
  }

  List<Widget> get _widgets => [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Today's Commission income last month",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 30),
                Text(
                  "${_today < 0 ? "-" : ""}\$${formatNumber(_today < 0 ? _today * -1 : _today)}",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: Color(0xff4D4D4D)),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Commission income this month",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 30),
                Text(
                  "${_currentMonth < 0 ? "-" : ""}\$${formatNumber(_currentMonth < 0 ? _currentMonth * -1 : _currentMonth)}",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: Color(0xff4D4D4D)),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Commission income last month",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 30),
                Text(
                  "${_prevMonth < 0 ? "-" : ""}\$${formatNumber(_prevMonth < 0 ? _prevMonth * -1 : _prevMonth)}",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: Color(0xff4D4D4D)),
                ),
              ],
            ),
          ),
        ),
      ];

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
        title: Text("My Income"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      _selected = 0;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Today",
                          style: TextStyle(
                              fontWeight: _selected == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      ),
                      SizedBox(
                          width: 30,
                          child: Divider(
                            color: _selected == 0 ? color : Colors.white,
                            height: 2,
                            thickness: 3,
                          ))
                    ],
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      _selected = 1;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text("This month",
                            style: TextStyle(
                                fontWeight: _selected == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SizedBox(
                          width: 30,
                          child: Divider(
                            color: _selected == 1 ? color : Colors.white,
                            height: 2,
                            thickness: 3,
                          ))
                    ],
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      _selected = 2;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text("Last month",
                            style: TextStyle(
                                fontWeight: _selected == 2
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SizedBox(
                          width: 30,
                          child: Divider(
                            color: _selected == 2 ? color : Colors.white,
                            height: 2,
                            thickness: 3,
                          ))
                    ],
                  ),
                )),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            key: _key,
            onRefresh: fetchBonuses,
            child: Scrollbar(
              child: ListView.builder(
                  controller: _controller,
                  itemCount: _bonusList.length + (_loading ? 2 : 1),
                  itemBuilder: (context, index) {
                    index = index - 1;

                    if (index == _bonusList.length) {
                      return _loading
                          ? Center(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 40, horizontal: 10),
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(),
                                  )),
                            )
                          : SizedBox.shrink();
                    }

                    if (index < 0)
                      return Container(
                        margin: EdgeInsets.only(bottom: 50),
                        child: IndexedStack(
                          children: _widgets,
                          index: _selected,
                        ),
                      );
                    var bonus = _bonusList[index];
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
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var dx = await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => WithdrawScreen(user: widget.user)));
          if (dx != null) {
            _key.currentState?.show();
          }
        },
        label: Text("Withdraw"),
        backgroundColor: color,
      ),
    );
  }
}
