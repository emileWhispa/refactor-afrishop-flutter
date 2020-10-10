import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/invitation_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';

class AfrishopCodePage extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const AfrishopCodePage(
      {Key key, @required this.user, @required this.callback})
      : super(key: key);

  @override
  _AfrishopCodePageState createState() => _AfrishopCodePageState();
}

class _AfrishopCodePageState extends State<AfrishopCodePage> with SuperBase {

  var code = "000000";

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
            "Member",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Text(
                "I don't have an invitation code",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
              ),
            ),
            Text(
              "Please use $code as an invitation code",
              style:
                  TextStyle(fontWeight: FontWeight.w900, color: Colors.orange),
            ),
            Container(
              margin: EdgeInsets.only(top: 30,bottom: 160),
              height: 45,
              width: double.infinity,
              child: RaisedButton(
                elevation: 0.0,
                onPressed: () async {
                  var d = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => InvitationCode(
                              user: widget.user, callback: widget.callback,code: code,)));
                  if (d != null) {
                    Navigator.pop(context, d);
                  }
                },
                color: color,
                padding: EdgeInsets.all(16),
                child: Text(
                  "Next",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
