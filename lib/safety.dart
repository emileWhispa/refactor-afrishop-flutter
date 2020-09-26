import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SafetyFirst extends StatefulWidget{
  @override
  _SafetyFirstState createState() => _SafetyFirstState();
}

class _SafetyFirstState extends State<SafetyFirst> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      content: Column(
        children: <Widget>[
          Image(image: AssetImage("assets/safety.png"),height: 350,fit: BoxFit.fitHeight,),
          SizedBox(height: 12),
          Image(image: AssetImage("assets/purchase.png"),)
        ],
      ),
    );
  }
}