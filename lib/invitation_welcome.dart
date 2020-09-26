import 'package:afri_shop/invitation_code.dart';
import 'package:afri_shop/invitation_success.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class InvitationWelcome extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const InvitationWelcome(
      {Key key, @required this.user, @required this.callback})
      : super(key: key);

  @override
  _InvitationWelcomeState createState() => _InvitationWelcomeState();
}

class _InvitationWelcomeState extends State<InvitationWelcome> with SuperBase {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var s = TextStyle(color: Color(0xff666666));
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
            "Member",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Text(
                "Member’s Privilege",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
              ),
            ),
            Text("Become a member and get permission.", style: s),
            Text("1. Get 10% commission on platform shopping;", style: s),
            Text("2. Permission to become a distributor;", style: s),
            Text("3. Share products, get commissions for successful sales;",
                style: s),
            SizedBox(height: 30),
            Text(
                "Fill in the referral invitation code, you can directly pass the review",
                style: s),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () async {
                          var d = await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => InvitationCode(
                                      user: widget.user,
                                      callback: widget.callback)));
                          if (d != null) {
                            Navigator.pop(context, d);
                          }
                        },
                        color: color,
                        elevation: 0.6,
                        child: Text(
                          "My Invitation Code",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      )),
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      child: _saving
                          ? Center(child: CupertinoActivityIndicator())
                          : RaisedButton(
                              onPressed: goSuccess,
                              elevation: 0.6,
                              child: Text(
                                "Application for Membership",
                                style: TextStyle(
                                    color: Color(0xff666666),
                                    fontWeight: FontWeight.w900),
                              ),
                            )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void goSuccess() async {
    setState(() {
      _saving = true;
    });
    this.ajax(
        url: "discover/invitation/saveInvitationRequest",
        method: "POST",
        authKey: widget.user()?.token,
        data: FormData.fromMap({"userInfo": widget.user()?.id}),
        onValue: (source, url) async {
          var d = await Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (context) => InvitationSuccess(
                      user: widget.user, callback: widget.callback)));
          if (d != null) {
            Navigator.pop(context, d);
          }
        },
        onEnd: () {
          setState(() {
            _saving = false;
          });
        });
  }
}
