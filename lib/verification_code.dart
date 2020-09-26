import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class VerificationCodeReg extends StatefulWidget{
  final String phone;
  final String password;
  final bool isEmail;

  const VerificationCodeReg({Key key,@required this.phone, this.isEmail:false,@required this.password}) : super(key: key);
  @override
  _VerificationCodeRegState createState() => _VerificationCodeRegState();
}

class _VerificationCodeRegState extends State<VerificationCodeReg> with SuperBase {
  TextEditingController _controller = new TextEditingController();
  Duration _duration = new Duration(seconds: 0);
  Timer _timer;
  bool _valid = false;
  bool _sending = false;
  bool _sending2 = false;


  void _register() async {

    setState(() {
      _sending2 = true;
    });
    reqFocus(context);
    var code = _controller.text;

    this.ajax(
        url:
        "user/checkCode?account=${widget.phone}&code=$code",
        server: true,
        onValue: (source, url) async {
          var dd = json.decode(source);
          if( dd['code'] == 1) {
            this.ajax(
                url: "login/createUser",
                method: "POST",
                map: {
                  "captcha": code,
                  "password": widget.password,
                  "account": widget.phone,
                },
                server: true,
                auth: false,
                onValue: (source, url) {
                  var map = json.decode(source);
                  if (map['data'] != null && map['code'] == 1) {
                    User user = User.fromJson(map['data']);
                    this.ajax(
                        url: "registerUser",
                        base2: true,
                        method: "POST",
                        server: true,
                        data: FormData.fromMap(user.toServerModel()),
                        onValue: (source, url) {
                          var map = jsonDecode(source);
                          user.slogan = map['slogan'];
                          user.code = map['code'];
                          user.invited = map['invited'];
                          user.requestInvitation = true;
                          this.auth(jwt, jsonEncode(user), user.id);
                          Navigator.of(context).pop(user);
                        },
                        onEnd: () {
                          setState(() {
                            _sending2 = false;
                          });
                        },
                        error: (s, v) {
                          setState(() {
                            _sending2 = false;
                          });
                          _showSnack(s);
                        });
                  } else {
                    setState(() {
                      _sending2 = false;
                    });
                    _showSnack(map['message']);
                  }
                },
                error: (s, v) {
                  setState(() {
                    _sending2 = false;
                  });
                  _showSnack(s);
                });
          }else{
            setState(() {
              _sending2 = false;
            });
            _showSnack(dd['message']);
          }
    },
    error: (s,v){
      setState(() {
        _sending2 = false;
      });
      _showSnack(s);
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  void _showSnack(String text) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(text)));
  }

  void _getTheCode(){
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: widget.isEmail ? "user/getEmailCode?email=${widget.phone}" : "login/register/identifyCode/${widget.phone}",
        server: true,
        onValue: (source, url) async {
          setState(() {
            _duration = new Duration(seconds: 60);
            _timer?.cancel();
            _timer = Timer.periodic(Duration(seconds: 1), (t){
              if(_duration.inSeconds <= 0){
                t.cancel();
              }
              setState(() {
                _duration = Duration(seconds: _duration.inSeconds - 1);
              });
            });
          });
        },onEnd: (){
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text(
          "Verification code",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          SizedBox(height: 5),
          Text(
            "Verification code sent to ${widget.phone}",style: TextStyle(color: Colors.grey),),
          SizedBox(height: 5),
          Text(
            "Warning: verification code expires in 10 minutes",style: TextStyle(color: Colors.orange),),
          SizedBox(height: 15),
          Container(
            height: 45,
            child: TextFormField(
              controller: _controller,
              onChanged: (string){
                if( string.length == 6){
                  setState(() {
                    _valid = true;
                  });
                }else if(_valid){
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
                  suffixIcon: _sending ? CupertinoActivityIndicator() : Container(
                    height: 40,
                    padding: EdgeInsets.all(7),
                    child: RaisedButton(
                      onPressed: _duration.inSeconds > 0 ? (){} : _getTheCode,
                      color: color.withOpacity(0.2),
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: color,
                          ),
                          borderRadius: BorderRadius.circular(6)
                      ),
                      elevation: 0.0,
                      child: Text(
                       _duration.inSeconds > 0 ? "${_duration.inSeconds}" : "Get the code",
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none)),
            ),
          ),
          SizedBox(height: 115,),
          _sending2 ? CupertinoActivityIndicator() : SizedBox(
            width: double.infinity,
            height: 45,
            child: RaisedButton(
              onPressed: _valid ? _register : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)
              ),
              elevation: 0.0,
              color: _valid ? color : Color(0xffCCCCCC),
              child: Text(
                "Submit",
                style: TextStyle(fontWeight: FontWeight.w700,color: Color(0xff272626).withOpacity(0.5)),
              ),
            ),
          )
        ],
      ),
    );
  }
}