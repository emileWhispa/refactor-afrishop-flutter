import 'dart:async';
import 'dart:convert';

import 'package:afri_shop/Json/Address.dart';
import 'package:afri_shop/Json/Cart.dart';
import 'package:afri_shop/Json/Logistic.dart';
import 'package:afri_shop/Json/coupon.dart';
import 'package:afri_shop/description.dart';
import 'package:afri_shop/failure.dart';
import 'package:afri_shop/select_coupon.dart';
import 'package:afri_shop/webview_example.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'Json/Post.dart';
import 'Json/User.dart';
import 'Json/order.dart';
import 'Json/flutter_wave.dart';
import 'PaymentSuccess.dart';
import 'address_info.dart';
import 'flutter_form.dart';
import 'SuperBase.dart';

class CompleteOrder extends StatefulWidget {
  final User Function() user;
  final List<Cart> list;
  final Order order;
  final Order completedOrder;
  final bool fromOrders;
  final bool continueToPayment;
  final String payNowParams;
  final void Function(User user) callback;
  final String ordersId;

  const CompleteOrder(
      {Key key,
      @required this.user,
      @required this.list,
      this.order,
      this.continueToPayment: false,
      this.fromOrders: false,
      this.completedOrder,
      @required this.callback,
      this.payNowParams, this.ordersId})
      : super(key: key);

  @override
  _CompleteOrderState createState() => _CompleteOrderState();
}

class _CompleteOrderState extends State<CompleteOrder> with SuperBase {
  var _addingToCart = false;
  Timer _timer;
  Duration _duration;
  List<Cart> products = [];
  List<Post> posts = [];

  Address _address;
  int itemNum = 0;

  List<Logistic> _logistics = [];

  Future<void> _getLogisticDetails() {
    return this.ajax(
        url: "logistics/getOrderLogistics/${widget.ordersId}",
        auth: true,
        authKey: widget.user()?.token,
        server: true,
        error: (s, v) => print(s),
        onValue: (source, url) {
          print(source);
          print(url);
          var dx = json.decode(source);
          var d = dx['data'];
          if (d != null && dx['code'] == 1) {
            Iterable data = d['content'];
            setState(() {
              if (data.isNotEmpty) {
                _logistics = (data.first['data'] as Iterable)
                    .map((f) => Logistic.fromJson(f))
                    .toList();
              }
            });
          }
        });
  }

  void getDefault() {
    getDefaultAddress().then((value){
      _address = value;
      if( value == null){
        getOtherDefault();
      }
    });
  }

