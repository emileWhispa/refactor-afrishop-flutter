import 'dart:convert';

import 'package:afri_shop/Json/Post.dart';
import 'package:afri_shop/Partial/NowBuilder.dart';
import 'package:afri_shop/Partial/follow_button.dart';
import 'package:afri_shop/Partial/list_item.dart';
import 'package:afri_shop/edit_material.dart';
import 'package:afri_shop/follow_management.dart';
import 'package:afri_shop/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bezier_chart/bezier_chart.dart';

import 'Json/Bonus.dart';
import 'Json/User.dart';
import 'SuperBase.dart';

class DiscoverProfile extends StatefulWidget {
  final User Function() user;
  final User Function() object;
  final void Function(User user) callback;
  final bool liked;

  const DiscoverProfile(
      {Key key,
      @required this.user,
      @required this.object,
      @required this.callback, this.liked:false})
      : super(key: key);

  @override
  _DiscoverProfileState createState() => _DiscoverProfileState();
}

class _DiscoverProfileState extends State<DiscoverProfile> with SuperBase {
  var _index = 0;
  User _user;

  List<Post> _list = [];
  List<Post> _list2 = [];

  List<Post> get list => _index == 0 ? _list : _list2;

  List<Bonus> _bonusList = [];
  List<Bonus> _bonusSmallList = [];

