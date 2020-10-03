import 'dart:async';

import 'package:afri_shop/discover_search.dart';
import 'package:afri_shop/following.dart';
import 'package:afri_shop/new_account_screen.dart';
import 'package:afri_shop/new_post.dart';
import 'package:afri_shop/recommended.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';
import 'cart_page.dart';
import 'discover_profile.dart';

class Discover extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;
  final GlobalKey<CartScreenState> cartState;

  const Discover({Key key, this.user, this.callback, this.cartState}) : super(key: key);

  @override
  DiscoverState createState() => DiscoverState();
}

class DiscoverState extends State<Discover> with SuperBase {
  int _index = 0;
  var _followKey = new GlobalKey<FollowingState>();
  var _recommendedKey = new GlobalKey<RecommendedState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      recheck();
    });
  }


  void goToTop(){
    if( _index == 0 )
    _followKey.currentState?.goToTop();
    else
    _recommendedKey.currentState?.goToTop();
  }


  void recheck(){
    print("reach 2");
    setState(() {
      _index = widget.user() == null ? 1 : 0;
    });

    Timer(Duration(seconds: 2), ()=>
        _followKey.currentState?.refresh());

  }

  Future<void> waitUserCheck() async {
    var _user = widget.user();
    if (_user == null) {
      _user = await Navigator.of(context).push(
          CupertinoPageRoute<User>(builder: (context) => AccountScreen(canPop: true,user: widget.user, callback: widget.callback,cartState: widget.cartState,)));
      if (widget.callback != null && _user != null) widget.callback(_user);
      setState(() {});
    }
    return Future.value();
  }


  Widget get recommended =>InkWell(
      onTap: () {
        setState(() {
          _index = 1;
        });
      },
      child: Container(
          margin: EdgeInsets.only(left: 15),
          height: kToolbarHeight,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: _index == 1 ? Colors.grey : Colors.white,
                      width: 3))),
          child: Center(
            child: Text(
              "Recommended",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontFamily: 'Asimov'),
            ),
          )));

  Widget get following =>InkWell(
      onTap: () {
        setState(() {
          _index = 0;
        });
      },
      child: Container(
        height: kToolbarHeight,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: _index == 0 ? Colors.grey : Colors.white,
                    width: 3))),
        child: Center(
          child: Text(
            "Following",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontFamily: 'Asimov'),
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        leading: Align(
          child: InkWell(
              onTap: () async {
                await waitUserCheck();
                if (widget.user() != null)
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => DiscoverProfile(
                                user: widget.user,
                                callback: widget.callback,
                                object: widget.user,
                              )));
              },
              child: Container(
                  height: 24,
                  width: 24,
                  child: Image(
                    image: AssetImage("assets/personal_center.png"),
                    height: 24,
                    width: 24,
                  ))),
        ),
        centerTitle: true,
        title: widget.user()  == null ? Row(
          children: <Widget>[
            Spacer(),
            recommended,
            SizedBox(width: 15),
            following,
            Spacer(),
          ],
        ) : Row(
          children: <Widget>[
            Spacer(),
            following,
            SizedBox(width: 15),
            recommended,
            Spacer(),
          ],
        ),
        actions: <Widget>[
          InkWell(
              onTap: () {
                if (widget.user() != null)
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => DiscoverSearch(
                              user: widget.user, callback: widget.callback)));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Image(
                    image: AssetImage("assets/search.png"),
                    height: 24,
                    width: 24),
              ))
        ],
      ),
      body: IndexedStack(children: <Widget>[
        Following(
          key: _followKey,
          user: widget.user,
          callback: widget.callback,
          cartState: widget.cartState,
        ),
        Recommended(
          key: _recommendedKey,
          user: widget.user,
          callback: widget.callback,
          cartState: widget.cartState,
        ),
      ], index: _index),
      floatingActionButton: widget.user() == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await waitUserCheck();
                if (widget.user() != null) {
                  var s = await Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => NewPostScreen(
                            user: widget.user,
                            callback: widget.callback,
                          )));
                  if (s != null) refreshFollow();
                }
              },
              backgroundColor: color,
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
    );
  }

  void refreshFollow(){
    _followKey.currentState?.refresh(reset: true);
    _recommendedKey.currentState?.refresh();
  }
}
