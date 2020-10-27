import 'dart:convert';

import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/firebase_info.dart';
import 'package:afri_shop/forgot_password.dart';
import 'package:afri_shop/verification_code.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:dio/dio.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Json/globals.dart' as globals;
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:google_sign_in/google_sign_in.dart';

import 'Json/country.dart';
import 'country_picker.dart';

class Authorization extends StatefulWidget {
  final bool login;

  const Authorization({Key key, this.login: true}) : super(key: key);

  @override
  _AuthorizationState createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> with SuperBase {
  bool _isLogin = true;
  bool _obSecure = true;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _emailRegController = new TextEditingController();
  TextEditingController _phoneRegController = new TextEditingController();
  TextEditingController _passwordRegController = new TextEditingController();
  GlobalKey<FormState> _loginKey = new GlobalKey<FormState>();
  GlobalKey<FormState> _registerKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _sending = false;
  bool _isEmail = true;
  bool _isEmail2 = true;
  var _sending2 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLogin = widget.login;
    phoneNode.addListener(() {
      if (!phoneNode.hasFocus) {
        loginValid = _loginKey.currentState?.validate() ?? _loginValid;
      }
    });
    emailNode.addListener(() {
      if (!emailNode.hasFocus) {
        loginValid = _loginKey.currentState?.validate() ?? _loginValid;
      }
    });
    passNode.addListener(() {
      if (!passNode.hasFocus) {
        loginValid = _loginKey.currentState?.validate() ?? _loginValid;
      }
    });
    phone2Node.addListener(() {
      if (!phone2Node.hasFocus) {
        registerValid = _registerKey.currentState?.validate() ?? _registerValid;
      }
    });
    email2Node.addListener(() {
      if (!email2Node.hasFocus) {
        registerValid = _registerKey.currentState?.validate() ?? _registerValid;
      }
    });
    pass2Node.addListener(() {
      if (!pass2Node.hasFocus) {
        registerValid = _registerKey.currentState?.validate() ?? _registerKey;
      }
    });
  }

  set loginValid(bool _loginValid) {
    if (_loginValid != this._loginValid)
      setState(() {
        this._loginValid = _loginValid;
      });
    this._loginValid = _loginValid;
  }

  set registerValid(bool _registerValid) {
    if (_registerValid != this._registerValid)
      setState(() {
        this._registerValid = _registerValid;
      });
    this._registerValid = _registerValid;
  }

  bool _loginValid = false;
  bool _registerValid = false;

  Country _country;
  Country _country2;

  FocusNode phoneNode = new FocusNode();
  FocusNode emailNode = new FocusNode();
  FocusNode email2Node = new FocusNode();
  FocusNode passNode = new FocusNode();
  FocusNode phone2Node = new FocusNode();
  FocusNode pass2Node = new FocusNode();

