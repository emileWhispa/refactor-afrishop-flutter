
import 'package:afri_shop/Json/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';

class EmptyAccountDetail extends StatefulWidget {

  const EmptyAccountDetail(
      {Key key})
      : super(key: key);

  @override
  _EmptyAccountDetailState createState() => _EmptyAccountDetailState();
}

class _EmptyAccountDetailState extends State<EmptyAccountDetail> with SuperBase {
  User _user;
  var _key = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Image.asset(
                "assets/afrishop_logo@3x.png",
                width: 70,
                fit: BoxFit.fitWidth,
              ),
            ),Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 70),
                child: Text(
                  "Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
        centerTitle: true,
        elevation: 0.6,
      ),
      body: RefreshIndicator(
        key: _key,
        onRefresh: ()=>Future.value(),
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () {
                        showGeneralDialog(
                            context: context,
                            barrierColor: Colors.black12.withOpacity(0.6),
                            // background color
                            barrierDismissible: true,
                            // should dialog be dismissed when tapped outside
                            barrierLabel: "Dialog",
                            // label for barrier
                            transitionDuration: Duration(milliseconds: 400),
                            // how long it takes to popup dialog after button click
                            pageBuilder: (_, __, ___) {
                              return SizedBox.shrink();
                            },
                            transitionBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var wasCompleted = false;
                              if (animation.status ==
                                  AnimationStatus.completed) {
                                wasCompleted = true;
                              }

                              if (wasCompleted) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              } else {
                                return SlideTransition(
                                  position: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  ).drive(Tween<Offset>(
                                      begin: Offset(0, -1.0),
                                      end: Offset.zero)),
                                  child: child,
                                );
                              }
                            });
                      },
                      child: CircleAvatar(
                        radius: 27,
                      ),
                    ),
                  ),
                  Expanded(
                      child: InkWell(
                        onTap: () {
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Username",
                                style: style),
                            SizedBox(height: 3),
                            Text(
                              "Invitation code: ....",
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      )
                          ),
                  IconButton(
                      icon: Image.asset(
                        "assets/account_edit.png",
                        height: 24,
                        width: 24,
                      ),
                      onPressed: () {

                      })
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: (){},
                      child: Column(
                        children: <Widget>[
                          Text("${_user?.posts ?? 0}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Posts", style: TextStyle()),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: (){},
                      child: Column(
                        children: <Widget>[
                          Text("${_user?.likes ?? 0}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Likes", style: TextStyle()),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: (){},
                      child: Column(
                        children: <Widget>[
                          Text("${_user?.following ?? 0}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Following", style: TextStyle()),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        children: <Widget>[
                          Text("${_user?.followers ?? 0}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Followers", style: TextStyle()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade200,
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                              "MY ORDERS",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            )),
                        InkWell(
                          onTap: () {

                          },
                          child: Text(
                            "View All >",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {

                            },
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/unpaid.png",
                                    height: 21, width: 21),
                                SizedBox(height: 2.4),
                                Text("Unpaid"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {

                            },
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/purchased.png",
                                    height: 21, width: 21),
                                SizedBox(height: 2.4),
                                Text("Purchased"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {

                            },
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/arrived.png",
                                    height: 21, width: 21),
                                SizedBox(height: 2.4),
                                Text("Arrived"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {

                            },
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/finished.png",
                                    height: 21, width: 21),
                                SizedBox(height: 2.4),
                                Text("Finished"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),InkWell(
              onTap: (){},
              child: Container(
                color: Colors.grey.shade200,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  color: Colors.white70,
                  padding:
                  EdgeInsets.symmetric(vertical: 13, horizontal: 24),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                            "BECOME A MEMBER",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          )),
                      Text(
                        "Order cash back",
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade400,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                              "MY SERVICES",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () async {

                            },
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.favorite,
                                  color: Color(0xff4D4D4D),
                                ),
                                SizedBox(height: 2.4),
                                Text("Favorites"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {},
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/wallet.png",
                                    height: 21, width: 21),
                                SizedBox(height: 2.4),
                                Text("Wallet"),
                              ],
                            ),
                          ),
                        ),
//                        Expanded(
//                          child: InkWell(
//                            onTap: () {
//                              Navigator.of(context).push(CupertinoPageRoute(
//                                  builder: (context) => ContactUs(
//                                        user: widget.user(),
//                                      )));
//                            },
//                            child: Column(
//                              children: <Widget>[
//                                Image.asset("assets/contact_us.png",
//                                    height: 21, width: 21),
//                                SizedBox(height: 2.4),
//                                Text("Contact Us"),
//                              ],
//                            ),
//                          ),
//                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {

                            },
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/account_coupons.png",
                                    height: 24,
                                    width: 24,
                                    color: Color(0xff4D4D4D)),
                                SizedBox(height: 2.4),
                                Text("Coupons"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {

                            },
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/location.png",
                                    height: 21, width: 21),
                                SizedBox(height: 2.4),
                                Text("Address"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () async {

                            },
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/support.png",
                                    height: 21, width: 21),
                                SizedBox(height: 2.4),
                                Text("Support"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {

                              },
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                  "assets/share.png",
                                  height: 21,
                                  width: 21,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 2.4),
                                Text("Share"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox.shrink(), flex: 2),
//                        Expanded(
//                          child: InkWell(
//                            onTap: () {
//                              Navigator.of(context).push(CupertinoPageRoute(
//                                  builder: (context) => FrequentQuestion(
//                                    user: widget.user(),
//                                  )));
//                            },
//                            child: Column(
//                              children: <Widget>[
//                                Image.asset("assets/faq.png",height:21,width: 21),
//                                SizedBox(height: 2.4),
//                                Text("FAQ"),
//                              ],
//                            ),
//                          ),
//                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade200,
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                              "MY HOME PAGE",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () async {

                              },
                              child: InkWell(
                                onTap: (){},
                                child: Column(
                                  children: <Widget>[
                                    Text("${_user?.posts ?? "0"}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff4D4D4D))),
                                    SizedBox(height: 4.4),
                                    Text("Posts"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 1.5,
                            color: Colors.grey.shade400,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {

                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset("assets/camera.png",
                                      height: 21, width: 21),
                                  SizedBox(height: 4.4),
                                  Text("Release"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
//          ListTile(
//            onTap: () {
//              Navigator.of(context).push(CupertinoPageRoute(
//                  builder: (context) => CouponScreen(
//                        user: widget.user,
//                      )));
//            },
//            leading: Image.asset("assets/account_coupons.png",height: 24,width: 24),
//            title: Text("Coupons", style: style),
//            trailing: icon,
//          ),
          ],
        ),
      ),
    );
  }
}
