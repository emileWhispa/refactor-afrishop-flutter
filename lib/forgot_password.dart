import 'dart:convert';

import 'package:afri_shop/forgot_by_phone.dart';
import 'package:afri_shop/reset_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> with SuperBase {
  var phone = new TextEditingController();
  var form = new GlobalKey<FormState>();

  bool _sending = false;

  void _sendCode() async {
    if (!form.currentState.validate()) return;

    setState(() {
      _sending = true;
    });

    this.ajax(
        url: "login/checkAccount?name=${phone.text}",
        server: true,
        onValue: (source, v) async {
          print(source);
          var j = jsonDecode(source);
          if (j['code'] == 1 && j['data']['available'] == false) {
            var x = await Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => ResetPassword(
                      phone: phone.text,
                    )));
            if (x != null) {
              Navigator.pop(context);
            }
          }else{
            showFail("Email Address Not Found");
          }
        },onEnd: (){
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


  bool _valid = false;

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
          "Forgot Password",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Reset Your Password",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 5),
            Text(
                "To reset your password, enter your email  address below and follow the instructions in the email we'll send you.",
                style: TextStyle(color: Color(0xff999999))),
            SizedBox(height: 5),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: TextFormField(
                controller: phone,
                onChanged: (string){
                  if( !_valid && emailExp.hasMatch(string) ){
                    setState(() {
                      _valid = true;
                    });
                  }else if( _valid && !emailExp.hasMatch(string) ){
                    setState(() {
                      _valid = false;
                    });
                  }
                },
                validator: (s) => s.isEmpty ? "Email is required" : null,
                decoration: InputDecoration(
                    hintText: "Email address",
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.only(left: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none)),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () async {
                    var x = await Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => ForgotByPhone()));
                    if (x != null) {
                      Navigator.pop(context, "developer");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "Reset via Phone Number",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )),
            SizedBox(
              height: 110,
            ),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: _sending
                  ? Align(
                      alignment: Alignment.center,
                      child: loadBox(),
                    )
                  : RaisedButton(
                      onPressed: _valid ? _sendCode : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                      elevation: 0.0,
                      color: _valid ? color : Color(0xffCCCCCC),
                      child: Text(
                        "Send Reset Link",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xff272626).withOpacity(0.5)),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
