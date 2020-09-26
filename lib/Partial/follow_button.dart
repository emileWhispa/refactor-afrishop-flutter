import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  final User follower;
  final User followed;
  final User Function() object;

  const FollowButton(
      {Key key, @required this.follower, @required this.followed,@required this.object})
      : super(key: key);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> with SuperBase {
  bool _checking = true;
  bool _following = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)=>this.checkStatus());
  }

  void checkStatus() {
    this.ajax(
        url:
            "discover/follow/follow/status/${widget.follower?.id}/${widget.followed?.id}",
        authKey: widget.object()?.token,
        server: true,
        onValue: (source, url) {
          setState(() {
            _checking = false;
            _following = source == "true";
          });
        });
  }

  void changeStatus() {
    setState(() {
      _checking = true;
    });
    this.ajax(
        url:
            "discover/follow/follow/user/${widget.follower.id}/${widget.followed.id}/${!_following}",
        authKey: widget.object()?.token,
        server: true,
        onValue: (source, url) {
          setState(() {
            _checking = false;
            _following = !_following;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.followed?.id == widget.follower?.id || widget.followed == null || widget.follower == null ? SizedBox.shrink() :  _checking
        ? RaisedButton(
            onPressed: null,
            child: CupertinoActivityIndicator(),
          )
        : _following
            ? FlatButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4)),
                onPressed: changeStatus,
                child: Text("Following"))
            : RaisedButton(
                onPressed: changeStatus,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                  side: BorderSide(
                    color: Color(0xffFEE606)
                  )
                ),
                color: Colors.yellow.shade100,
                child: Text("Follow"),
                elevation: 0.0,
              );
  }
}
