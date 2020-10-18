import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'Json/coupon.dart';
import 'Json/order.dart';
import 'SuperBase.dart';

class SelectCouponScreen extends StatefulWidget {
  final User Function() user;
  final String payNowParams;
  final Order order;
  final String coupon;

  const SelectCouponScreen({Key key, @required this.user, this.payNowParams,@required this.order, this.coupon}) : super(key: key);

  @override
  _SelectCouponScreenState createState() => _SelectCouponScreenState();
}

class _SelectCouponScreenState extends State<SelectCouponScreen>
    with SuperBase {
  List<Coupon> _validList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => refreshKey.currentState?.show());
  }



  void _sendCoupon() {

    if( widget.order?.totalPrice != null && widget.order.totalPrice >= _coupon.withAmount) {
      setState(() {
        _sending = true;
      });
      this.ajax(
          url: widget.payNowParams != null
              ? "order/payNow?${widget.payNowParams}&toitableId=${_coupon
              ?.toitableId}"
              : "order/settle?toitableId=${_coupon?.toitableId}",
          method: widget.payNowParams != null
              ? "GET" : "POST",
          jsonData: widget.payNowParams != null
              ? null : jsonEncode(widget.order.itemList.map((e) => e.id).toList()),
          onValue: (source, url) {
            print(source);
            print(url);
            var map = json.decode(source);
            if (map != null && map['code'] == 1) {
              var _order = Order.fromJson(map['data']);
              _order.couponId = _coupon?.toitableId;
              print("Discovered price : ${_order?.realityPay}");
              Navigator.pop(context, _order);
            } else {
              platform.invokeMethod("toast", map['message']);
            }
          },
          server: true,
          authKey: widget
              .user()
              ?.token,
          auth: true,
          onEnd: () {
            setState(() {
              _sending = false;
            });
          });
    }else{
      platform.invokeMethod("toast","Coupon not allowed for this order");
    }
  }

  void _sendCoupon2() {

    if( widget.order?.subTotalPrice != null && widget.order.subTotalPrice >= _coupon.withAmount) {
      Navigator.pop(context,_coupon);
    }else{
      platform.invokeMethod("toast","Coupon not allowed for this order");
    }
  }

  Future<void> _loadCoupons() async {
    return this.ajax(
        url: "coupon",
        auth: true,
        authKey: widget.user()?.token,
        error: (s, v) => print(s),
        onValue: (source, url) {
          var _map = json.decode(source)['data'];
          if (_map == null) return;
          Iterable map = _map['validCouponList'];
          setState(() {
            if (map != null) {
              _validList = map.map((f) => Coupon.fromJson(f)).toList();
              if( _validList.any((element) => element.toitableId == widget.coupon) ){
                _coupon = _validList.firstWhere((element) => element.toitableId == widget.coupon);
              }
            }
          });
        });
  }

  var refreshKey = new GlobalKey<RefreshIndicatorState>();

  Coupon _coupon;

  bool _sending = false;

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
        title: Text("Coupon"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _loadCoupons,
          child: Scrollbar(
              child: _validList.isEmpty
                  ? ListView(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(top: 70),
                            child: Image.asset("assets/coupon-empty.jpg",
                                height: 150)),
                        Center(
                            child: Text(
                          "No available coupons",
                          style:
                              TextStyle(fontSize: 18, color: Color(0xff999999)),
                        )),
                        SizedBox(height: 40)
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: _validList.length,
                              itemBuilder: (context, index) {
                                var coupon = _validList[index];
                                return Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        height: 130,
                                        margin: EdgeInsets.only(bottom: 20,right:7),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/coupons-layer.png"),
                                                fit: BoxFit.fitWidth)),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: Container(
                                              decoration: BoxDecoration(),
                                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    "${coupon.couponTitle}",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily:
                                                            'SF UI Display',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    "Available for over \$${coupon.withAmount}",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        height: 1.6,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'SF UI Display'),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    "Valid ${coupon.parseStart} - ${coupon.parseEnd}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'SF UI Display',
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        height: 1.2,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Container(
                                              padding: EdgeInsets.all(10)
                                                  .copyWith(left: 65),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text("\$${coupon.deductAmount}",
                                                      style: TextStyle(
                                                          fontSize: 22,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'SF UI Display')),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _coupon = coupon;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                            border: _coupon?.id == coupon?.id
                                                ? null
                                                : Border.all(
                                                    color: Colors.grey),
                                            shape: BoxShape.circle,
                                            color: _coupon?.id == coupon?.id
                                                ? color
                                                : Colors.white),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              _coupon?.id == coupon?.id ? 2.0 : 11),
                                          child: _coupon?.id == coupon?.id
                                              ? Icon(
                                                  Icons.check,
                                                  size: 20.0,
                                                  color: Colors.black,
                                                )
                                              : SizedBox.shrink(),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }),
                        ),
                        Container(
                          decoration: BoxDecoration(
                          ),
                          child: _sending
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: CupertinoActivityIndicator(),
                                  ),
                                )
                              : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                                child: RaisedButton(
                                    onPressed: _coupon == null ? (){} : _sendCoupon,
                                    child: Text("Confirm",
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold)),
                                    elevation: 0.5,
                                    color: _coupon == null ? color : color),
                              ),
                        )
                      ],
                    ))),
      backgroundColor: Color(0xffF4F4F4),
    );
  }
}