  void _register() async {
    if (!(_registerKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _sending2 = true;
    });
    reqFocus(context);
    var phone = _isEmail2
        ? _emailRegController.text
        : "${_country2?.dialingCode ?? "260"}${_phoneRegController.text}";

    var map = {
      "email":phone,
      "account":phone,
      "password":_passwordRegController.text,
      "fcm": globals.fcm,
    };
    print(map);
    this.ajax(
        url: "api/auth/signup",
        method: "POST",
        server: true,
        auth: false,
        noOptions: true,
        map: map,
        onValue: (map, url) {
          if (map['data'] != null && map['code'] == 1) {
            User user = User.fromJson(map['data']);
          platform.invokeMethod('logSignupEvent', <Object, dynamic>{
      'email':'${phone}'
    });
            platform.invokeMethod("toast", "Signup Success");
            this.auth(jwt, jsonEncode(user), user.id);
            Navigator.of(context).pop(user);
          } else {
            _showSnack(map['message']);
            setState(() {
              _sending2 = false;
            });
          }
        },
        error: (source, url) {
          setState(() {
            _sending2 = false;
          });
          _showSnack('Connection error');
        });
  }

//  void _faceBook() async {
//    final facebookLogin = FacebookLogin();
//    showMd();
//    facebookLogin.loginBehavior = FacebookLoginBehavior.webOnly;
//    if (await facebookLogin.isLoggedIn) await facebookLogin.logOut();
//    final result = await facebookLogin.logIn(['email']);
//    switch (result.status) {
//      case FacebookLoginStatus.loggedIn:
//        await _sendTokenToServer(result.accessToken.token);
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        platform.invokeMethod("toast", "Canceled by user");
//        break;
//      case FacebookLoginStatus.error:
//        platform.invokeMethod("toast", "Failed");
//        break;
//    }
//    canPop();
//  }
//
//  Future<void> _sendTokenToServer(String token) async {
//    var credential = FacebookAuthProvider.getCredential(accessToken: token);
//    var withCredential = await _auth.signInWithCredential(credential);
//    var tokenResult = await withCredential.user.getIdToken();
//    print(tokenResult?.token);
//
//    Clipboard.setData(ClipboardData(text: tokenResult?.token));
//
//    await Navigator.push(
//        context,
//        CupertinoPageRoute(
//            builder: (context) => FirebaseInfo(
//                url: withCredential.user.photoUrl,
//                uid: withCredential.user.uid,
//                email: withCredential.user.email,
//                name: withCredential.user.displayName)));
//    if (tokenResult.token != null) platform.invokeMethod("toast", "Success");
//    return Future.value();
//  }
//
//  final GoogleSignIn _googleSignIn = GoogleSignIn();
//  final FirebaseAuth _auth = FirebaseAuth.instance;
//
//  Future<FirebaseUser> _handleGoogleSignIn() async {
//    showMd();
//    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//    if (googleUser != null) {
//      final GoogleSignInAuthentication googleAuth =
//          await googleUser.authentication;
//
//      final AuthCredential credential = GoogleAuthProvider.getCredential(
//        accessToken: googleAuth.accessToken,
//        idToken: googleAuth.idToken,
//      );
//
//      print(googleAuth.accessToken);
//
//      final FirebaseUser user =
//          (await _auth.signInWithCredential(credential)).user;
//      var token = await user.getIdToken();
//      print(token?.token);
//      Clipboard.setData(ClipboardData(text: token?.token));
//      platform.invokeMethod("toast", "Signed in ${user.displayName}");
//      canPop();
//      Navigator.push(
//          context,
//          CupertinoPageRoute(
//              builder: (context) => FirebaseInfo(
//                  url: googleUser.photoUrl,
//                  uid: user.uid,
//                  email: googleUser.email,
//                  name: googleUser.displayName)));
//      return user;
//    } else {
//      platform.invokeMethod("toast", "Failed");
//    }
//    canPop();
//    return null;
//  }

  void _signIn() async {
    if (_loginKey.currentState?.validate() ?? false) {
      setState(() {
        _sending = true;
      });
      reqFocus(context);
      var account = _isEmail
          ? _emailController.text
          : "${_country?.dialingCode ?? "250"}${_phoneController.text}";
      this.ajax(
          url: "api/auth/signin",
          method: "POST",
          server: true,
          auth: false,
          noOptions: true,
          map: {
            "account":account,
            "password":_passwordController.text,
            "fcm": globals.fcm,
          },
          onValue: (map, url) {
            if (map['data'] != null && map['code'] == 1) {
              User user = User.fromJson(map['data']);
              platform.invokeMethod("toast", "Login Success");
              this.auth(jwt, jsonEncode(user), user.id);
              Navigator.of(context).pop(user);
            } else {
              _showSnack(map['message']);
              setState(() {
                _sending = false;
              });
            }
          },
          error: (source, url) {
            setState(() {
              _sending = false;
            });
            _showSnack('Connection error or invalid username or password');
          });
    }
  }

