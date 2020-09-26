import 'package:cached_network_image/cached_network_image.dart';
import 'package:afri_shop/pending_cart.dart';
import 'package:afri_shop/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Authorization.dart';
import 'Json/User.dart';
import 'SuperBase.dart';

class SecondAccountScreen extends StatefulWidget {
  final User user;
  final void Function(User user) callback;

  const SecondAccountScreen({Key key, this.user, this.callback}) : super(key: key);

  @override
  SecondAccountScreenState createState() => SecondAccountScreenState();
}

class SecondAccountScreenState extends State<SecondAccountScreen>
    with SuperBase {
  User _user;

  void populate(User user) {
    setState(() {
      _user = user;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _user == null
        ? Authorization(
      pop: false,
//            onLog: (user) {
//              setState(() {
//                //_user = user;
//              });
//              //if( widget.callback != null ) widget.callback(user);
//            },
          )
        : Scaffold(
            body: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: 275,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 245,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                              Colors.grey.shade100,
                              Colors.grey.shade200,
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                              Colors.grey.shade500
                            ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                        padding:
                            EdgeInsets.all(10).copyWith(bottom: 20, top: 60),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  InkWell(
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage("assets/clement.jpeg"),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "${_user.username}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text("RWF"),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                      icon: Icon(Icons.settings),
                                      onPressed: () async {
                                        User user = await Navigator.of(context)
                                            .push(CupertinoPageRoute(
                                                builder: (context) =>
                                                    UserProfile(
                                                      user: ()=>_user,
                                                      callback: widget.callback,
                                                    )));
                                        if (user != null) {
                                          setState(() {
                                            _user = user;
                                          });
                                        }
                                      })
                                ],
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Add email address",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Add email address,Add email address,Add email address,Add email address,Add email address,Add email address,Add email address,",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: _user != null
                                ? Container(
                                    child: Card(
                                      elevation: 4.0,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: InkWell(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                          Icons.favorite_border,
                                                          size: 17),
                                                      SizedBox(height: 3.5),
                                                      Text("Wish list"),
                                                    ],
                                                  ),
                                                  onTap: () {}),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.star_border,
                                                        size: 17,
                                                      ),
                                                      SizedBox(height: 3.5),
                                                      Text("Following"),
                                                    ],
                                                  ),
                                                  onTap: () {}),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons
                                                            .account_balance_wallet,
                                                        size: 17,
                                                      ),
                                                      SizedBox(height: 3.5),
                                                      Text("Coupons"),
                                                    ],
                                                  ),
                                                  onTap: () {}),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : RaisedButton(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(68.0),
                                    ),
                                    padding: EdgeInsets.all(15),
                                    onPressed: () async {
                                      User user = await Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                              builder: (context) =>
                                                  Authorization()));
                                      if (user != null) {
                                        setState(() {
                                          _user = user;
                                        });
                                      }
                                    },
                                    child: Text(
                                      "LOGIN / REGISTER",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange),
                                    ),
                                    elevation: 4.5,
                                  ),
                          ),
                        ),
                        bottom: 0,
                        left: 0,
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(30).copyWith(top: 0),
                ),
                Container(height: 10, color: Colors.grey.withOpacity(0.3)),
                Container(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          if (_user != null) {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) =>
                                    PendingCart(user: ()=>_user,callback: null,)));
                          }
                        },
                        leading: Icon(
                          Icons.bookmark_border,
                          size: 30,
                        ),
                        title: Text(
                          "My order",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: CupertinoButton(
                          child: Text("View all"),
                          onPressed: () {},
                          padding: EdgeInsets.only(right: 0),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        title: Text(
                          "Unpaid",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        title: Text(
                          "To be shipped",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        title: Text(
                          "Shipped",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 10, color: Colors.grey.withOpacity(0.3)),
                GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 1000,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2),
                    itemBuilder: (context, index) {
                      return Container(
                        child: Image(
                            image: CachedNetworkImageProvider(
                                "https://www.stylishmenz.com/wp-content/uploads/2019/05/Men-Tracksuit-Sets-Pullover-Hoodies-Pants-Sportwear-Suit-Male-Hoodies-plus-men-clothes-2018-Hot-spring-3.jpg_640x640-3.jpg"),
                            frameBuilder: (context, child, frame, was) =>
                                frame == null
                                    ? Center(
                                        child: CupertinoActivityIndicator())
                                    : child),
                      );
                    })
              ],
            ),
          );
  }

  Widget get _lockPage => Row(
        children: <Widget>[
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.lock_open),
                onPressed: () {
                  if (_user != null) {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => PendingCart(user:()=> _user)));
                  }
                },
                iconSize: 45,
              ),
              Text(
                "Pending Payments",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              )
            ],
          )),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.directions_bus),
                onPressed: () {},
                iconSize: 45,
              ),
              Text(
                "In Transit (Shipping)",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              )
            ],
          )),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chat_bubble),
                onPressed: () {},
                iconSize: 45,
              ),
              Text(
                "Pending Feedback",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              )
            ],
          )),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.settings_backup_restore),
                onPressed: () {},
                iconSize: 45,
              ),
              Text(
                "Return & Refund",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              )
            ],
          )),
        ],
      );
}
