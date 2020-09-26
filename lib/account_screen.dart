import 'package:afri_shop/old_user_detail.dart';

import 'Json/User.dart';
import 'SuperBase.dart';
import 'old_authorization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;
  final bool partial;
  final void Function(int index) jumpTo;

  const AccountScreen({Key key,@required this.user,@required this.callback, this.partial:false, this.jumpTo}) : super(key: key);
  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with SuperBase {


  void populate(User user) {
    setState(() {

    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
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
    return widget.user() != null
        ? OldUserDetail(user: widget.user,onLogOut: (d){
          setState(() {
            widget.callback(null);
          });
    },callback: widget.callback,jumpTo: widget.jumpTo,)
        : Scaffold(
            appBar: widget.partial ? null : AppBar(
              backgroundColor: color,
              title: Row(
                children: <Widget>[
                  Image.asset("assets/afrishop_logo@3x.png",width: 70,fit: BoxFit.fitWidth,),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(right:70.0),
                    child: Text("Account",style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  )),
                ],
              ),
              centerTitle: true,
              elevation: 0.6,
            ),
            backgroundColor: widget.partial ? Colors.transparent : null,
            body: ListView(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: _dec,
                        child: Center(
                          child: Text("!",style: TextStyle(fontSize: 120,fontWeight: FontWeight.bold,color: Colors.black26),),
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
                  height: 40,
                ),
                Text(
                  "You need to login first",
                  style: TextStyle(fontFamily: 'SF UI Display',fontWeight: FontWeight.normal,fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 38,
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    borderRadius: BorderRadius.circular(5),
                    child: Text("Sign up with Phone or Email",style: TextStyle(fontSize: 15.5,color: Colors.black87.withOpacity(0.60),fontFamily: 'SF UI Display',fontWeight: FontWeight.bold),),
                    onPressed: () async {
                      var str = await Navigator.of(context).push(
                          CupertinoPageRoute<User>(
                              builder: (context) => Authorization(login: false,)));
                      setState(() {
                        //str.requestInvitation = true;
                        widget.callback(str);
                      });
                    },
                    color: Color(0xffffe707),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          border:
                              Border(top: BorderSide(color: Colors.grey.shade300))),
                    )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "OR",
                        style: TextStyle(color: Colors.black26, fontSize: 14),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          border:
                              Border(top: BorderSide(color: Colors.grey.shade300))),
                    )),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Already have account?",
                      style: TextStyle(color: Colors.grey,fontSize: 12.5),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: InkWell(
                          onTap: () async {
                            var str = await Navigator.of(context).push(
                                CupertinoPageRoute<User>(
                                    builder: (context) => Authorization()));
                            setState(() {
                              //str.requestInvitation = true;
                              widget.callback(str);
                            });
                          },
                          child: Text(
                            "Sign In.",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          )),
                    )
                  ],
                )
              ],
            ),
          );
  }
}
