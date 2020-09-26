import 'dart:convert';

import 'package:afri_shop/SuperBase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FinalResetPassword extends StatefulWidget{
  final String phone;
  final String code;
  final bool isFromEmail;

  const FinalResetPassword({Key key,@required this.phone,@required this.code, this.isFromEmail:false}) : super(key: key);
  @override
  _FinalResetPasswordState createState() => _FinalResetPasswordState();
}

class _FinalResetPasswordState extends State<FinalResetPassword> with SuperBase {

  bool _sending = false;
  var form = new GlobalKey<FormState>();
  bool _obSecure = true;
  bool _obSecure1 = true;
  TextEditingController password = new TextEditingController();
  TextEditingController password1 = new TextEditingController();
  bool _valid = false;


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


  void showSuccess() async {
    await Navigator.push(context,
        CupertinoPageRoute(builder: (context) {
          return Scaffold(
            appBar: AppBar(

              leading: Navigator.canPop(context)
                  ? IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  })
                  : null,
              centerTitle: true,
              title: 
              Text("Reset password"),
            ),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                      height: 120,
                      fit: BoxFit.cover,
                      image: AssetImage("assets/logo_circle.png")),
                  SizedBox(height: 20),
                  Text("Password modified successfully",
                      style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey, fontSize: 14)),
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:20.0),
                    child: Container(
                      width: double.infinity,
                      child: RaisedButton(onPressed: (){
                        Navigator.maybePop(context);
                      },child: Text("Confirm"),color: color,elevation: 0.5,textColor: Colors.grey,),
                    ),
                  )
                ],
              ),
            ),
          );
        }));
      Navigator.pop(context,"data");
  }

  void reset() {
    if (!form.currentState.validate()) return;
    setState(() {
      _sending = true;
    });
    reqFocus(context);
    this.ajax(
        url:
        "user/${ widget.isFromEmail ? "resetPasswordWithEmail": "resetPassword"}?${widget.isFromEmail?"email":"phone"}=${widget.phone}&code=${widget.code}&newPassword=${password.text}",
        server: true,
        auth: false,
        method: "PUT",
        onValue: (source, url) {
          print(source);
          print(url);
          print(widget.code);
          var js = json.decode(source);
          if (js['code'] == 1) {
            showSuccess();
          } else
            showFail(js['message']);
        },
        error: (s, v) => print(s),
        onEnd: () {
          setState(() {
            _sending = false;
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
          "Reset Password",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            SizedBox(height: 20),
            TextFormField(
              controller: password,
              obscureText: _obSecure,

              onChanged: (string) {
                if (string.length > 7 && string == password1.text) {
                  setState(() {
                    _valid = true;
                  });
                } else if (_valid) {
                  setState(() {
                    _valid = false;
                  });
                }
              },
              validator: (s) => s.isEmpty ? "Must be 8 or more characters" : null,
              decoration: InputDecoration(
                  hintText: "New password",
                  helperText: "Must be 8 or more characters",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.only(left: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none),
                  suffixIcon: Container(
                    height: 20,
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            _obSecure = !_obSecure;
                          });
                        },
                        child: Image.asset(
                          "assets/${!_obSecure ? 'eye_closed.png' : 'openeye.png'}",
                          fit: BoxFit.fitWidth,
                        )),
                  )),
            ),
            SizedBox(height: 6),
            TextFormField(
              controller: password1,
              obscureText: _obSecure1,
              onChanged: (string) {
                if (string == password.text) {
                  setState(() {
                    _valid = true;
                  });
                } else if (_valid) {
                  setState(() {
                    _valid = false;
                  });
                }
              },
              validator: (s) => s != password.text ? "Please provide same password" : null,
              decoration: InputDecoration(
                  hintText: "Confirm password",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.only(left: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none),
                  suffixIcon: Container(
                    height: 20,
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            _obSecure1 = !_obSecure1;
                          });
                        },
                        child: Image.asset(
                          "assets/${!_obSecure1 ? 'eye_closed.png' : 'openeye.png'}",
                          fit: BoxFit.fitWidth,
                        )),
                  )),
            ),
            SizedBox(
              height: 115,
            ),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: _sending
                  ? Align(
                alignment: Alignment.center,
                child: CupertinoActivityIndicator(),
              )
                  : RaisedButton(
                onPressed: _valid ? reset : null,
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