  void _showSnack(String text) {
    platform.invokeMethod("toast", text);
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(text)));
  }

  bool _pop = false;

  void canPop() {
    if (_pop) {
      Navigator.pop(context);
      _pop = false;
    }
  }

  Future<void> showMd() async {
    if (_pop) return;
    _pop = true;
    //Timer(Duration(seconds: 8), ()=>this.canPop());
    await showGeneralDialog(
        transitionDuration: Duration(seconds: 1),
        barrierDismissible: false,
        context: context,
        barrierColor: Colors.black12,
        pageBuilder: (context, _, __) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            content: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(7)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          );
        });
    _pop = false;
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      Column(
        children: [
          _isLogin
              ? Form(
            key: _loginKey,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: <Widget>[
                  _isEmail
                      ? TextFormField(
                    controller: _emailController,
                    focusNode: emailNode,
                    onEditingComplete: () {
                      _loginKey.currentState?.validate();
                    },
                    validator: (s) => s.length < 2
                        ? "Email address is required"
                        : emailExp.hasMatch(s) ? null : "Valid email is required",
                    decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.red)),
                        hintStyle:
                        TextStyle(color: Color(0xff999999)),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                        hintText: "Email address",
                        filled: true,
                        fillColor: Colors.white),
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(5)),
                          height: 48,
                          child: CountryPicker(
                            onChanged: (c) {
                              setState(() {
                                _country = c;
                              });
                            },
                            showFlag: false,
                            showName: false,
                            showDialingCode: true,
                            selectedCountry: _country,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          focusNode: phoneNode,
                          inputFormatters: [
                            WhitelistingTextInputFormatter
                                .digitsOnly
                          ],
                          onEditingComplete: () {
                            _loginKey.currentState?.validate();
                          },
                          keyboardType: TextInputType.number,
                          validator: (s) => s.length < 2
                              ? "Phone is required"
                              : null,
                          decoration: InputDecoration(
                              focusedErrorBorder:
                              OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red)),
                              hintStyle: TextStyle(
                                  color: Color(0xff999999)),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                  BorderRadius.circular(5)),
                              hintText: "Phone number",
                              filled: true,
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    obscureText: _obSecure,
                    controller: _passwordController,
                    focusNode: passNode,
                    onEditingComplete: () {
                      loginValid = _loginKey.currentState?.validate() ??
                          _loginValid;
                    },
                    onChanged: (s) {
                      loginValid = _loginKey.currentState?.validate() ??
                          _loginValid;
                    },
                    validator: (s)=>s.trim().isEmpty ? "Password is required" : null,
                    decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                        hintText: "Password",
                        filled: true,
                        hintStyle: TextStyle(color: Color(0xff999999)),
                        fillColor: Colors.white,
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
//                        Align(
//                            alignment: Alignment.centerRight,
//                            child: InkWell(
//                              onTap: () {
//                                Navigator.of(context).push(CupertinoPageRoute(
//                                    builder: (context) => ForgotPassword()));
//                              },
//                              child: Padding(
//                                padding:
//                                    const EdgeInsets.symmetric(vertical: 12.0),
//                                child: Text(
//                                  "Forgot Password?",
//                                  style: TextStyle(color: Colors.grey),
//                                ),
//                              ),
//                            )),
                  SizedBox(
                    height: 35,
                  ),
                  _sending
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : SizedBox(
                    height: 42,
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                            color: _loginValid
                                ? Colors.black87
                                : Color(0xff272626)
                                .withOpacity(0.2),
                            fontWeight: FontWeight.bold),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      onPressed: _signIn,
                      color:
                      _loginValid ? color : Color(0xffCCCCCC),
                    ),
                  ),

                ],
              ),
            ),
          )
              : Form(
            key: _registerKey,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: <Widget>[
                  _isEmail2
                      ? TextFormField(
                    controller: _emailRegController,
                    onEditingComplete: () {
                      _registerKey.currentState?.validate();
                    },
                    focusNode: email2Node,
                    validator: (s) => s.length < 2
                        ? "Email address is required"
                        : emailExp.hasMatch(s) ? null : "Valid email is required",
                    decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.red)),
                        hintStyle: TextStyle(
                            color: Color(0xff999999), fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                        hintText: "Email address",
                        filled: true,
                        fillColor: Colors.white),
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(5)),
                          height: 48,
                          child: CountryPicker(
                            onChanged: (c) {
                              setState(() {
                                _country2 = c;
                              });
                            },
                            showFlag: false,
                            showName: false,
                            showDialingCode: true,
                            selectedCountry: _country2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneRegController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onEditingComplete: () {
                            _registerKey.currentState?.validate();
                          },
                          focusNode: phone2Node,
                          keyboardType: TextInputType.number,
                          validator: (s) => s.length < 2
                              ? "Phone is required"
                              : null,
                          decoration: InputDecoration(
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red)),
                              focusedErrorBorder:
                              OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red)),
                              hintStyle: TextStyle(
                                  color: Color(0xff999999),
                                  fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 15),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                  BorderRadius.circular(5)),
                              hintText: "Phone number",
                              filled: true,
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordRegController,
                    obscureText: _obSecure,
                    focusNode: pass2Node,
                    onEditingComplete: () {
                      registerValid =
                          _registerKey.currentState?.validate() ??
                              _registerValid;
                    },
                    onChanged: (s) {
                      registerValid =
                          _registerKey.currentState?.validate() ??
                              _registerValid;
                    },
                    validator: validatePassword,
                    decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)),
                        hintText: "Password",
                        filled: true,
                        hintStyle: TextStyle(
                            color: Color(0xff999999), fontSize: 14),
                        fillColor: Colors.white,
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
                  SizedBox(height: 30),
                  _sending2
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Create Your Account",
                        style: TextStyle(
                            color: _registerValid
                                ? Colors.black87
                                : Color(0xff272626)
                                .withOpacity(0.2)),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      onPressed: _register,
                      color: _registerValid
                          ? color
                          : Color(0xffCCCCCC),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),

          InkWell(
            onTap: () {
              setState(() {
                _isLogin = !_isLogin;
              });
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have account ?"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0),
                    child: Text(
                      "${!_isLogin ? "Sign In" : "Sign up"}",
                      style:
                      TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
          ),
        ],
      );
  }
}
