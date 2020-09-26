import 'dart:async';
import 'dart:convert';

import 'package:afri_shop/final_reset_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'SuperBase.dart';

class ResetPassword extends StatefulWidget {
  final String phone;
  final bool isEmail;

  const ResetPassword({Key key, @required this.phone, this.isEmail: true})
      : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> with SuperBase {
  var captchaController = new TextEditingController();

  // var passwordController = new TextEditingController();
  var form = new GlobalKey<FormState>();
  var _sending = false;
  bool _valid = false;
  bool _sending2 = false;
  Duration _duration = new Duration(seconds: 0);
  Timer _timer;



  void _getTheCode() {
    setState(() {
      _sending2 = true;
    });
    this.ajax(
        url: widget.isEmail
            ? "user/register/identifyCode/${widget.phone}/Big dhevil"
            : "login/register/identifyCode/${widget.phone}",
        server: true,
        onValue: (source, url) async {
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
        },
        onEnd: () {
          setState(() {
            _sending2 = false;
          });
        });
  }

  void _goFinalPass() async {
    setState(() {
      _sending = true;
    });
    this.ajax(
        url:
            "user/checkCode?account=${widget.phone}&code=${captchaController.text}",
        server: true,
        onValue: (source, url) async {
          print(source);
          var js = jsonDecode(source);

          if (js['code'] == 1) {
            var x = await Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => FinalResetPassword(
                    phone: widget.phone, code: captchaController.text,isFromEmail: widget.isEmail)));
            if (x != null) {
              Navigator.pop(context, "pure data");
            }
          } else {
            showFail(js['message']);
          }
        },
        error: (s, url) => showFail(s),
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
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

  void showSuccess(String success) async {
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
                Text("$success",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))
              ],
            ),
          );
        });
    Navigator.of(context).pop("data");
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
          "Verification Code",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            SizedBox(height: 5),
            Text(
              "Verification code sent to ${widget.phone}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              "Warning: verification code expires in 10 minutes",
              style: TextStyle(color: Colors.orange),
            ),
            SizedBox(height: 15),
            Container(
              height: 45,
              child: TextFormField(
                controller: captchaController,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
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
                decoration: InputDecoration(
                    hintText: "Verification Code",
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.only(left: 10),
                    suffixIcon: _sending2
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
            SizedBox(
              height: 115,
            ),
//            Container(
//              height: 45,
//              child: TextFormField(
//                obscureText: true,
//                controller: passwordController,
//                validator: (s)=>s.isEmpty ? "New password required" : null,
//                decoration: InputDecoration(
//                    hintText: "New password",
//                    fillColor: Colors.white,
//                    filled: true,
//                    contentPadding: EdgeInsets.only(left: 10),
//                    border: OutlineInputBorder(
//                        borderRadius: BorderRadius.circular(6),
//                        borderSide: BorderSide(color: Colors.grey.shade100))),
//              ),
//            ),
//            SizedBox(
//              height: 15,
//            ),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: _sending
                  ? Align(
                      alignment: Alignment.center,
                      child: CupertinoActivityIndicator(),
                    )
                  : RaisedButton(
                      onPressed: _valid ? _goFinalPass : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      elevation: 0.0,
                      color: _valid ? color : Color(0xffCCCCCC),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xff272626).withOpacity(0.25)),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
