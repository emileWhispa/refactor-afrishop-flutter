import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class EmailSecurity extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const EmailSecurity({Key key, @required this.user, @required this.callback})
      : super(key: key);

  @override
  _EmailSecurityState createState() => _EmailSecurityState();
}

class _EmailSecurityState extends State<EmailSecurity> with SuperBase {
  Duration _duration = new Duration(seconds: 0);
  Timer _timer;
  bool _sending = false;
  bool _sending2 = false;
  bool _valid = false;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _controller = new TextEditingController();

  String get email => "${_emailController.text}";

  void showSuccess() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image(
                    height: 120,
                    fit: BoxFit.cover,
                    image: AssetImage("assets/logo_circle.png")),
                SizedBox(height: 20),
                Text("Email changed successfully",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))
              ],
            ),
          );
        });
    Navigator.of(context).pop();
  }

  var _formKey = new GlobalKey<FormState>();

  void _change() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _sending2 = true;
    });
    reqFocus(context);
    this.ajax(
        url:
            "user/bindPhoneOrEmail?code=${_controller.text}&email=$email",
        server: true,
        method: "PUT",
        authKey: widget.user()?.token,
        auth: true,
        onValue: (source, url) {
          print(url);
          print(source);
          var js = json.decode(source);
          if (js['code'] == 1) {
            User user = User.fromJson(js['data']);
            user.token = widget.user()?.token;
            widget.callback(user);
            this.auth(jwt, jsonEncode(user), user.id);
            showSuccess();
          } else {
            platform.invokeMethod("toast", js['message']);
          }
        },
        onEnd: () {
          setState(() {
            _sending2 = false;
          });
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.user()?.email != null) {
      // _emailController = new TextEditingController(text: widget.user()?.email);
    }
  }

  void _getTheCode() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "user/getEmailCode?email=$email",
        server: true,
        authKey: widget.user()?.token,
        onValue: (source, url) async {
          var jx = json.decode(source);
          if (jx['code'] == 1) {
            setState(() {
              _duration = new Duration(seconds: 60);
              _timer?.cancel();
              _timer = Timer.periodic(Duration(seconds: 1), (t) {
                if (_duration.inSeconds <= 0) {
                  t.cancel();
                }
                setState(() {
                  _duration = Duration(seconds: _duration.inSeconds - 1);
                });
              });
            });
          }

          platform.invokeMethod("toast", jx['message']);
        },
        error: (s, v) => platform.invokeMethod("toast", s),
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  bool get enabled =>!_sending && _duration.inSeconds <= 0;

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
          "Email",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            Container(
                child: TextFormField(
              controller: _emailController,
              enabled: enabled,
              inputFormatters: [
                FilteringTextInputFormatter.deny(disableSpecial)
              ],
              validator: (s) =>
                  emailExp.hasMatch(s) ? null : "Valid email is required",
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  filled: true,
                  hintText: "Email",
                  enabled: enabled,
                  fillColor: enabled ? Colors.white : Colors.grey.shade100,
                  contentPadding: EdgeInsets.only(left: 7),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5))),
            )),
            SizedBox(height: 10),
            Container(
              height: 45,
              child: TextFormField(
                controller: _controller,
                onChanged: (string) {
                  if (string.length == 6) {
                    setState(() {
                      _valid = true;
                    });
                  } else if (_valid) {
                    setState(() {
                      _valid = false;
                    });
                  }
                },
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: "Code",
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.only(left: 10),
                    suffixIcon: _sending
                        ? CupertinoActivityIndicator()
                        : Container(
                            height: 40,
                            padding: EdgeInsets.all(7),
                            child: RaisedButton(
                              onPressed:
                                  _duration.inSeconds > 0 ? () {} : _getTheCode,
                              color: color.withOpacity(0.2),
                              padding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: color,
                                  ),
                                  borderRadius: BorderRadius.circular(6)),
                              elevation: 0.0,
                              child: Text(
                                _duration.inSeconds > 0
                                    ? "${_duration.inSeconds}"
                                    : "Get the code",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none)),
              ),
            ),
            SizedBox(height: 90),
            _sending2
                ? CupertinoActivityIndicator()
                : RaisedButton(
                    elevation: 0.0,
                    child: Text(
                      "Submit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: _change,
                    color: color,
                  )
          ],
        ),
      ),
    );
  }
}
