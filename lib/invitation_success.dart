import 'package:afri_shop/invitation_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class InvitationSuccess extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;

  const InvitationSuccess(
      {Key key, @required this.user, @required this.callback})
      : super(key: key);

  @override
  _InvitationSuccessState createState() => _InvitationSuccessState();
}

class _InvitationSuccessState extends State<InvitationSuccess> with SuperBase {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var s = TextStyle(color: Color(0xff666666));
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  "assets/success.png",
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Application submitted successfully",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
            ),
            Text(
                "The audit will be completed within 3 working days, please contact customer service if you have any questions",
                style: s),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: RaisedButton(
                onPressed: () async {
                    Navigator.pop(context,"done");
                },
                color: color,
                child: Text("DONE",style: TextStyle(fontWeight: FontWeight.w900),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
