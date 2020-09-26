import 'dart:convert';

import 'package:afri_shop/ContactUs.dart';
import 'package:afri_shop/about_information.dart';
import 'package:afri_shop/feedback.dart';
import 'package:afri_shop/account_security.dart';
import 'package:afri_shop/frequent_question.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class Support extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const Support({Key key, @required this.user,@required this.callback}) : super(key: key);

  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> with SuperBase {

  bool get _invited => (_user ?? widget.user())?.invited == true;

  User _user;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)=>this.fetchUser());
  }


  Future<void> fetchUser() {
    return this.ajax(
        url: "user/userById/${widget.user()?.id}",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          var js = json.decode(source);
          setState(() {
            _user = User.fromJson2(js);
            widget.user()?.code = _user.code;
          });
        });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.5,
        fontFamily: 'SF UI Display');
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
          "Support",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          InkWell(
            onTap: (){
              Share.share("https://play.google.com/store/apps/details?id=io.dcloud.H52FE1175&hl=en ${_invited ? "please use my invitation code: ${( _user ?? widget.user())?.code}, to become afrishop member and enjoy a 10% discount" : ""} ",subject: "Share subject");
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Image.asset("assets/account_share.png", height: 24, width: 24),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Share",
                      style: style,
                    ),
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => AccountSecurity(user: widget.user,callback: widget.callback,)));
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Image.asset("assets/account_ver.png", height: 24, width: 24),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Account Security",
                      style: style,
                    ),
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => FrequentQuestion(
                        user: widget.user(),
                      )));
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Image.asset("assets/account_faq.png"),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "FAQ",
                      style: style,
                    ),
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => ContactUs(
                        user: widget.user(),
                      )));
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.call,
                    size: 26,
                    color: color,
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Contact",
                      style: style,
                    ),
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => FeedbackScreen(
                        user: widget.user(),
                      )));
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Image.asset("assets/account_feedback.png",
                      height: 24, width: 24),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Feedback",
                      style: style,
                    ),
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => AboutInformation()));
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Image.asset("assets/account_about.png",
                      height: 24, width: 24),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "About afrishop",
                      style: style,
                    ),
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return  _SignOut(user: widget.user);
                  });
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Image.asset("assets/account_log_out.png",
                      height: 24, width: 24),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Sign out",
                      style: style,
                    ),
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignOut extends StatefulWidget {
  final User Function() user;

  const _SignOut({Key key, @required this.user}) : super(key: key);

  @override
  __SignOutState createState() => __SignOutState();
}

class __SignOutState extends State<_SignOut> with SuperBase {
  bool _requesting = false;

  void signOut() async {
    setState(() {
      _requesting = true;
    });
    (await prefs).clear();
    Navigator.of(context).pop();
    Navigator.of(context).pop("result");
    this.ajax(
        url: "logout",
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        onValue: (s, v) async {
        },
        error: (s,v)=>print(s),
        onEnd: () {
          setState(() {
            _requesting = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      contentPadding: EdgeInsets.all(5),
      title: Text("Confirm Logout?",
          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _requesting ? Center(child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: CupertinoActivityIndicator(),
          ),) : Row(
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  onPressed: signOut,
                  color: Colors.white,
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0.7,
                  child: Text(
                    "Logout",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.red),
                  ),
                ),
              )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  color: color,
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0.7,
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              )),
            ],
          )
        ],
      ),
    );
  }
}