  var global = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = widget.user();
    _index = widget.liked ? 1 : 0;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => global.currentState?.show(atTop: true));
  }

  var _currentUrl = "";

  Widget sample2(BuildContext context) {
    return Center(
      child: Container(
        //height: MediaQuery.of(context).size.height / 4.8,
        width: MediaQuery.of(context).size.width,
        child: BezierChart(
          bezierChartScale: BezierChartScale.CUSTOM,
          xAxisCustomValues: const [0, 3, 10, 15, 20, 25, 30, 35],
          series: const [
            BezierLine(
              label: "Custom 1",
              data: const [
                DataPoint<double>(value: 10, xAxis: 0),
                DataPoint<double>(value: 130, xAxis: 5),
                DataPoint<double>(value: 50, xAxis: 10),
                DataPoint<double>(value: 150, xAxis: 15),
                DataPoint<double>(value: 75, xAxis: 20),
                DataPoint<double>(value: 0, xAxis: 25),
                DataPoint<double>(value: 5, xAxis: 30),
                DataPoint<double>(value: 45, xAxis: 35),
              ],
            ),
            BezierLine(
              lineColor: Colors.blue,
              lineStrokeWidth: 2.0,
              label: "Custom 2",
              data: const [
                DataPoint<double>(value: 5, xAxis: 0),
                DataPoint<double>(value: 50, xAxis: 5),
                DataPoint<double>(value: 30, xAxis: 10),
                DataPoint<double>(value: 30, xAxis: 15),
                DataPoint<double>(value: 50, xAxis: 20),
                DataPoint<double>(value: 40, xAxis: 25),
                DataPoint<double>(value: 10, xAxis: 30),
                DataPoint<double>(value: 30, xAxis: 35),
              ],
            ),
            BezierLine(
              lineColor: Colors.black,
              lineStrokeWidth: 2.0,
              label: "Custom 3",
              data: const [
                DataPoint<double>(value: 5, xAxis: 0),
                DataPoint<double>(value: 10, xAxis: 5),
                DataPoint<double>(value: 35, xAxis: 10),
                DataPoint<double>(value: 40, xAxis: 15),
                DataPoint<double>(value: 40, xAxis: 20),
                DataPoint<double>(value: 40, xAxis: 25),
                DataPoint<double>(value: 9, xAxis: 30),
                DataPoint<double>(value: 11, xAxis: 35),
              ],
            ),
          ],
          config: BezierChartConfig(
            verticalIndicatorStrokeWidth: 2.0,
            verticalIndicatorColor: Colors.black12,
            showVerticalIndicator: true,
            contentWidth: MediaQuery.of(context).size.width * 2,
            backgroundGradient: LinearGradient(colors: [
              Colors.amber.shade300,
              Colors.amber.shade400,
              Colors.amber.shade500,
              Colors.amber.shade600,
              Colors.amber.shade700,
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> fetchUser() {
    fetchBonuses();
    return this.ajax(
        url: "user/userById/${_user?.id}",
        authKey: widget.object()?.token,
        onValue: (source, url) {
          var map = json.decode(source);
          if( map['code'] == 1) {
            var js = map['data'];
            setState(() {
              _user = User.fromJson2(js);
            });
          }
        });
  }

  bool _loadingBonuses = true;

  Future<void> fetchBonuses() {
    setState(() {
      _loadingBonuses = true;
    });
    return this.ajax(
        url: "discover/post/list/bonus/${widget.user()?.id}?pageNo=0&pageSize=50",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          Iterable js = json.decode(source);
          setState(() {
            _loadingBonuses = false;
            _bonusList = js.map((f) => Bonus.fromJson(f)).toList();
            _bonusSmallList = _bonusList.take(2).toList();
          });
        },
        onEnd: () {
          setState(() {
            _loadingBonuses = false;
          });
        });
  }

  Future<void> _loadPosts() async {
    fetchUser();
    await this.ajax(
        url:
            "discover/post/listPostsByUser/${widget.user()?.id}?pageNo=0&pageSize=100",
        authKey: widget.object()?.token,
        onValue: (source, url) {
          print(url);
          _currentUrl = url;
          Iterable map = json.decode(source);
          setState(() {
            _list = map.map((f) => Post.fromJson(f)).toList();
          });
        },
        error: (s, v) => print(s));
    await this.ajax(
        url:
            "discover/post/listPostsLiked/${widget.user()?.id}?pageNo=0&pageSize=100",
        authKey: widget.object()?.token,
        onValue: (source, url) {
          Iterable map = json.decode(source);
          setState(() {
            _list2 = map.map((f) => Post.fromJson(f)).toList();
          });
        },
        error: (s, v) => print(s));
  }

  Widget sample1(BuildContext context, {bool data1: true}) {
    return ClipRRect(
      //borderRadius: BorderRadius.only(bottomRight: Radius.circular(4.5),bottomLeft: Radius.circular(4.5)),
      child: Container(
        //height: MediaQuery.of(context).size.height / 3.56,
        width: MediaQuery.of(context).size.width,
        child: BezierChart(
          bezierChartScale: BezierChartScale.CUSTOM,
          xAxisCustomValues:
              data1 ? [0, 5, 10, 15, 20, 25, 30, 35] : [0, 6, 16, 25, 30, 35],
          series: [
            BezierLine(
              data: data1
                  ? [
                      DataPoint<double>(value: 10, xAxis: 0),
                      DataPoint<double>(value: 130, xAxis: 5),
                      DataPoint<double>(value: 50, xAxis: 10),
                      DataPoint<double>(value: 150, xAxis: 15),
                      DataPoint<double>(value: 75, xAxis: 20),
                      DataPoint<double>(value: 0, xAxis: 25),
                      DataPoint<double>(value: 5, xAxis: 30),
                      DataPoint<double>(value: 45, xAxis: 35),
                    ]
                  : [
                      DataPoint<double>(value: 10, xAxis: 0),
                      DataPoint<double>(value: 130, xAxis: 5),
                      DataPoint<double>(value: 50, xAxis: 10),
                      DataPoint<double>(value: 150, xAxis: 15),
                      DataPoint<double>(value: 75, xAxis: 20),
                      DataPoint<double>(value: 0, xAxis: 25),
                    ],
            ),
          ],
          config: BezierChartConfig(
            verticalIndicatorStrokeWidth: 3.0,
            verticalIndicatorColor: Colors.black26,
            showVerticalIndicator: true,
            backgroundGradient: LinearGradient(colors: [
              Colors.grey.shade100,
              Colors.grey.shade200,
              Colors.grey.shade300,
              Colors.grey.shade400,
              Colors.grey.shade500
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            snap: false,
          ),
        ),
      ),
    );
  }

  bool get isMe => widget.user()?.id == widget.object()?.id;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("${widget.user()?.username}"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: global,
        onRefresh: _loadPosts,
        child: ListView.builder(
          itemCount: list.length + 3,
          itemBuilder: (context, index) {
            index = index - 3;
            if (index == -3)
              return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.2, 0.5),
                        blurRadius: 1.2)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            showGeneralDialog(
                                context: context,
                                barrierColor: Colors.black12.withOpacity(0.6),
                                // background color
                                barrierDismissible: true,
                                // should dialog be dismissed when tapped outside
                                barrierLabel: "Dialog",
                                // label for barrier
                                transitionDuration: Duration(milliseconds: 400),
                                // how long it takes to popup dialog after button click
                                pageBuilder: (_, __, ___) {
                                  return Center(
                                    child: FadeInImage(
                                        image: widget.user()?.avatar != null
                                            ? CachedNetworkImageProvider(
                                            widget.user().avatar)
                                            : AssetImage(
                                            "assets/account_user.png"),
                                        placeholder: defLoader,
                                        fit: BoxFit.contain),
                                  );
                                },
                                transitionBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var wasCompleted = false;
                                  if (animation.status ==
                                      AnimationStatus.completed) {
                                    wasCompleted = true;
                                  }

                                  if (wasCompleted) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  } else {
                                    return SlideTransition(
                                      position: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      ).drive(Tween<Offset>(
                                          begin: Offset(0, -1.0),
                                          end: Offset.zero)),
                                      child: child,
                                    );
                                  }
                                });
                          },
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: CachedNetworkImageProvider(
                                widget.user()?.avatar ??''),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.5),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Text("${_user.posts}"),
                                        Text("Posts",
                                            style: TextStyle(
                                                fontFamily: 'DIN Alternate',
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    FollowManagement(
                                                      user: widget.user,
                                                      object: widget.object,
                                                      callback: widget.callback,
                                                    )));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Text("${_user.followers}"),
                                          Text("Followers",
                                              style: TextStyle(
                                                  fontFamily: 'DIN Alternate',
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    FollowManagement(
                                                      user: widget.user,
                                                      index: 1,
                                                      object: widget.object,
                                                      callback: widget.callback,
                                                    )));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Text("${_user.following}"),
                                          Text(
                                            "Following",
                                            style: TextStyle(
                                                fontFamily: 'DIN Alternate',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 7),
                              SizedBox(
                                width: double.infinity,
                                child: isMe
                                    ? FlatButton(
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  fullscreenDialog: true,
                                                  builder: (context) =>
                                                      UserProfile(
                                                          callback:
                                                              widget.callback,
                                                          user:
                                                              widget.object)));
                                        },
                                        child: Text("Edit Materials"))
                                    : FollowButton(
                                        follower: widget.object(),
                                        object: widget.object,
                                        followed: widget.user()),
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: InkWell(
                          onTap: isMe
                              ? () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => EditMaterial(
                                              object: widget.object,
                                              callback: widget.callback)));
                                }
                              : null,
                          child: RichText(
                              text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "${_user?.slogan ?? (isMe ? "Please fill in a personalized signature" : "")}",
                                style: TextStyle(
                                    color: Color(0xff999999),
                                    fontSize: 15.5,
                                    fontFamily: 'Futura'),
                              ),
                              isMe
                                  ? WidgetSpan(
                                      child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4.0, bottom: 0.0),
                                      child: Icon(
                                        Icons.mode_edit,
                                        size: 17,
                                        color: Color(0xff999999),
                                      ),
                                    ))
                                  : TextSpan(text: "")
                            ],
                          )),
                        )),
                  ],
                ),
              );

            if (index == -2)
              return SizedBox.shrink();
