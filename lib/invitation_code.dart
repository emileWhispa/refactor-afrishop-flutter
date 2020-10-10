import 'dart:convert';

import 'package:afri_shop/confirm_invitation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Json/User.dart';
import 'SuperBase.dart';

class InvitationCode extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;
  final String code;

  const InvitationCode({Key key, @required this.user, @required this.callback, this.code})
      : super(key: key);

  @override
  _InvitationCodeState createState() => _InvitationCodeState();
}

class _InvitationCodeState extends State<InvitationCode> with SuperBase {
  bool _valid = false;
  TextEditingController _controller = new TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if( widget.code != null){
      _controller = new TextEditingController(text: widget.code);
      _valid = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if( widget.code != null){
        _doFind();
      }
    });
  }

  void _doFind() {
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "user/userByCode/${Uri.encodeComponent(_controller.text)}",
        server: true,
        authKey: widget.user()?.token,
        onValue: (source, url) async {
          var jx = json.decode(source);
          if (jx['code'] == 1) {
            var inv = User.fromJson2(jx['data']);
            if( inv.invited ){
           var d = await Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ConfirmInvitation(
                          user: widget.user,
                          callback: widget.callback,
                          inviter: inv),
                        ));
           if( d != null){
             Navigator.pop(context,d);
           }
          }else{
              showFail("User cannot invite");
          }
          }else{
            showFail(jx['message']);
          }
        },
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }


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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                "Please enter the invitation code",
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey),
              ),
              SizedBox(height: 25),
              TextFormField(
                controller: _controller,
                onChanged: (s) {
                  if (_valid && s.length != 6) {
                    setState(() {
                      _valid = false;
                    });
                  } else if (!_valid && s.length == 6) {
                    setState(() {
                      _valid = true;
                    });
                  }
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  filled: true,
                  hintText: "Invitation code",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 25),
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.orange),
                      children: [
                    WidgetSpan(
                        child: Icon(
                      Icons.help,
                      color: Colors.orange,
                      size: 14,
                    )),
                    TextSpan(
                      text: " Please enter the invitation code",
                    ),
                  ])),
              SizedBox(height: 170),
              _sending
                  ? CupertinoActivityIndicator()
                  : Container(
                      width: double.infinity,
                      child: RaisedButton(
                        elevation: 0.0,
                        onPressed: _valid ? _doFind : null,
                        color: _valid ? color : Color(0xffCCCCCC),
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Submit",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
