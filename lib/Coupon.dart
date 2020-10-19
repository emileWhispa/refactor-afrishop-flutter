import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'Json/coupon.dart';
import 'SuperBase.dart';

class TrapeziumClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 2 / 3, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TrapeziumClipper oldClipper) => false;
}

class CouponScreen extends StatefulWidget {
  final User Function() user;

  const CouponScreen({Key key, @required this.user}) : super(key: key);

  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> with SuperBase {
  List<Coupon> _validList = [];
  List<Coupon> _usedList = [];
  List<Coupon> _expiredList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this._loadCoupons());
  }

  int _index = 0;

  List<String> get _menus => [
        // "Valid",
        // "Used",
        // "Expired",
      ];

  Future<void> _loadCoupons() async {
    return this.ajax(
        url: "coupon",
        auth: true,
        authKey: widget.user()?.token,
        error: (s,v)=>print(s),
        onValue: (source, url) {
          var _map = json.decode(source)['data'];
          if( _map == null ) return;
          Iterable map = _map['validCouponList'];
          Iterable map2 = _map['usedCouponList'];
          Iterable map3 = _map['expiredCouponList'];
          setState(() {
            if (map != null)
              _validList = map.map((f) => Coupon.fromJson(f)).toList();
            if (map2 != null)
              _usedList = map2.map((f) => Coupon.fromJson(f)).toList();
            if (map3 != null)
              _expiredList = map3.map((f) => Coupon.fromJson(f)).toList();
          });
        });
  }

  PageController _controller = new PageController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text("Coupon"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          // Container(
          //   height: 50,
          //   color: Colors.white,
          //   child: Row(
          //     children: List.generate(_menus.length, (index) {
          //       return Expanded(
          //         child: InkWell(
          //           child: Container(
          //               padding:
          //                   EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          //               decoration: _index == index
          //                   ? BoxDecoration(
          //                       border: Border(
          //                           bottom:
          //                               BorderSide(color: color, width: 2.5)))
          //                   : null,
          //               child: Text(
          //                 "${_menus[index]}",
          //                 textAlign: TextAlign.center,
          //                 style: TextStyle(
          //                     color: Colors.black, fontWeight: _index == index ? FontWeight.bold : null,fontFamily: 'SF UI Display'),
          //               )),
          //           onTap: () {
          //             setState(() {
          //               _index = index;
          //               _controller.jumpToPage(index);
          //             });
          //           },
          //         ),
          //       );
          //     }),
          //   ),
          // ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _index = index;
                });
              },
              children: <Widget>[
                _CouponList(
                  list: _validList,
                  loadCoupons: _loadCoupons,
                  expired: 1,
                ),
                // _CouponList(
                //   list: _usedList,
                //   loadCoupons: _loadCoupons,
                //   expired: 2,
                // ),
                // _CouponList(
                //   list: _expiredList,
                //   loadCoupons: _loadCoupons,
                //   expired: 3,
                // ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xffF4F4F4),
    );
  }
}

class _CouponList extends StatefulWidget {
  final List<Coupon> list;
  final Future<void> Function() loadCoupons;
  final int expired;

  const _CouponList({Key key, @required this.list, @required this.loadCoupons, this.expired})
      : super(key: key);

  @override
  __CouponListState createState() => __CouponListState();
}

class __CouponListState extends State<_CouponList> with SuperBase {
  var refreshKey = new GlobalKey<RefreshIndicatorState>();

  Future<void> _loadCoupons() {
    refreshKey.currentState?.show(atTop: true);
    return widget.loadCoupons();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this._loadCoupons());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshIndicator(
        key: refreshKey,
        onRefresh: _loadCoupons,
        child: Scrollbar(
            child: widget.list.isEmpty ? ListView(
              children: <Widget>[
                Container(margin: EdgeInsets.only(top: 70),child: Image.asset("assets/coupon-empty.jpg",height:150)),
                Center(child: Text("No available coupons",style: TextStyle(fontSize: 18,color: Color(0xff999999)),)),
                SizedBox(height: 40)
              ],
            ) : ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: widget.list.length,
                itemBuilder: (context, index) {
                  var coupon = widget.list[index];
                  return Container(
                    height: 130,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage("assets/${widget.expired != 1 ? "coupons-dis.png" : "coupons-layer.png"}"),fit: BoxFit.fitWidth)
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(),
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${coupon.couponTitle}",
                                style: TextStyle(
                                    color: Colors.white,fontFamily: 'SF UI Display',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800),
                              ),
                              Text(
                                "Available for over \$${coupon.withAmount}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.6,
                                    fontWeight: FontWeight.w400,fontFamily: 'SF UI Display'),
                              ),
                              Spacer(),
                              Text(
                                widget.expired == 1 ? "Valid":widget.expired == 2 ? "Used":"Expired",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'SF UI Display',
                                    color: widget.expired == 1 ? Colors.white : widget.expired == 2 ? Colors.orange : Colors.red,
                                    fontSize: 14,
                                    height: 1.6,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Valid ${coupon.parseStart} - ${coupon.parseEnd}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'SF UI Display',
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.6,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        )),
                        Container(
                          padding: EdgeInsets.all(10).copyWith(left: 65),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("\$${coupon.deductAmount}",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,fontFamily: 'SF UI Display')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                })));
  }
}
