import 'dart:convert';

import 'package:afri_shop/Coupon.dart';
import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/address_info.dart';
import 'package:afri_shop/change_detail_screen.dart';
import 'package:afri_shop/change_detail_view.dart';
import 'package:afri_shop/discover_profile.dart';
import 'package:afri_shop/favorite.dart';
import 'package:afri_shop/follow_management.dart';
import 'package:afri_shop/income_screen.dart';
import 'package:afri_shop/invitation_welcome.dart';
import 'package:afri_shop/new_post.dart';
import 'package:afri_shop/pending_cart.dart';
import 'package:afri_shop/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

import 'Json/choice.dart';
import 'SuperBase.dart';
import 'Support.dart';
import 'cart_page.dart';
import 'old_authorization.dart';

class OldUserDetail extends StatefulWidget {
  final User Function() user;
  final void Function(String data) onLogOut;
  final void Function(User user) callback;
  final void Function(int index) jumpTo;
  final void Function(FormData data,List<Choice> list) uploadFile;
  final bool isSigned;
  final GlobalKey<CartScreenState> cartState;

  const OldUserDetail(
      {Key key,
      @required this.user,
      this.onLogOut,
      @required this.callback,
      this.isSigned: false, this.jumpTo,@required this.cartState,@required this.uploadFile})
      : super(key: key);

  @override
  _OldUserDetailState createState() => _OldUserDetailState();
}

