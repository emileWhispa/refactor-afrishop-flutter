import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';

class NewPassword extends StatefulWidget{
  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> with SuperBase{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text(
          "Reset Password",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Please enter your new password",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 70,
            margin: EdgeInsets.only(top: 10),
            child: TextFormField(
              decoration: InputDecoration(
                  hintText: "Password",
                  helperText: "Must be 8 or more characters",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.only(left: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade100))),
            ),
          ),
          Container(
            height: 45,
            margin: EdgeInsets.only(top: 10),
            child: TextFormField(
              decoration: InputDecoration(
                  hintText: "Confirm Password",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.only(left: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade100))),
            ),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: RaisedButton(
              onPressed: () {
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)
              ),
              elevation: 0.0,
              color: color,
              child: Text(
                "Submit",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          )
        ],
      ),
    );
  }
}