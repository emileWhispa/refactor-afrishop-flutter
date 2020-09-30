import 'dart:convert';

import 'package:afri_shop/ReviewScreen.dart';
import 'package:afri_shop/complete_order.dart';
import 'package:afri_shop/to_be_reviewed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:afri_shop/pending_payment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'Json/order.dart';
import 'SuperBase.dart';
import 'webview_example.dart';

class PendingCart extends StatefulWidget {
  final User Function() user;
  final int active;
  final void Function(User user) callback;

  const PendingCart(
      {Key key, @required this.user, this.active: 0, @required this.callback})
      : super(key: key);

  @override
  _PendingCartState createState() => _PendingCartState();
}

class _PendingCartState extends State<PendingCart> with SuperBase {
  List<Order> _list = [];
  List<Order> _deleted = [];
  List<Order> _unpaid = [];
  List<Order> _paid = [];
  List<Order> _shipped = [];
  List<Order> _successfully = [];
  List<Order> _closed = [];

  List<String> get _menus =>
      ["ALL", "Pending Payment", "Purchased", "Sending", "Finished"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _index = widget.active;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this._loadItems();
      _controller.jumpToPage(_index);
    });
  }

  var refreshKey = new GlobalKey<RefreshIndicatorState>();

  PageController _controller = new PageController();

  Future<void> _loadItems() {
    refreshKey.currentState?.show(atTop: true);
    return this.ajax(
        url: "order",
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
//          print(source);
//          print(widget.user()?.token);
          Iterable _map = json.decode(source)['data']['content'];
          setState(() {
            _list = _map.map((f) => Order.fromJson(f)).toList();
            _deleted = _list.where((f) => f.orderStatus == 0).toList();
            _unpaid = _list.where((f) => f.isPending).toList();
            _paid = _list.where((f) => f.orderStatus == 20).toList();
            _shipped = _list.where((f) => f.orderStatus == 40).toList();
            _successfully = _list.where((f) => f.isSuccess).toList();
            _closed = _list.where((f) => f.isClosed).toList();
          });
        },
        error: (s, v) => print(s),
        onEnd: () {});
  }

  int _index = 0;

  bool _delete = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.maybePop(context);
                })
            : null,
        title: Text("My orders", style: TextStyle(fontSize: 17)),
        centerTitle: true,
        actions: <Widget>[
//          IconButton(
//              icon: Icon(Icons.delete),
//              onPressed: () {
//                setState(() {
//                  _delete = !_delete;
//                });
//              })
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_menus.length, (index) {
                return InkWell(
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      decoration: _index == index
                          ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: color, width: 2.5)))
                          : null,
                      child: Text(
                        "${_menus[index]}",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: _index == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontFamily: 'SF UI Display'),
                      )),
                  onTap: () {
                    setState(() {
                      _index = index;
                      _controller.jumpToPage(index);
                    });
                  },
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _index = index;
                });
              },
              children: <Widget>[
                _BodyState(
                  user: widget.user,
                  delete: _delete,
                  list: _list,
                  loadItems: _loadItems,
                  callback: widget.callback,
                ),
                _BodyState(
                  user: widget.user,
                  delete: _delete,
                  list: _unpaid,
                  loadItems: _loadItems,
                  callback: widget.callback,
                ),
                _BodyState(
                  user: widget.user,
                  delete: _delete,
                  list: _paid,
                  loadItems: _loadItems,
                  callback: widget.callback,
                ),
                _BodyState(
                  user: widget.user,
                  delete: _delete,
                  list: _shipped,
                  loadItems: _loadItems,
                  callback: widget.callback,
                ),
                _BodyState(
                  user: widget.user,
                  delete: _delete,
                  list: _successfully,
                  loadItems: _loadItems,
                  callback: widget.callback,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyState extends StatefulWidget {
  final List<Order> list;
  final User Function() user;
  final void Function(User user) callback;
  final bool delete;
  final Future<void> Function() loadItems;

  const _BodyState(
      {Key key,
      this.list,
      @required this.user,
      @required this.delete,
      this.loadItems,
      @required this.callback})
      : super(key: key);

  @override
  __BodyStateState createState() => __BodyStateState();
}

class __BodyStateState extends State<_BodyState> with SuperBase {
  var refreshKey = new GlobalKey<RefreshIndicatorState>();

  List<Order> get _list => widget.list ?? [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshKey.currentState?.show(atTop: true);
    });
  }

  void goCheckOut(Order order) async {
    await showModalBottomSheet(
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
            callback: widget.callback,
            addToCart: (String url, String title,bool isDpo) async {
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
    refreshKey.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshIndicator(
      key: refreshKey,
      child: Scrollbar(
          child: _list.isEmpty
              ? ListView(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(top: 70),
                        child:
                            Image.asset("assets/no_record.png", height: 150)),
                    Center(
                        child: Text(
                      "No record",
                      style: TextStyle(fontSize: 22),
                    ))
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    var _pro = _list[index];
                    //print(_pro.orderId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "${_pro.date}",
                            style: TextStyle(
                                fontSize: 12.7, color: Color(0xff272626)),
                          ),
                        ),
                        Column(
                          children: _pro.itemList
                              .map((f) => Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200.withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                    margin:
                                        EdgeInsets.all(15).copyWith(top: 0,bottom: 15),
                                    child: InkWell(

                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    CompleteOrder(
                                                        callback: widget.callback,
                                                        user: widget.user,
                                                        list: _pro.itemList,
                                                        completedOrder: _pro,
                                                        order: _pro,
                                                        fromOrders: true)));
                                        refreshKey.currentState?.show();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            FadeInImage(
                                              height: 80,
                                              width: 80,
                                              image: CachedNetworkImageProvider(
                                                  '${f.itemImg}'),
                                              fit: BoxFit.cover,
                                              placeholder: defLoader,
                                            ),
                                            Expanded(
                                                child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                          '${f.itemTitle}',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        "x${f.itemNum}",
                                                        style: TextStyle(
                                                            color:
                                                                Color(0xff999999),
                                                            fontSize: 11),
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 9),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          '${f.shopName}',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.grey),
                                                        ),
                                                        Spacer(),
                                                        Text("${f.itemSku}",
                                                            maxLines: 1,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    Colors.grey))
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color: color,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(5)),
                                                        padding:
                                                            EdgeInsets.all(3),
                                                        child: Text(
                                                          "\$${f.total.toStringAsFixed(2)}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Text("${_pro.status}",
                                                          style: TextStyle(
                                                              color: Colors.red))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                              .toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Subtotal : \$${_pro.realityPriceString}",
                                style: TextStyle(
                                    color: Color(0xff999999), fontSize: 12),
                              ),
                              Spacer(),
                              _pro.isPending
                                  ? Container(
                                      height: 30,
                                      child: RaisedButton(
                                        onPressed: () => this.goCheckOut(_pro),
                                        child: Text("Pay"),
                                        color: color,
                                        elevation: 0.0,
                                      ),
                                    )
                                  :
                              _pro.isSuccessWithNonCommentItem
                                  ? Container(
                                height: 30,
                                child: RaisedButton(
                                    color : color,
                                    elevation: 0.0,
                                    onPressed: () async {
                                      await Navigator.push(context, CupertinoPageRoute(builder: (context)=>ReviewList(order:_pro,callback: widget.callback, user: widget.user)));
                                    setState(() {
                                      refreshKey.currentState?.show();
                                      widget.loadItems();
                                    });
                                      }, child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Text("Review",style: TextStyle(fontWeight: FontWeight.bold),),
                                )),
                              )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                        Container(color: Colors.grey.shade200, height: 11),
                      ],
                    );
                  })),
      onRefresh: widget.loadItems,
    );
  }

  void deleteOrder(Order order) {
    setState(() {
      order.deleting = true;
    });
    this.ajax(
        url: "order/${order.orderId}",
        method: "DELETE",
        auth: true,
        server: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          var map = json.decode(source);
          if (map['code'] == 1) {
            widget.loadItems();
          } else {
            platform.invokeMethod("toast", map['message']);
          }
        },
        error: (s, v) => platform.invokeMethod("toast", s),
        onEnd: () {
          setState(() {
            order.deleting = true;
          });
        });
  }
}

class SlideMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  SlideMenu({this.child, this.menuItems});

  @override
  _SlideMenuState createState() => new _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = new Tween(
            begin: const Offset(0.0, 0.0), end: const Offset(-0.2, 0.0))
        .animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    return new GestureDetector(
      onHorizontalDragUpdate: (data) {
        // we can access context.size here
        setState(() {
          _controller.value -= data.primaryDelta / context.size.width;
        });
      },
      onHorizontalDragEnd: (data) {
        if (data.primaryVelocity > 2500)
          _controller
              .animateTo(.0); //close menu on fast swipe in the right direction
        else if (_controller.value >= .5 ||
            data.primaryVelocity <
                -2500) // fully open if dragged a lot to left or on fast swipe to left
          _controller.animateTo(1.0);
        else // close if none of above
          _controller.animateTo(.0);
      },
      child: new Stack(
        children: <Widget>[
          new SlideTransition(position: animation, child: widget.child),
          new Positioned.fill(
            child: new LayoutBuilder(
              builder: (context, constraint) {
                return new AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return new Stack(
                      children: <Widget>[
                        new Positioned(
                          right: .0,
                          top: .0,
                          bottom: .0,
                          width: constraint.maxWidth * animation.value.dx * -1,
                          child: new Container(
                            color: Colors.black26,
                            child: new Row(
                              children: widget.menuItems.map((child) {
                                return new Expanded(
                                  child: child,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
