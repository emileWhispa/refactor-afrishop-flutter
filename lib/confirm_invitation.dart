import 'package:afri_shop/SuperBase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';

class ConfirmInvitation extends StatefulWidget {
  final User Function() user;
  final User inviter;
  final void Function(User user) callback;

  const ConfirmInvitation(
      {Key key,
      @required this.user,
      @required this.callback,
      @required this.inviter})
      : super(key: key);

  @override
  _ConfirmInvitationState createState() => _ConfirmInvitationState();
}

class _ConfirmInvitationState extends State<ConfirmInvitation> with SuperBase {
  bool _sending = false;

  void showFail(String fail) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image(
                    height: 120,
                    fit: BoxFit.cover,
                    image: AssetImage("assets/logo_black.png")),
                SizedBox(height: 20),
                Text("$fail",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19))
              ],
            ),
          );
        });
  }

  void _invite() {
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "discover/networking/saveNetwork",
        authKey: widget.user()?.token,
        server: true,
        method: "POST",
        data: FormData.fromMap({
          "userInfo": widget.inviter?.id,
          "networkInfo": widget.user()?.id,
        }),
        error: (s, v) => this.showFail("Connection error"),
        onValue: (source, url) {
          Navigator.pop(context, "data");
        },
        onEnd: () {
          setState(() {
            _sending = true;
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
            "Member",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Text(
                "Confirm inviter information",
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.grey),
              ),
              SizedBox(height: 25),
              CircleAvatar(
                radius: 50,
              
                backgroundImage:  AssetImage("assets/africa_logo.png"),
                    
              ),
              SizedBox(height: 25),
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.orange),
                      children: [
                    TextSpan(
                      text: "Inviter",
                    ),
                  ])),
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.orange),
                      children: [
                    TextSpan(
                      text: "${widget.inviter?.username ?? "..."}",
                    ),
                  ])),
              SizedBox(height: 150),
              Container(
                width: double.infinity,
                child: _sending
                    ? CupertinoActivityIndicator()
                    : RaisedButton(
                        onPressed: _invite,
                        padding: EdgeInsets.all(16),
                        color: color,
                        elevation: 0.4,
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