  void getOtherDefault(){
    this.ajax(
        url: "address/default",
        authKey: widget.user()?.token,
        auth: true,
        onValue: (source, url) {
          var data = json.decode(source)['data'];
          if (data == null) return;
          setState(() {
            _address = Address.fromJson(data);
            setDefaultAddress(_address);
          });
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  void autoClose() {
    setState(() {
      _order?.orderStatus = 60;
      _order2?.orderStatus = 60;
    });
    this.ajax(
        url:
            "order/cancelOrder?orderId=${widget.order?.orderId}&reason=${Uri.encodeComponent("Time out")}",
        authKey: widget.user()?.token,server: true);
  }

  @override
  void initState() {
    super.initState();

    _order = widget.completedOrder;
    _order2 = widget.order;
    widget.list.map((e) {
      setState(() {
        itemNum = itemNum + e.itemNum;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //this.checkVisitedLink();
      getDefault();
      _getLogisticDetails();
      if (widget.continueToPayment && widget.completedOrder != null) {
        goCheckOut(widget.completedOrder);
      }
      //DateFormat format = new DateFormat("MMM dd, yyyy hh:mm:ss");
      // print(order?.orderTime);
      var now = DateTime.now();
      var formattedDate = order?.getDate ?? now;
      var addedTime = formattedDate.add(Duration(hours: 24));
      setState(() {
        // _diffDt = addedTime.difference(_addDt);
        if (order?.closedByTime == true) {
          autoClose();
        }
          _duration = addedTime.difference(DateTime.now());
      });
      _timer = Timer.periodic(Duration(seconds: 1), (t) {
        if (_duration == Duration(hours: 0)) {
          setState(() {
            _duration = Duration(hours: 0);
          });
        } else {
          setState(() {
            _duration = Duration(seconds: _duration.inSeconds - 1);
          });
        }
        // setState(() {
        //   _duration = Duration(seconds: _duration.inSeconds - 1);
        // });
      });
    });
  }

  void checkVisitedLink() async {
    var list = await getVisitedPost();
    var newList = list
        .where((f) => f.products.any((f) {
              print("fav : ${f.product.itemId} => ${f.product.title}");
              return widget.order.itemList.any((x) {
                print("order : ${x.itemId} => ${x.itemTitle}");
                return x.itemId == f.product.itemId;
              });
            }))
        .toList();
    print(list.length);
    var newList0 = widget.order.itemList
        .where((fx) => list
            .any((f) => f.products.any((x) => x.product?.itemId == fx.itemId)))
        .toList();
    if (newList.isNotEmpty && newList0.isNotEmpty) {
      setState(() {
        products = newList0.toList();
        posts = newList.toList();
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Container(
                height: MediaQuery.of(context).size.height - 250,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(
                        "Bonus Alert",
                        style: Theme.of(context).textTheme.headline.copyWith(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(products.length, (index) {
                        var post = posts.length > index
                            ? posts[index]
                            : posts.isNotEmpty
                                ? posts.first
                                : null;
                        var product = products[index];

                        if (post == null) return SizedBox.shrink();

                        return _ValidateBonus(
                            post: post, product: product, user: widget.user);
                      }),
                    ),
                  ],
                ),
              ),
              contentPadding: EdgeInsets.all(7),
            );
          });
    }
  }

  void showSuccess() async {
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
                Text("Address changed successfully",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))
              ],
            ),
          );
        });
  }

  bool get canCheckOut =>
      order == null || order?.isPending == true || !widget.fromOrders;

  bool get canCoupon =>
      canCheckOut &&
      order?.couponId != null &&
      order?.couponPrice != null &&
      order.couponPrice > 0;

  bool get canCheckOut2 => canCheckOut && widget.fromOrders;

  bool get pending => order?.isPending == true && widget.fromOrders;

  void _cancelOrder() async {
    var x = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
        builder: (context) {
          return _DeleteOrder(order: order, user: widget.user);
        });
    if (x != null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                })
            : null,
        title: Text(
          canCheckOut ? "Check out" : "Detail",
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          canCheckOut2
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image(
                        image: AssetImage("assets/order_detail.png"),
                        height: 100),
                    SizedBox(height: 12),
                    Text(
                      "Pending Payment",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    Text(
                      printDuration(_duration),
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Payment Countdown Order Timeout Order Expiration",
                      style: TextStyle(fontSize: 13, color: Color(0xff999999)),
                    ),
                    SizedBox(height: 12),
                  ],
                )
              : SizedBox.shrink(),
          InkWell(
            onTap: _order == null
                ? () async {
                    Address address = await Navigator.of(context).push(
                        CupertinoPageRoute(
                            builder: (context) => AddressInfo(
                                select: true,
                                defaultAd: _address,
                                title: "Select address",
                                user: widget.user)));
                    if (address == null) {
                      platform.invokeMethod("toast", "No address selected");
                      setState(() {
                        _address = address;
                      });
                      return;
                    } else {
                      showSuccess();
                      setState(() {
                        _address = address;
                      });
                    }
                  }
                : null,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _address == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "You Have No Address",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                    "Please Fill in The Address (Click it To Edit)"),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    "${order?.deliveryAddress ?? _address?.address}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        "${order?.deliveryPhone ?? _address?.phone}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                  "${order?.deliveryName ?? _address?.delivery}")
                            ],
                          ),
                  ),
                  _order == null
                      ? Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.list.length,
              itemBuilder: (context, index) {
                var pro = widget.list[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => Description(
                                product: pro.product,
                                user: widget.user,
                                callback: widget.callback)));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image(
                          image: CachedNetworkImageProvider(pro.itemImg),
                          height: 60,
                          width: 60,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${pro.itemTitle}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text("${pro.itemSku}"),
                                SizedBox(height: 5),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Color(0xffffe707),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                        '\$${pro.itemPrice?.toStringAsFixed(2) ?? 0.0}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Spacer(),
                                    Text("x${pro.itemNum}")
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            margin: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Order Summary",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text("Merchandise Total"),
                  trailing: Text("\$$total2"),
                ),
                ListTile(
                    onTap: () {},
                    title: Text("Shipping Fee"),
                    trailing: Text(order?.expressCost == 0
                        ? "\$${0}"
                        : "${order?.expressCost}")),
                ListTile(
                  onTap: () {},
                  title: Text("Handling Fee"),
                  trailing: Text(order?.fee == 0 ? "\$${0}" : "${order?.fee}"),
                ),
                ListTile(
                  onTap: () {},
                  title: Text("Duty Fee"),
                  trailing: Text(order?.tax == 0 ? "\$${0}" : "${order?.tax}"),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: canCoupon ? color.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4.5),
                          bottomRight: Radius.circular(4.5))),
                  child: ListTile(
                    onTap: () async {
                      if (_order == null) {
                        var order1 = await Navigator.push(
                            context,
                            CupertinoPageRoute<Order>(
                                builder: (context) => SelectCouponScreen(
                                    user: widget.user,
                                    payNowParams: widget.payNowParams,
                                    coupon: order?.couponId,
                                    order: order)));
                        if (order1 != null) {
                          setState(() {
                            _order2 = order1;
                          });
                        }
                      }
                    },
                    title: Text(
                      "Coupon",
                      style: TextStyle(color: canCoupon ? Colors.orange : null),
                    ),
                    trailing: canCheckOut
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                  order?.couponPrice == null
                                      ? "-\$${0}"
                                      : "${order?.couponPrice}",
                                  style: TextStyle(
                                      color: canCoupon ? Colors.orange : null)),
                              Icon(Icons.arrow_forward_ios,
                                  size: 13,
                                  color: canCoupon ? Colors.orange : null)
                            ],
                          )
                        : Text(
                            order?.couponPrice == null
                                ? "-\$${0}"
                                : "${order?.couponPrice}",
                            style: TextStyle(
                                color: canCoupon ? Colors.orange : null)),
                  ),
                ),
              ],
            ),
          ),
          canCheckOut
              ? SizedBox.shrink()
              : Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Latest Logistics Status",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                      Column(
                        children: _logistics
                            .map((f) => Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin:
                                            EdgeInsets.only(right: 10, top: 3),
                                        decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle),
                                        height: 10,
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Text("${f.content}"),
                                          ),
                                          Text(
                                            "${f.time}",
                                            style: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 13),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      )
                    ],
                  ),
                ),
          widget.order.status == 'Pending'
              ? SizedBox.shrink()
              : Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Order Information",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        title: Text("Order Number"),
                        trailing: Text("${order?.orderNo ?? ""}"),
                      ),
                      ListTile(
                        onTap: () {},
                        title: Text("Order Time"),
                        trailing: Text("${order?.orderTime}"),
                      ),
                    ],
                  ),
                )
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                offset: Offset(0.2, 1.5),
                blurRadius: 4.8)
          ],
        ),
        child: SafeArea(
          child: canCheckOut
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: _addingToCart
                      ? CupertinoActivityIndicator()
                      : Row(
                          children: <Widget>[
                            pending ? SizedBox.shrink() : Text("Subtotal:"),
                            pending
                                ? InkWell(
                                    child: Container(
                                      child: Text(
                                        "Cancel Order",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: Color(0xff272626)),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Color(0xffffe707)
                                              .withOpacity(0.2),
                                          border: Border.all(
                                              color: Color(0xffffe707),
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      padding: EdgeInsets.all(7),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 6),
                                    ),
                                    onTap: _cancelOrder,
                                  )
                                : Text(
                                    "\$$total",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                            pending ? SizedBox.shrink() : Spacer(),
                            pending
                                ? Expanded(
                                    child: proceed,
                                  )
                                : proceed
                          ],
                        ),
                )
              : order?.isClosed == true
                  ? _deleting
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CupertinoActivityIndicator(),
                        )
                      : deleteBtn
                  : SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget get proceed => Container(
        height: 30,
        child: RaisedButton(
            color: color,
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Text(
              _order == null ? "Proceed to Checkout" : "Pay",
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            onPressed: nullAddressOnPending ? null : requestOrder),
      );

  void _deleteOrder() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(5),
            title: Text("Confirm To Delete?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Text(
                    "Confirm delete this order ?",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(6)),
                        elevation: 0.7,
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red),
                        ),
                      ),
                    )),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: RaisedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          _trueDelete();
                        },
                        color: color,
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        elevation: 0.7,
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    )),
                  ],
                )
              ],
            ),
          );
        });
  }

  void _trueDelete() {
    setState(() {
      _deleting = true;
    });
    this.ajax(
        url: "order/${order?.orderId}",
        method: "DELETE",
        auth: true,
        authKey: widget.user()?.token,
        server: true,
        onValue: (s, v) {
          Navigator.pop(context, s);
        },
        error: (s, v) => print(s),
        onEnd: () {
          setState(() {
            _deleting = false;
          });
        });
  }

  bool _deleting = false;

  Widget get deleteBtn => Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: RaisedButton(
            color: color,
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Text(
              "Delete Order",
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red),
            ),
            onPressed: _deleteOrder),
      );

  String get total => order?.realityPriceString ?? total2;

  String get total2 =>
      widget.list.fold<double>(0.0, (v, t) => v + t.total).toStringAsFixed(2);

  void showMd() async {
    //Timer(Duration(seconds: 8), ()=>this.canPop());
    await showGeneralDialog(
        transitionDuration: Duration(seconds: 1),
        barrierDismissible: false,
        context: context,
        barrierColor: Colors.black12,
        pageBuilder: (context, _, __) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            content: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(7)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Order _order;
  Order _order2;

  Order get order => _order ?? _order2;

  bool get nullAddressOnPending => _address == null && _order == null;

  void requestOrder() {
    if (nullAddressOnPending) return;

    if (_order != null) {
      goCheckOut(_order);
      return;
    }

    showMd();

    var map = {
      "deliveryAddressId": _address.addressId,
      "ids": widget.list.map((e) => e.id).toList()
    };

    var notNull = widget.payNowParams != null;

    var iterable = order != null && order?.couponId != null
        ? "toitableId=${Uri.encodeComponent(order?.couponId)}"
        : "";

    iterable = iterable.isNotEmpty ? (notNull ? "&" : "") + iterable : "";

    print(map);
    print(widget.payNowParams);

    this.ajax(
        url: "order/place?${notNull ? widget.payNowParams : ""}$iterable",
        method: "POST",
        server: true,
        auth: true,
        map: map,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          print(url);
          var map = json.decode(source);
          Navigator.pop(context);
          if (map != null && map['code'] == 1) {
            _order = Order.fromJson(map['data']);
            setState(() {});
            platform.invokeMethod('logInitiateCheckoutEvent', <Object, dynamic>{
              "contentData": "${_order.orderName}",
              "contentId": "${_order.orderId}",
              "contentType": 'order',
              "numItems": itemNum,
              "paymentInfoAvailable": true,
              "currency": "USD",
              "totalPrice": order.totalPrice
            });
            goCheckOut(_order);
          } else {
            platform.invokeMethod("toast", map['message']);
          }
        },
        error: (source, url) {
          Navigator.pop(context);
          print(source);
          platform.invokeMethod("toast", source);
        });
  }

  void goCheckOut(Order order) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        isDismissible: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
        builder: (context) {
          return PopPage(
            order: order,
            price: order.realityPay,
            addressEmail: _address.email,
            callback: widget.callback,
            addToCart: (String url, String title, bool isDpo) async {
              await Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => WebViewExample(
                            url: url,
                            title: title,
                            user: widget.user,
                            callback: widget.callback,
                            order: order,
                            isDpo: isDpo,
                          )));
              return Future.value();
            },
            // price: widget.order.totalPrice,
            //  order: widget.order,
            user: widget.user,
          );
        });
  }
}

