import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class PasswordSecurity extends StatefulWidget {
  final User Function() user;

  const PasswordSecurity({Key key, @required this.user}) : super(key: key);

  @override
  _PasswordSecurityState createState() => _PasswordSecurityState();
}

class _PasswordSecurityState extends State<PasswordSecurity> with SuperBase {
  var _formKey = new GlobalKey<FormState>();
  var _passwordController = new TextEditingController();
  var _oldPasswordController = new TextEditingController();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _sending = false;

  bool _obSecure = true;
  bool _obSecure1 = true;
  bool _obSecure2 = true;

  void showSuccess() {
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
                    image: AssetImage("assets/logo_circle.png")),
                SizedBox(height: 20),
                Text("Password changed successfully",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))
              ],
            ),
          );
        });
  }

  void sendPost() {
    if (_formKey.currentState.validate()) {
      setState(() {
        _sending = true;
      });
      reqFocus(context);
      this.ajax(
          url:
              "user/updatePassword",
          method: "PUT",
          authKey: widget.user()?.token,
          map: {
            "oldPassword":_oldPasswordController.text,
            "newPassword":_passwordController.text
          },
          server: true,
          onValue: (source, url) {
            var js = jsonDecode(source);
            if (js['code'] != 1) {
              _shownSnack(js['message']);
            } else {
              Navigator.of(context).pop();
              showSuccess();
            }
          },
          error: (source, url) {
            _shownSnack(source);
          },
          onEnd: () {
            setState(() {
              _sending = false;
            });
          });
    }
  }

  void _shownSnack(String snack) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(snack)));
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.maybePop(context);
                })
            : null,
        title: Text(
          "Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            Container(
                height: null,
                child: TextFormField(
                  validator: (s) => s.isEmpty ? "Required" : null,
                  controller: _oldPasswordController,
                  obscureText: _obSecure,
                  decoration: InputDecoration(
                      filled: true,
                      hintText: "Current Password",
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.only(left: 7),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(5)),
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
                )),
            SizedBox(height: 15),
            Container(
                height: null,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obSecure1,
                  validator: (s) => s.length < 8
                      ? "8  characters minimum \nAt least one letter\nAt least one number"
                      : null,
                  decoration: InputDecoration(
                      filled: true,
                      hintText: "New Password",
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.only(left: 7),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(5)),
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
                )),
            SizedBox(height: 15),
            Container(
                height: null,
                child: TextFormField(
                  validator: (s) => s != _passwordController.text
                      ? "Confirm has to match new pasword"
                      : null,
                  obscureText: _obSecure2,
                  decoration: InputDecoration(
                      filled: true,
                      hintText: "Confirm Password",
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.only(left: 7),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(5)),
                      suffixIcon: Container(
                        height: 20,
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                _obSecure2 = !_obSecure2;
                              });
                            },
                            child: Image.asset(
                              "assets/${!_obSecure2 ? 'eye_closed.png' : 'openeye.png'}",
                              fit: BoxFit.fitWidth,
                            )),
                      )),
                )),
            SizedBox(height: 40),
            Container(
                height: 42,
                child: _sending
                    ? Center(
                        child: CupertinoActivityIndicator(),
                      )
                    : RaisedButton(
                        elevation: 0.0,
                        child: Text(
                          "Submit",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: sendPost,
                        color: color,
                      ))
          ],
        ),
      ),
    );
  }
}
