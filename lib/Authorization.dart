import 'package:afri_shop/PhoneAuthExample.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Json/User.dart';
import 'SuperBase.dart';

class Authorization extends StatefulWidget {
  final bool pop;
  final void Function(FirebaseUser user) onLog;

  const Authorization({Key key, this.pop: true, this.onLog}) : super(key: key);

  @override
  _AuthorizationState createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> with SuperBase {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void signUp() {

  }


  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: PhoneAuthExample(
        scaffoldKey: _scaffoldKey,
        onLog: widget.pop ? (user)=> Navigator.of(context).pop(user) : widget.onLog,
      ),);
  }
}
