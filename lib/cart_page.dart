  import 'dart:convert';

import 'new_account_screen.dart';
import 'package:afri_shop/description.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:afri_shop/Json/Product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'Json/Address.dart';
import 'Json/order.dart';
import 'old_authorization.dart';
import 'Json/Cart.dart';
import 'Json/User.dart';
import 'SuperBase.dart';
import 'complete_order.dart';

class CartScreen extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;
  final void Function() goToHome;
  final Product product;

  const CartScreen(
      {Key key,
      @required this.user,
      @required this.callback,
      this.product,
      this.goToHome})
      : super(key: key);

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> with SuperBase {
  List<Cart> _list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
      if (widget.product != null) {
        showMd();
      }
    });
  }

  void refresh() {
    _control.currentState?.show(atTop: true);
  }

  void showMd() async {
    //Timer(Duration(seconds: 8), ()=>this.canPop());
    _pop = true;
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
    _pop = false;
  }

  var _control = new GlobalKey<RefreshIndicatorState>();
  bool _select = false;
  bool _selectingAll = false;

  var _url = "cart";
  bool _pop = false;

  void canPop() {
    if (_pop) {
      Navigator.pop(context);
      _pop = false;
    }
  }

  var _x = 0;

  Future<void> loadItems({bool server: true}) async {
    await open();
    setState(() {});
    print(widget.user()?.token);
    return this.ajax(
        url: _url,
        server: server,
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) async {
//          print(url);
//          print(source);
          var map = json.decode(source);
          Iterable _map = map['data'];
          if (_map != null)
            setState(() {
              _list = _map.map((f){
                var cart = Cart.fromJson(f);
                cart.checkFlag = _list.any((element) => element.checkFlag == 1 && element.id == cart.id) ? 1 : 0;
                return cart;
              }).toList();
            });
          if (widget.user() != null) {
            widget.user()?.cartCount = _list.fold(0, (previousValue, element) => previousValue+element.itemNum);
          }
          if (widget.product != null) {
            var cart = _list
                .where((f) => f.itemTitle == widget.product.title)
                .toList();
            var d = cart.isNotEmpty ? cart.first : null;
            if (d != null && _x == 0) {
              _x++;
              await checkFlag(d, x: 1);
              canPop();
            }
          }
          if (server) {
            this.saveVal(url, source);
          }
        });
  }

  Database db;

  Future<void> open() async {
    db = await getDatabase();
    return Future.value();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    db?.close();
  }

  void deleteModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext build) {
          var list = _list.where((f) => f.selected).toList();
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Confirm to delete ${list.length} items(s) from cart ?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  list.map((f) => f.itemTitle).join(", "),
                  maxLines:
                      MediaQuery.of(build).orientation == Orientation.portrait
                          ? 20
                          : 10,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: FlatButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(build).pop()),
                    ),
                    RaisedButton(
                        child: Text('Delete'),
                        color: Colors.red,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(build).pop();
                          //this.deleter(list);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  bool _addingToCart = false;

  void populate(User user) {
    this.loadItems();
  }

  void deleter(List<Product> list) async {
    for (int i = 0; i < list.length; i++) {
      await list[i].deleteItem(db);
    }
    setState(() {
      _list.removeWhere((f) => f.selected);
      _select = false;
    });
  }

  void _updateQuantity(Cart cart) {
    setState(() {
      //cart.updating = true;
    });
    this.ajax(
        url: "cart/num/${cart.id}/${cart.itemNum}",
        method: "PUT",
        server: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          //platform.invokeMethod("toast", '${map['message']}');
          loadItems(server: true);
        },
        error: (source, url) {
          platform.invokeMethod("toast", source);
        },
        onEnd: () {
          setState(() {
            cart.updating = false;
          });
        });
  }

  var _deleting = false;

  void _selectAllFunc() async {
    setState(() {
      _selectingAll = true;
    });

    var f = _selectAll ? 0 : 1;

    setState(() {
      _list.forEach((element) {
        element.checkFlag = f;
      });
      _selectingAll = false;
    });
  }

  void _delete() async {
    var list = _list.where((f) => f.selected).toList();
    var pr = jsonEncode(list.map((f) => f.id).toList());
    setState(() {
      _deleting = true;
    });
    print(pr);
    this.ajax(
        url: "cart/delete",
        method: "DELETE",
        auth: true,
        server: true,
        authKey: widget.user()?.token,
        jsonData: pr,
        onValue: (source, url) {
          var map = json.decode(source);
          platform.invokeMethod("toast", '${map['message']}');
          if (map['code'] == 1) {
            refresh();
          }
        },
        error: (s,v){
          print(s);
          platform.invokeMethod("toast", s);
        },
        onEnd: () {
          setState(() {
            _select = false;
            _deleting = false;
          });
        });
  }

  Future<void> checkFlag(Cart cart, {int x}) {
    setState(() {
      //cart.updating = true;
    });
    x = x ?? (cart.selected ? 0 : 1);
    return this.ajax(
        url: "item/state/${cart.id}/$x",
        authKey: widget.user()?.token,
        method: "PUT",
        server: true,
        auth: true,
        onValue: (source, url) async {
          print(source);
          var map = jsonDecode(source);
          if (map['code'] == 1) {
            setState(() {
              cart.checkFlag = x;
            });
            (await this.prefs).remove(this.url(_url));
          }
        },
        error: (source, url) {
          //platform.invokeMethod("toast", source);
        },
        onEnd: () {
          setState(() {
            cart.updating = false;
          });
        });
  }

  void _deletePop() async {
    if (!_list.any((f) => f.selected)) {
      platform.invokeMethod("toast", "Please choose the goods");
      return;
    }
    showCupertinoModalPopup(
        context: context,
        builder: (context) => new CupertinoAlertDialog(
              title: new Text("Confirm To Delete"),
              content: new Text("Confirm delete these goods ?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                    _delete();
                  },
                  child: Text("Confirm"),
                )
              ],
            ));
  }

  void _goPro(Cart cart) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => Description(
                product: cart.product,
                user: widget.user,
                callback: widget.callback)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.user() == null
        ? AccountScreen(user: widget.user, callback: widget.callback)
        : Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: AppBar(
              backgroundColor: color,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.maybePop(context);
                      })
                  : null,
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: Image.asset(
                      "assets/afrishop_logo@3x.png",
                      width: 70,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Cart",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Spacer(),
                ],
              ),
              centerTitle: true,
              elevation: 0.6,
              actions: <Widget>[
                !_select
                    ? FlatButton(
                        onPressed: () {
                          setState(() {
                            _select = !_select;
                          });
                        },
                        child: Text("Management"))
                    : FlatButton(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 22.0),
                          child: Text("Complete"),
                        ),
                        onPressed: () {
                          setState(() {
                            _select = false;
                          });
                        })
              ],
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                    child: RefreshIndicator(
                        key: _control,
                        child: _list.isEmpty
                            ? ListView(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(28.0),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(height: 30),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 50.0),
                                            child: Image(
                                              image: AssetImage(
                                                  "assets/empty.png"),
                                              height: 150,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        Text("Your Cart Is Empty"),
                                        SizedBox(height: 30),
                                        Container(
                                          width: double.infinity,
                                          height: 43,
                                          child: CupertinoButton(
                                              borderRadius: BorderRadius.zero,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Text(
                                                "Go To Add Your Goods",
                                                style: TextStyle(
                                                    color: Color(0xff4D4D4D),
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              onPressed: () {
                                                Navigator.popUntil(
                                                    context, (f) => f.isFirst);
                                                if (widget.goToHome != null) {
                                                  widget.goToHome();
                                                }
                                              },
                                              color: color),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Scrollbar(
                                child: ListView.builder(
                                itemCount: _list.length,
                                itemBuilder: (context, index) {
                                  var _item = _list[index];
                                  //print("${_item.itemId} - ${_item.itemTitle}");
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 5, right: 6, left: 6),
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        _item.updating
                                            ? Container(
                                                padding:
                                                    EdgeInsets.only(right: 3),
                                                child:
                                                    CupertinoActivityIndicator(),
                                                margin:
                                                    EdgeInsets.only(right: 10))
                                            : InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _item.checkFlag = _item.checkFlag == 1 ? 0 : 1;
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  decoration: BoxDecoration(
                                                      border: _item.selected
                                                          ? null
                                                          : Border.all(
                                                              color:
                                                                  Colors.grey),
                                                      shape: BoxShape.circle,
                                                      color: _item.selected
                                                          ? color
                                                          : Colors.white),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        _item.selected
                                                            ? 2.0
                                                            : 11),
                                                    child: _item.selected
                                                        ? Icon(
                                                            Icons.check,
                                                            size: 20.0,
                                                            color: Colors.black,
                                                          )
                                                        : SizedBox.shrink(),
                                                  ),
                                                ),
                                              ),
                                        InkWell(
                                          onTap: () => _goPro(_item),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: FadeInImage(
                                              height: 75,
                                              width: 95,
                                              image: CachedNetworkImageProvider(
                                                  _item.itemImg ?? ""),
                                              fit: BoxFit.cover,
                                              placeholder: defLoader,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () => _goPro(_item),
                                          child: Container(
                                            height: 90,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 6),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  _item.itemTitle ?? "",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12.6,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets.only(right:2.0),
                                                        child: Text(
                                                          "${_item.shopName}",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey.shade400),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text("${_item.itemSku}",
                                                            maxLines:1,
                                                            overflow:TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey
                                                                    .shade400)),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4,
                                                              horizontal: 12),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xffffe707),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Text(
                                                        '\$${_item.itemPrice}',
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child:
                                                            SizedBox.shrink()),
                                                    Container(
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black12,
                                                              width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3)),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            child: Container(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          3),
                                                              child: new Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            onTap: () =>
                                                                setState(() {
                                                              if (_item
                                                                      .itemNum >
                                                                  1) {
                                                                _item.itemNum--;
                                                                this._updateQuantity(
                                                                    _item);
                                                              }
                                                            }),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            child: Text(
                                                              '${_item.itemNum}',
                                                              style:
                                                                  TextStyle(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            child: Container(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          3),
                                                              child: new Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                _item.itemNum++;
                                                                this._updateQuantity(
                                                                    _item);
                                                              });
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ))
                                      ],
                                    ),
                                  );
                                },
                              )),
                        onRefresh: loadItems)),
                _list.isEmpty
                    ? SizedBox.shrink()
                    : Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _select
                              ? Row(
                                  children: <Widget>[
                                    _selectingAll
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: CupertinoActivityIndicator(),
                                          )
                                        : InkWell(
                                            onTap: _selectAllFunc,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              decoration: BoxDecoration(
                                                  border: _selectAll
                                                      ? null
                                                      : Border.all(
                                                          color: Colors.grey),
                                                  shape: BoxShape.circle,
                                                  color: _selectAll
                                                      ? color
                                                      : Colors.white),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    _selectAll ? 2.0 : 11),
                                                child: _selectAll
                                                    ? Icon(
                                                        Icons.check,
                                                        size: 20.0,
                                                        color: Colors.black,
                                                      )
                                                    : SizedBox.shrink(),
                                              ),
                                            ),
                                          ),
                                    Text("Select All"),
                                    Spacer(),
                                    Container(
                                      height: 30,
                                      child: RaisedButton(
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero),
                                        onPressed:
                                            _deleting ? null : _deletePop,
                                        child: _deleting
                                            ? loadBox()
                                            : Text("delete"),
                                        color: color,
                                      ),
                                    )
                                  ],
                                )
                              : Row(
                                  children: <Widget>[
                                    Text(
                                      "Total: \$${_list.where((f) => f.selected).fold(0.0, (v, e) => v + e.total).toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(child: SizedBox.shrink()),
                                    _addingToCart
                                        ? CircularProgressIndicator()
                                        : Container(
                                            height: 30,
                                            child: RaisedButton(
                                                color: color,
                                                elevation: 0.0,
                                                textColor: Color(0xff4D4D4D),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero),
                                                child: Text(
                                                  "Complete your order",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                                onPressed: _complete),
                                          )
                                  ],
                                ),
                        ),
                      ),
              ],
            ));
  }

  Address _address;
  bool _selected = false;

  void _complete() async {
    if (!_list.any((f) => f.selected)) {
      platform.invokeMethod("toast", "Select goods");
      return;
    }

    var _user = widget.user();
    if (_user == null) {
      _user = await Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) => Authorization()));
      if (widget.callback != null && _user != null) widget.callback(_user);
      setState(() {});
    }
    if (_user != null) {
      getOrder(_user);
      _selected = false;
    }
  }

  void getOrder(User _user) async {
    _selected = true;
    showMd();
    this.ajax(
        url: "order/settle",
        method: "POST",
        jsonData: jsonEncode(_list.where((element) => element.selected).map((e) => e.id).toList()),
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) async {
          this.canPop();
          var map = json.decode(source);
          if (map != null && map['code'] == 1) {
            var _order = Order.fromJson(map['data']);
            complete(order: _order);
          } else {
            platform.invokeMethod("toast", map['message']);
          }
        },
        error: (source, url) {
          this.canPop();
          platform.invokeMethod("toast", source);
        });
  }

  void complete({Order order}) async {
    var x = CupertinoPageRoute(
        builder: (context) => CompleteOrder(
              list: order?.itemList ?? [],
              user: widget.user,
              callback: widget.callback,
              order: order,
            ));
    await Navigator.of(context).push(x);
    _control.currentState?.show(atTop: true);
  }

  bool get _selectAll => !_list.any((f) => !f.selected);
}

class _CompleteOrder extends StatefulWidget {
  final User Function() user;
  final List<Cart> cartList;

  const _CompleteOrder({Key key, @required this.user, @required this.cartList})
      : super(key: key);

  @override
  __CompleteOrderState createState() => __CompleteOrderState();
}

class __CompleteOrderState extends State<_CompleteOrder> with SuperBase {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this._complete());
  }

  bool _loading = false;

  void _complete() async {
    setState(() {
      _loading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(5), topLeft: Radius.circular(5))),
      child: !_loading
          ? Center(
              child: Text("No address selected"),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
