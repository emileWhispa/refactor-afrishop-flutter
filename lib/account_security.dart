import 'package:afri_shop/email_security.dart';
import 'package:afri_shop/password_security.dart';
import 'package:afri_shop/phone_security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class AccountSecurity extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const AccountSecurity({Key key, @required this.user, @required this.callback})
      : super(key: key);

  @override
  _AccountSecurityState createState() => _AccountSecurityState();
}

class _AccountSecurityState extends State<AccountSecurity> with SuperBase {
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
          "Account security",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => PhoneSecurity(
                            user: widget.user,
                            callback: widget.callback,
                          )));
              setState(() {});
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.phone_iphone,
                    size: 26,
                    color: color,
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Phone",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                  )),
                  Text(
                    "${widget.user()?.phone ?? ""}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => EmailSecurity(
                          user: widget.user, callback: widget.callback)));
              setState(() {});
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.email,
                    size: 26,
                    color: color,
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Email address",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                  )),
                  Text(
                    "${widget.user()?.email ?? ""}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
         widget.user()?.type == 1 ? InkWell(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => PasswordSecurity(
                        user: widget.user,
                      )));
            },
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.lock,
                    size: 26,
                    color: color,
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Password",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
                ],
              ),
            ),
          ) : SizedBox.shrink(),
        ],
      ),
    );
  }
}