//              return Container(
//                height: 300,
//                padding: EdgeInsets.all(5).copyWith(top: 0),
//                child: Card(
//                  child: DefaultTabController(
//                      length: 2,
//                      child: Column(
//                        children: <Widget>[
//                          TabBar(
//                              labelStyle:
//                                  TextStyle(fontWeight: FontWeight.bold),
//                              unselectedLabelStyle:
//                                  TextStyle(fontWeight: FontWeight.normal),
//                              tabs: [
//                                Tab(
//                                    child: Row(
//                                  children: <Widget>[
//                                    Text(
//                                      "Income",
//                                      style: TextStyle(),
//                                    ),
//                                    Text(
//                                      "(\$${(_user.wallet ?? 0.0).toStringAsFixed(2)})",
//                                      style: TextStyle(
//                                          color: Colors.grey,
//                                          fontWeight: FontWeight.bold),
//                                    )
//                                  ],
//                                )),
//                                Tab(
//                                  child: Row(
//                                    children: <Widget>[
//                                      Text(
//                                        "Views",
//                                        style: TextStyle(),
//                                      ),
//                                      Text(
//                                        "(${(_user.visits ?? 0)})",
//                                        style: TextStyle(
//                                            color: Colors.grey,
//                                            fontWeight: FontWeight.bold),
//                                      )
//                                    ],
//                                  ),
//                                ),
//                              ]),
//                          Expanded(
//                            child: TabBarView(
//                              children: <Widget>[
//                                Container(
//                                  width: double.infinity,
//                                  child: Column(
//                                    mainAxisAlignment: MainAxisAlignment.center,
//                                    children: <Widget>[
//                                      Expanded(child: sample1(context)),
//                                      _loadingBonuses
//                                          ? Padding(
//                                              padding:
//                                                  const EdgeInsets.all(8.0),
//                                              child:
//                                                  CircularProgressIndicator(),
//                                            )
//                                          : Padding(
//                                              padding:
//                                                  const EdgeInsets.all(8.0),
//                                              child: Column(
//                                                children: _bonusSmallList
//                                                    .map((f) => Padding(
//                                                          padding:
//                                                              const EdgeInsets
//                                                                      .symmetric(
//                                                                  vertical:
//                                                                      8.0),
//                                                          child: Row(
//                                                            children: <Widget>[
//                                                              NowBuilder(
//                                                                date:
//                                                                    f.dateTime,
//                                                                style: TextStyle(
//                                                                    fontWeight:
//                                                                        FontWeight
//                                                                            .bold),
//                                                              ),
//                                                              Expanded(
//                                                                  child:
//                                                                      Padding(
//                                                                padding: const EdgeInsets
//                                                                        .symmetric(
//                                                                    horizontal:
//                                                                        4.0),
//                                                                child: Text(
//                                                                  "${f.title}",
//                                                                  maxLines: 1,
//                                                                  overflow:
//                                                                      TextOverflow
//                                                                          .ellipsis,
//                                                                ),
//                                                              )),
//                                                              Text(
//                                                                "\$${f.amountStr}",
//                                                                maxLines: 1,
//                                                                overflow:
//                                                                    TextOverflow
//                                                                        .ellipsis,
//                                                                style: TextStyle(
//                                                                    color: Colors
//                                                                        .grey),
//                                                              ),
//                                                            ],
//                                                          ),
//                                                        ))
//                                                    .toList(),
//                                              ),
//                                            ),
//                                      _bonusList.length > 2
//                                          ? InkWell(
//                                              child: Icon(
//                                                  Icons.keyboard_arrow_down),
//                                              onTap: () {
//                                                showModalBottomSheet(
//                                                    context: context,
//                                                    backgroundColor:
//                                                        Colors.transparent,
//                                                    builder: (context) {
//                                                      return Container(
//                                                        decoration: BoxDecoration(
//                                                            color: Colors.white,
//                                                            borderRadius: BorderRadius.only(
//                                                                topLeft: Radius
//                                                                    .circular(
//                                                                        6),
//                                                                topRight: Radius
//                                                                    .circular(
//                                                                        6))),
//                                                        child: ListView.builder(
//                                                            padding:
//                                                                EdgeInsets.all(
//                                                                    14),
//                                                            itemCount:
//                                                                _bonusList
//                                                                    .length,
//                                                            itemBuilder:
//                                                                (context,
//                                                                    index) {
//                                                              var f =
//                                                                  _bonusList[
//                                                                      index];
//                                                              return Padding(
//                                                                padding: const EdgeInsets
//                                                                        .symmetric(
//                                                                    vertical:
//                                                                        8.0),
//                                                                child: Row(
//                                                                  children: <
//                                                                      Widget>[
//                                                                    NowBuilder(
//                                                                      date: f
//                                                                          .dateTime,
//                                                                      style: TextStyle(
//                                                                          fontWeight:
//                                                                              FontWeight.bold),
//                                                                    ),
//                                                                    Expanded(
//                                                                        child:
//                                                                            Padding(
//                                                                      padding: const EdgeInsets
//                                                                              .symmetric(
//                                                                          horizontal:
//                                                                              4.0),
//                                                                      child:
//                                                                          Text(
//                                                                        "${f.title}",
//                                                                        maxLines:
//                                                                            1,
//                                                                        overflow:
//                                                                            TextOverflow.ellipsis,
//                                                                      ),
//                                                                    )),
//                                                                    Text(
//                                                                      "\$${f.amountStr}",
//                                                                      maxLines:
//                                                                          1,
//                                                                      overflow:
//                                                                          TextOverflow
//                                                                              .ellipsis,
//                                                                      style: TextStyle(
//                                                                          color:
//                                                                              Colors.grey),
//                                                                    ),
//                                                                  ],
//                                                                ),
//                                                              );
//                                                            }),
//                                                      );
//                                                    });
//                                              })
//                                          : SizedBox.shrink()
//                                    ],
//                                  ),
//                                ),
//                                Container(
//                                  //width: double.infinity,
//                                  height: 90,
//                                  child: Column(
//                                    children: <Widget>[
//                                      Container(
//                                          height: 133,
//                                          child:
//                                              sample1(context, data1: false)),
//                                    ],
//                                  ),
//                                ),
//                              ],
//                            ),
//                          ),
//                        ],
//                      )),
//                ),
//              );

            if (index == -1)
              return Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.2, 0.5),
                        blurRadius: 1.2)
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    InkWell(
                        onTap: () {
                          setState(() {
                            _index = 0;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: _index == 0
                                          ? Colors.black
                                          : Colors.white,
                                      width: 2))),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Posts",
                            style:
                                TextStyle(fontSize: 15, fontFamily: 'Asimov'),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        "(${_list.length})",
                        style:
                            TextStyle(color: Colors.grey, fontFamily: 'Futura'),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          setState(() {
                            _index = 1;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: _index == 1
                                          ? Colors.black
                                          : Colors.white,
                                      width: 2))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Like",
                                style: TextStyle(
                                    fontFamily: 'Asimov', fontSize: 15)),
                          ),
                        )),
                    Text("(${_list2.length})",
                        style: TextStyle(
                            color: Colors.grey, fontFamily: 'Futura')),
                    Spacer(),
                  ],
                ),
              );

            var post = list[index];

            return ListItem(
              post: post,
              user: widget.object,
              likePost: (status) {
                post.liked = status.liked;
                post.likes = status.likes;
                save(_currentUrl, _list);
              },
              delete: () {
                setState(() {
                  _list.remove(post);
                });
                save(_currentUrl, _list);
                deletePost(post);
              },
              callback: widget.callback,
            );
          },
        ),
      ),
    );
  }
}
