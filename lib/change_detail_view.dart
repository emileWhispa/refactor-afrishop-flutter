import 'dart:convert';

import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/bonus_detail_list.dart';
import 'package:afri_shop/withdraw_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';

class ChangeDetailView extends StatefulWidget {
  final User Function() user;

  const ChangeDetailView({Key key, this.user}) : super(key: key);

  @override
  _ChangeDetailViewState createState() => _ChangeDetailViewState();
}

class _ChangeDetailViewState extends State<ChangeDetailView> with SuperBase {

  User _user;

  var _key = new GlobalKey<RefreshIndicatorState>();


  Future<void> fetchUser() {
    return this.ajax(
        url: "user/userById/${widget.user()?.id}",
        authKey: widget.user()?.token,
        onValue: (source, url) {

          var js = json.decode(source);
          if( js['code'] == 1) {
            setState(() {
              _user = User.fromJson2(js['data']);
            });
          }
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)=>_key.currentState?.show());
  }

  void _goBonus(){

    Navigator.push(context, CupertinoPageRoute(builder: (context)=>BonusDetailList(user: widget.user)));
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
          actions: <Widget>[
            FlatButton(onPressed: _goBonus, child: Text(
              "Change Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ))
          ],
          centerTitle: true),
      body: Center(
        child: RefreshIndicator(
          key: _key,
          onRefresh: fetchUser,
          child: ListView(
            padding: const EdgeInsets.all(40.0),
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    Image.asset("assets/dollar.png",height: 90,width: 90),
                    SizedBox(height: 10),
                    Text("Amount",style: TextStyle(fontWeight: FontWeight.w900,color: Color(0xff333333)),),
                    SizedBox(height: 10),
                    Text(
                      "\$${(_user ?? widget.user())?.walletStr}",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 170),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: _goBonus,
                  color: color,
                  elevation: 0.5,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Change",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 15),
                child: RaisedButton(
                  elevation: 0.5,
                  onPressed: () async {
                    var dx = await Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => WithdrawScreen(user: widget.user)));
                    if (dx != null) {
                      _key.currentState?.show();
                    }
                  },
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Withdraw",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