class _DeleteOrder extends StatefulWidget {
  final Order order;
  final User Function() user;

  const _DeleteOrder({Key key, @required this.order, @required this.user})
      : super(key: key);

  @override
  __DeleteOrderState createState() => __DeleteOrderState();
}

class __DeleteOrderState extends State<_DeleteOrder> with SuperBase {
  List<String> get _list =>
      ["I don't want to buy it", "Wrong information", "Other"];

  String selected;
  bool _sending = false;

  void _cancelOrder() {
    setState(() {
      _sending = true;
    });
    this.ajax(
        url:
            "order/cancelOrder?orderId=${widget.order?.orderId}&reason=${Uri.encodeComponent(selected)}",
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        onValue: (s, v) {
          print(s);
          Navigator.pop(context, s);
        },
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100),
      padding: EdgeInsets.all(25),
      child: _sending
          ? Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(80.0),
                child: CircularProgressIndicator(),
              ))
            ])
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text("Cancel Order",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close, color: Colors.grey))
                  ],
                ),
                SizedBox(height: 30),
                Divider(),
                Column(
                  children: _list
                      .map((f) => ListTile(
                            onTap: () {
                              setState(() {
                                selected = f;
                              });
                            },
                            title: Text(f),
                            trailing: f == selected
                                ? Icon(
                                    Icons.check_circle,
                                    color: color,
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    height: 20,
                                    width: 20,
                                  ),
                          ))
                      .toList(),
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: _cancelOrder,
                    color: color,
                    elevation: 0.4,
                    child: Text("Confirm"),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ValidateBonus extends StatefulWidget {
  final Post post;
  final Cart product;
  final User Function() user;

  const _ValidateBonus(
      {Key key,
      @required this.post,
      @required this.product,
      @required this.user})
      : super(key: key);

  @override
  __ValidateBonusState createState() => __ValidateBonusState();
}

class __ValidateBonusState extends State<_ValidateBonus> with SuperBase {
  bool _validating = true;

  void validateBonus() {
    var post = widget.post;
    var map = {
      "product": widget.product.itemTitle,
      "post": post.id,
      "userInfo": post?.user?.id,
      "amount": widget.product.total,
      "sharer": widget.post.sharer,
      "percentage": 10,
    };
    this.ajax(
        url: "saveBonus",
        base2: true,
        server: true,
        method: "POST",
        data: FormData.fromMap(map),
        onValue: (source, url) {
          removeVisited(widget.post);
          setState(() {
            _validating = false;
          });
        },
        error: (s, v) => print('$s$v ssv'));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this.validateBonus());
  }

  Post get post => widget.post;

  Cart get product => widget.product;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.green.withOpacity(0.5),
                offset: Offset(0.2, 1.5),
                blurRadius: 4.8)
          ],
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              Expanded(
                  child: _validating
                      ? Row(
                          children: <Widget>[
                            CupertinoActivityIndicator(),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Valindating bonus ...."),
                            )
                          ],
                        )
                      : RichText(
                          text: TextSpan(
                              style: TextStyle(color: Colors.black87),
                              children: [
                              TextSpan(
                                  text:
                                      "${post.username} will receive bonus of"),
                              TextSpan(
                                  text:
                                      " ${product.bonusStr} (${product.percent}%)",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ])))
            ],
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image(
                image: CachedNetworkImageProvider(product.itemImg),
                height: 60,
                width: 60,
                frameBuilder: (context, child, frame, was) =>
                    frame == null ? CupertinoActivityIndicator() : child,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${product.itemTitle}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text("${post.user?.username}"),
                      SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Color(0xffffe707),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              '\$${product.bonusStr}',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Spacer(),
                          Text("${product.percent}%")
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PopPage extends StatefulWidget {
  final Future<void> Function(String authUrl, String title, bool isDpo)
      addToCart;
  final double price;
  final Order order;
  final void Function(User user) callback;
  final User Function() user;
  final String addressEmail;

  const PopPage(
      {Key key,
      @required this.addToCart,
      @required this.price,
      @required this.order,
      @required this.user,
      @required this.callback,
      this.addressEmail})
      : super(key: key);

  @override
  _PopPageState createState() => _PopPageState();
}

class _PopPageState extends State<PopPage> with SuperBase {
  int _selected = 0;

  bool _sending = false;

  Flutterwave _flutterwave;

  TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = new TextEditingController(
        text: widget.addressEmail ?? widget.user()?.email);
  }

  void verifyPay() async {
    this.ajax(
        url: "flutterwave/verifyPay?orderId=${widget.order.orderId}",
        method: "POST",
        server: true,
        onValue: (source, url) {
          print(source);
          var x = json.decode(source);
          if (x['code'] == 1) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => PaymentSuccess(
                        user: widget.user,
                        order: widget.order,
                        callback: widget.callback)));
          } else {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => PayFailure()));
          }
        },
        error: (s, v) {
          print(s);
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => PayFailure()));
        });
  }

  void flutterWave2() async {
    setState(() {
      _sending = true;
    });
    this.ajax(
        url:
            "order/currencyConversion?currency=zmk&price=${widget.order.realityPay}",
        authKey: widget.user()?.token,
        auth: true,
        onValue: (source, url) {
          var data = json.decode(source);
          if (data['code'] == 1) {
            double price = data['data'];
            this.ajax(
                url: "flutterwave/queryParams?userId=${widget.user()?.id}",
                server: true,
                onValue: (source, url) async {
                  print(source);
                  var key = json.decode(source)['data']['public_key'];
                  await widget.addToCart(
                      "https://app.afrieshop.com/afrishop_flutterwave/flutterwave_test.html?email=${_controller.text}&amount=$price&publicKey=$key&orderId=${widget.order.orderId}",
                      "Flutterwave payment",
                      false);
                  verifyPay();
                },
                error: (s, v) {
                  print(s); //flutterWave();
                  setState(() {
                    _sending = false;
                  });
                },
                onEnd: () {});
          } else {
            platform.invokeMethod("toast", data['message']);
            setState(() {
              _sending = false;
            });
          }
        },
        error: (s, v) {
          setState(() {
            _sending = false;
          });
        });
  }

  void flutterWave() async {
    _flutterwave = await Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => FlutterForm(
                  email: _controller.text,
                  flutterwave: _flutterwave,
                  user: widget.user,
                  price: widget.order.realityPay,
                )));
    if (_flutterwave == null) {
      platform.invokeMethod("toast", "Required information missing");
      return;
    }

    setState(() {
      _sending = true;
    });

    this.ajax(
        url: "flutterwave/pay?orderId=${widget.order.orderId}",
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        method: "POST",
        map: {
          "amount": widget.order.realityPay,
          "card": _flutterwave.card,
          "country": _flutterwave.country,
          "cvv": _flutterwave.cvv,
          "email": _flutterwave.email,
          "firstname": _flutterwave.firstName,
          "lastname": _flutterwave.lastName,
          "month": _flutterwave.month,
          "phone": "${_flutterwave.phone}",
          "ref": widget.order?.orderId,
          "year": _flutterwave.year
        },
        onValue: (source, url) async {
          var map = json.decode(source);
          print(source);
          if (map != null &&
              map['data'] != null &&
              map['data']['data'] != null &&
              map['data']['data']['authurl'] != null) {
            var uri = map['data']['data']['authurl'];
            await widget.addToCart(uri, "Flutterwave payment", false);
            verifyPay();
          } else {
            platform.invokeMethod("toast", map['message']);
          }
        },
        error: (s, v) {
          platform.invokeMethod("toast", s);
        },
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  void payPal() {
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "paypal/pay?orderId=${widget.order.orderId}",
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        method: "POST",
        map: {
          "cardno": "345674323567534565",
          "expiryyear": "2020",
          "expirymonth": "08",
        },
        onValue: (source, url) {
          var map = json.decode(source);
          print(source);
          widget.addToCart(map['data']['paypalUrl'], "Paypal payment", false);
        },
        error: (s, v) {
          platform.invokeMethod("toast", s);
        },
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  void validateBonusMarketing() {
    var map = {
      "product": "Bonus",
      "userInfo": widget.user()?.id,
      "amount": widget.order.realityPay,
      "percentage": 10,
    };
    this.ajax(
        url: "saveNetworkMarketing",
        base2: true,
        server: true,
        method: "POST",
        data: FormData.fromMap(map),
        onValue: (source, url) {},
        error: (s, v) => print('$s$v ssv'));
  }

  void dpoPayment() {
    //validateBonusMarketing(); is put on payment success
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "dpo/payment?orderId=${widget.order.orderId}",
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        method: "POST",
        map: {},
        onValue: (source, url) async {
          //platform.invokeMethod("toast", source);
          //platform.invokeMethod("toast", source);
          print(source);
          var map = json.decode(source);
          var dt = map['data'];
          if (dt != null)
            await widget.addToCart(dt['payUrl'], "DPO payment", true);
          //print("To return $source");
        },
        error: (s, v) {
          print(s);
          platform.invokeMethod("toast", s);
        },
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  void stripePay() {
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "order/stripe",
        auth: true,
        authKey: widget.user()?.token,
        server: true,
        onValue: (source, url) {
          print(source);
        },
        error: (s, v) {
          platform.invokeMethod("toast", s);
        },
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.infinity,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100),
      padding: EdgeInsets.all(7),
      child: SingleChildScrollView(
        child: _sending
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 88.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "Payment method",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300))),
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Subtotal : \$${widget.price}",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(8),
                    onTap: () {
                      setState(() {
                        _selected = 0;
                      });
                    },
                    leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/dpo.jpg"),
                    ),
                    trailing: _selected == 0
                        ? Icon(
                            Icons.check_circle,
                            color: color,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            height: 20,
                            width: 20,
                          ),
                    title: Text("DPO"),
                    subtitle: Text("All card types"),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(8),
                    onTap: () {
                      setState(() {
                        _selected = 1;
                      });
                    },
                    trailing: _selected == 1
                        ? Icon(
                            Icons.check_circle,
                            color: color,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            height: 20,
                            width: 20,
                          ),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/flutterwave.png"),
                    ),
                    title: Text("Flutterwave"),
                    subtitle: Text(
                      "Local cards and mobile money payments",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _selected == 1
                      ? Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "Statement Receiver's Email",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "*",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Container(
                                height: 37,
                                child: TextFormField(
                                  controller: _controller,
                                  onChanged: (s) {
                                    setState(() {});
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      filled: true,
                                      hintText: "Email",
                                      contentPadding: EdgeInsets.only(left: 7),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                )),
                          ],
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: RaisedButton(
                          onPressed: _selected == 1 &&
                                  _controller.text.isNotEmpty &&
                                  emailExp.hasMatch(_controller.text)
                              ? flutterWave
                              : _selected == 0
                                  ? dpoPayment
                                  : null,
                          color: color,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            "Pay",
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),
                          )))
                ],
              ),
      ),
    );
  }
}
