import 'dart:convert';

import 'package:afri_shop/old_authorization.dart';
import 'package:afri_shop/old_user_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'Json/globals.dart' as globals;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Json/User.dart';
import 'SuperBase.dart';
import 'Authorization.dart' as new_auth;
import 'old_authorization.dart' as old_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cart_page.dart';
import 'empty_account_detail.dart';

class AccountScreen extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;
  final void Function(int index) jumpTo;
  final GlobalKey<CartScreenState> cartState;
  final bool canPop;
  final bool partial;

  const AccountScreen(
      {Key key,
      @required this.user,
      @required this.callback,
      this.canPop: false,
      this.partial: false,
      this.jumpTo,
      @required this.cartState})
      : super(key: key);

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with SuperBase {
  void populate(User user) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
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

  void _faceBook() async {
    final facebookLogin = FacebookLogin();
    //print(await platform.invokeMethod("get-hash"));
    showMd();
    facebookLogin.loginBehavior = FacebookLoginBehavior.webOnly;
    if (await facebookLogin.isLoggedIn) {
      await facebookLogin.logOut();
    }
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        await _sendTokenToServer(result.accessToken.token);
        break;
      case FacebookLoginStatus.cancelledByUser:
        platform.invokeMethod("toast", "Canceled by user");
        canPop();
        break;
      case FacebookLoginStatus.error:
        platform.invokeMethod("toast", "Failed");
        canPop();
        break;
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    var credential = FacebookAuthProvider.getCredential(accessToken: token);
    var withCredential = await _auth.signInWithCredential(credential);
    var tokenResult = await withCredential.user.getIdToken();
    print(withCredential.user.uid);
    print(token);
    if (tokenResult.token != null) platform.invokeMethod("toast", "Success");
    await this.realSign(tokenResult, withCredential.user);
    return Future.value();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> realSign(IdTokenResult tokenResult, FirebaseUser user) async {
    var pic = "${user?.photoUrl}";

    pic = pic.replaceFirst("s96-c", "s400-c");
    var map = {
      "name": user?.displayName,
      "nick": user?.displayName,
      "email": user?.email,
      "phone": user?.phoneNumber,
      "fcm": globals.fcm,
      "password": user?.uid,
      "account": user?.uid ?? user?.email ?? user?.phoneNumber,
      "avatar": "$pic?height=500",
      "firebaseUid": user?.uid,
      "token": tokenResult?.token,
    };

    print(map['avatar']);
    printWrapped(jsonEncode(map));
    return this.ajax(
        url: "api/auth/register/user",
        method: "POST",
        server: true,
        auth: false,
        noOptions: true,
        map: map,
        onValue: (map, url) {
          print(url);
          if (map['data'] != null && map['code'] == 1) {
            User user = User.fromJson(map['data']);
            print(user.toServerModel());

            user.requestInvitation = !user.invited;

            platform.invokeMethod("toast", "Login Success");
            this.auth(jwt, jsonEncode(user), user.id);
            if (widget.canPop) {
              canPop();
              Navigator.pop(context, user);
            } else {
              canPop();
              setState(() {
                widget.callback(user);
              });
            }
          } else {
            print(map);
            canPop();
          }
        },
        error: (source, url) {
          print(source);
          canPop();
        });
  }

  Future<FirebaseUser> _handleGoogleSignIn() async {
    showMd();

    await _googleSignIn.signOut();
    await _auth.signOut();

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print(googleAuth.accessToken);

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;

      var tokenResult = await user.getIdToken();
      print(tokenResult?.token);

      await this.realSign(tokenResult, user);
      platform.invokeMethod("toast", "Signed in ${user.displayName}");
      return user;
    } else {
      platform.invokeMethod("toast", "Failed");
    }
    canPop();
    return null;
  }

  BoxDecoration get _dec => BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black26),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                spreadRadius: 1.0,
                blurRadius: 10.0,
                offset: Offset(10.5, 10.5))
          ]);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    if( widget.canPop && widget.partial ) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal:14.0,vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgets,
        ),
      );
    }

    if( widget.user() == null && !widget.canPop ){
      return EmptyAccountDetail();
    }

    return widget.user() != null
        ? OldUserDetail(
            user: widget.user,
            onLogOut: (d) {
              setState(() {
                widget.callback(null);
              });
            },
            callback: widget.callback,
            jumpTo: widget.jumpTo,
            cartState: widget.cartState,
          )
        : Scaffold(
            appBar: widget.partial
                ? null
                : AppBar(
                    leading: Navigator.canPop(context)
                        ? IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              Navigator.maybePop(context);
                            })
                        : null,
                    backgroundColor: color,
                    title: Row(
                      children: <Widget>[
                        Image.asset(
                          "assets/afrishop_logo@3x.png",
                          width: 70,
                          fit: BoxFit.fitWidth,
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(right: 70.0),
                          child: Text(
                            "Account",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        )),
                      ],
                    ),
                    centerTitle: true,
                    elevation: 0.6,
                  ),
            backgroundColor: widget.partial ? Colors.transparent : null,
            body: widget.partial
                ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widgets,
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    children: widgets,
                  ),
          );
  }

  List<Widget> get widgets => <Widget>[
        widget.partial
            ? SizedBox.shrink()
            : Align(
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: _dec,
                      child: Center(
                        child: Text(
                          "!",
                          style: TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                              color: Colors.black26),
                        ),
                      ),
                      height: 150,
                      width: 150,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: _dec,
                        height: 45,
                        width: 45,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.black26,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
          SizedBox(
          height: widget.partial ? 0 : 40,
        ),
        widget.partial ? SizedBox.shrink() : Text(
          "You need to login first",
          style: TextStyle(
              fontFamily: 'SF UI Display',
              fontWeight: widget.partial ? FontWeight.w900 : FontWeight.normal,
              fontSize: widget.partial ? 22 : 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height:widget.partial ? 0 : 30,
        ),
        Container(
          height: 45,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/google.png",
                  height: 25,
                  width: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text(
                    "Sign in with Google",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 15.5,
                    color: Colors.black87.withOpacity(0.60),
                    fontFamily: 'SF UI Display',
                    fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            onPressed: _handleGoogleSignIn,
            color: Colors.white,
          ),
        ),
        SizedBox(height: widget.partial ? 0 : 25),
        widget.partial ? SizedBox.shrink() : Row(
          children: <Widget>[
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width:  widget.partial ? 2 : 1,
                          color: Colors.grey.shade300))),
            )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "OR",
                style: TextStyle(
                    color: Colors.black26,
                    fontSize: widget.partial ? 18 : 14,fontWeight:  widget.partial ? FontWeight.bold : null ),
              ),
            ),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                        width:  widget.partial ? 2 : 1,
                          color: Colors.grey.shade300))),
            )),
          ],
        ),
        SizedBox(height: 20),
        Container(
          height: 45,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/facebook.png",
                  height: 25,
                  width: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text(
                    "Sign in with Facebook",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 15.5,
                    color: Colors.white,
                    fontFamily: 'SF UI Display',
                    fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            onPressed: _faceBook,
            color: Color(0xff0b5fcc),
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 45,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.phone_iphone,
                  color: Colors.white,
                  size: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text(
                    "Sign in with Phone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 15.5,
                    color: Colors.white,
                    fontFamily: 'SF UI Display',
                    fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            onPressed: () async {
              var str = await Navigator.of(context)
                  .push(CupertinoPageRoute<FirebaseUser>(
                      builder: (context) => new_auth.Authorization(
                            pop: true,
                          )));

              if (str != null) {
                showMd();
                this.realSign(await str.getIdToken(), str);
              }
            },
            color: Colors.black,
          ),
        ),
        SizedBox(height: 17),
        Container(
          height: 45,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.email,
                  size: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text(
                    "Sign in with Email",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 15.5,
                    color: Colors.black87.withOpacity(0.60),
                    fontFamily: 'SF UI Display',
                    fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            onPressed: () async {
             var user = await Navigator.of(context).push<User>(CupertinoPageRoute(builder: (context)=>old_auth.Authorization(login:true)));
             if( user != null && widget.canPop){
               Navigator.pop(context,user);
             }
            },
            color: Colors.white,
          ),
        ),
      ];
}