class _OldUserDetailState extends State<OldUserDetail> with SuperBase {
  User _user;
  var _key = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _key.currentState?.show();
      if (widget.user() != null &&
          widget.user().requestInvitation &&
          !_invited) {
        widget.user().requestInvitation = false;
        _invite();
      }
    });
  }

  Future<void> fetchUser() {
    return this.ajax(
        url: "user/userById/${widget.user()?.id}",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          var map = json.decode(source);
          if( map['code'] == 1) {
            var js = map['data'];
            setState(() {
              _user = User.fromJson2(js);
              widget
                  .user()
                  ?.code = _user.code;
              widget
                  .user()
                  ?.invited = _user.invited;
              this.auth(jwt, jsonEncode(widget.user()), widget
                  .user()
                  ?.id);
            });
          }
        });
  }

  void showSuccess(String success) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image(
                    height: 120,
                    fit: BoxFit.cover,
                    image: AssetImage("assets/logo_circle.png")),
                SizedBox(height: 20),
                Text("$success",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))
              ],
            ),
          );
        });
  }

  bool get _invited => (_user ?? widget.user())?.invited == true;

  String get _code => (_user ?? widget.user())?.code ?? "---";

  void _goFollowing({int index: 1}) {
    Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => FollowManagement(
            user: widget.user,
            object: widget.user,
            index: index,
            callback: widget.callback)));
  }

  void _goProfile({bool likePage: false}) async {
    await waitUserCheck();
    if (widget.user() != null)
     await Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => DiscoverProfile(
                    user: widget.user,
                    callback: widget.callback,
                    object: widget.user,
                    liked: likePage,
                  )));
    widget.cartState?.currentState?.refresh();
  }

  Future<void> waitUserCheck() async {
    var _user = widget.user();
    if (_user == null) {
      _user = await Navigator.of(context).push(
          CupertinoPageRoute<User>(builder: (context) => Authorization()));
      if (widget.callback != null && _user != null) widget.callback(_user);
      setState(() {});
    }
    return Future.value();
  }

  void _invite() async {
    await Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => InvitationWelcome(
                user: widget.user, callback: widget.callback)));
    _key.currentState?.show();
  }

  void _goPending(int st) async {
    await Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => PendingCart(
                user: widget.user, callback: widget.callback,active: st,)));
    _key.currentState?.show();
    widget.cartState?.currentState?.refresh();
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
        onRefresh: fetchUser,
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
                              return Center(
                                  child: FadeInImage(
                                      image: widget.user()?.avatar != null
                                          ? CachedNetworkImageProvider(
                                              widget.user().avatar)
                                          : AssetImage(
                                              "assets/account_user.png"),
                                      placeholder: defLoader,
                                      fit: BoxFit.contain));
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
                        backgroundImage: CachedNetworkImageProvider(
                            "${widget.user()?.avatar}"),
                      ),
                    ),
                  ),
                  Expanded(
                      child: _invited
                          ? InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _code));
                                platform.invokeMethod(
                                    "toast", "Invitation code copied");
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(widget.user()?.username ?? "Username",
                                      style: style),
                                  SizedBox(height: 3),
                                  Text(
                                    "Invitation code: $_code",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                            )
                          : Text(widget.user()?.username ?? "Username",
                              style: style)),
                  IconButton(
                      icon: Image.asset(
                        "assets/account_edit.png",
                        height: 24,
                        width: 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => UserProfile(
                                  user: widget.user,
                                  callback: widget.callback,
                                )));
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
                      onTap: this._goProfile,
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
                      onTap: () => this._goProfile(likePage: true),
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
                      onTap: _goFollowing,
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
                      onTap: () => this._goFollowing(index: 0),
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
                          onTap: () =>this._goPending(0),
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
                            onTap: () =>this._goPending(1),
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
                            onTap: () =>this._goPending(2),
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
                            onTap: () =>this._goPending(3),
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
                            onTap: () =>this._goPending(4),
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
            ),
            _invited
                ? Container(
                    color: Colors.grey.shade200,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (ctx) => IncomeScreen(
                                          user: widget.user,
                                        )));
                            _key.currentState?.show();
                          },
                          child: Container(
                            color: Colors.white70,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(child: Text("Cash income")),
                                    Text(
                                      "All >",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(21.0),
                                  child: Text(
                                    "\$${(_user?.walletStr ?? "0.0")}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 29,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xff4D4D4D)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        NetworkScreen(user: widget.user)));
                          },
                          child: Container(
                            color: Colors.white70,
                            margin: EdgeInsets.only(left: 10),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(child: Text("My network")),
                                    Text(
                                      "All >",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(21.0),
                                  child: Text(
                                    "${_user?.networks ?? 0}",
                                    style: TextStyle(
                                        fontSize: 29,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xff4D4D4D)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  )
                : InkWell(
                    onTap: _invite,
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
                              await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => Favorite(
                                            user: widget.user,
                                            callback: widget.callback,
                                          )));
                              widget.cartState?.currentState?.refresh();
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
                        _invited ? Expanded(
                          child: InkWell(
                            onTap: _invited
                                ? () async {
                                    await Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (ctx) => ChangeDetailView(
                                                  user: widget.user,
                                                )));
                                    _key.currentState?.show();
                                  }
                                : () {},
                            child: Column(
                              children: <Widget>[
                                Image.asset("assets/wallet.png",
                                    height: 21, width: 21),
                                SizedBox(height: 2.4),
                                Text("Wallet"),
                              ],
                            ),
                          ),
                        ) : SizedBox.shrink(),
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
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => CouponScreen(
                                        user: widget.user,
                                      )));
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
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => AddressInfo(
                                            user: widget.user,
                                          )));
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
                              var d = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => Support(
                                            user: widget.user,
                                            callback: widget.callback,
                                          )));
                              if (d == "result" && widget.onLogOut != null) {
                                widget.onLogOut('$d');
                              }
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
                              Share.share(
                                  "https://play.google.com/store/apps/details?id=io.dcloud.H52FE1175&hl=en ${_invited ? "please use my invitation code: ${(_user ?? widget.user())?.code}, to become afrishop member and enjoy a 10% discount" : ""} ",
                                  subject: "Share subject");
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
                        Expanded(child: SizedBox.shrink(), flex: _invited ? 2 : 1),
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
                                await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => DiscoverProfile(
                                            user: widget.user,
                                            object: widget.user,
                                            callback: widget.callback)));
                                widget.cartState?.currentState?.refresh();
                              },
                              child: InkWell(
                                onTap: _goProfile,
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
                                var x = await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => NewPostScreen(
                                          uploadFile: widget.uploadFile,
                                            user: widget.user,
                                            callback: widget.callback)));
                                if (x != null) {
                                  widget.cartState?.currentState?.refresh();
                                  _key.currentState?.show();
                                  if( widget.jumpTo != null ){
                                    widget.jumpTo(1);
                                  }
                                }
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
