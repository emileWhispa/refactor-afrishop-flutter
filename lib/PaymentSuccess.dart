import 'package:afri_shop/Json/Post.dart';
import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/pending_cart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Cart.dart';
import 'Json/User.dart';
import 'Json/order.dart';
import 'SuperBase.dart';

class PaymentSuccess extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;
  final Order order;

  const PaymentSuccess({Key key, @required this.user, @required this.order,@required this.callback})
      : super(key: key);

  @override
  _PaymentSuccessState createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> with SuperBase {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_)async{
      await this.checkVisitedLink();
      await this.checkVisitedLinkProduct();
      //this.validateBonusMarketing();
    });
  }
  List<Cart> products = [];
  List<Product> _visitedProducts = [];
  List<Post> posts = [];


  void validateBonusMarketing() {
    var map = {
      "product": "Bonus",
      "token":widget.user()?.token,
      "userInfo": widget.user()?.id,
      "orderId": widget.order.orderId,
      "amount": widget.order.subTotalPriceFromCoupon,
      "post": posts.isNotEmpty ? posts.first.id : null,
      "productSharer": _visitedProducts.isNotEmpty ? _visitedProducts.first.fromCode : null,
      "percentage": 10,
    };
    this.ajax(
        url: "discover/bonus/saveNetworkMarketing",
        authKey: widget.user()?.token,
        server: true,
        method: "POST",
        data: FormData.fromMap(map),
        onValue: (source, url) {
          if( posts.isNotEmpty)
            removeVisited(posts.first);
          if(_visitedProducts.isNotEmpty)
            removeVisitedProduct(_visitedProducts.first);
        },
        error: (s, v) => print('$s$v ssv'));
  }

  Future<void> checkVisitedLink() async {
    var list = await getVisitedPost();
    var newList = list
        .where((f) => f.products.any((f) {
      print("fav : ${f.product.itemId} => ${f.product.title}");
      return widget.order.itemList.any((x) {
        print("order : ${x.shopId} => ${x.itemTitle}");
        return x.shopId == f.product.itemId;
      });
    }))
        .toList();
    print(list.length);
    var newList0 = widget.order.itemList
        .where((fx) => list.any(
            (f) => f.products.any((x) => x.product?.itemId == fx.shopId)))
        .toList();
    if (newList.isNotEmpty && newList0.isNotEmpty) {
      products = newList0.toList();
      posts = newList.toList();
      setState(() {
      });
//      showDialog(
//          context: context,
//          builder: (context) {
//            return AlertDialog(
//              content: Container(
//                height: MediaQuery.of(context).size.height - 300,
//                child: ListView(
//                  children: <Widget>[
//                    Padding(
//                      padding: const EdgeInsets.symmetric(vertical: 6.0),
//                      child: Text(
//                        "Bonus Alert",
//                        style: Theme.of(context).textTheme.headline.copyWith(
//                            color: Colors.green, fontWeight: FontWeight.bold),
//                      ),
//                    ),
//                    Column(
//                      mainAxisSize: MainAxisSize.min,
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: List.generate(products.length, (index) {
//                        var post = posts.length > index ? posts[index] : posts.isNotEmpty ? posts.first : null;
//                        var product = products[index];
//
//                        if (post == null) return SizedBox.shrink();
//
//                        return _ValidateBonus(
//                            post: post, product: product, user: widget.user);
//                      }),
//                    ),
//                  ],
//                ),
//              ),
//              contentPadding: EdgeInsets.all(7),
//            );
//          });
    }
    return Future.value();
  }

  Future<void> checkVisitedLinkProduct() async {
    var list = await getVisitedProducts();
    var newList = list
        .where((f) => widget.order.itemList.any((x)=>x.shopId == f.itemId)).toList();
    if (newList.isNotEmpty) {
      _visitedProducts = newList.toList();
      setState(() {
      });
    }
    return Future.value();
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
          "Pay",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 250,
                  color: color,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image(image: AssetImage("assets/pay.png"), height: 150),
                        SizedBox(height: 25),
                        Text(
                          "Payment success",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 25),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: RaisedButton(
                                onPressed: () {
                                  widget.user()?.requestHomePage = true;
                                  if( widget.user() != null ) widget.callback(widget.user());
                                  Navigator.pop(context);
                                  //Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>OrderTimeout()));
                                },
                                color: Colors.white,
                                padding: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(6)),
                                elevation: 0.7,
                                child: Text(
                                  "Back To Home",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                            )),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: RaisedButton(
                                onPressed: () {
                                  widget.order.orderStatus = 20;
                                  Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => PendingCart(user: widget.user,callback: widget.callback)));
                                },
                                color: color,
                                padding: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                elevation: 0.0,
                                child: Text(
                                  "View Order",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                            )),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 100,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9.3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.4, 3.2),
                        blurRadius: 3.4)
                  ]),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.black54, Colors.black87],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight)),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "New registered users",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "Available for over \$500",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400),
                        ),
                        Spacer(),
                        Text(
                          "Valid until during 20-02-2020 till 20-02-2021",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  )),
                  Container(
                    decoration: BoxDecoration(color: color),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("\$20",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text("COUPON",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: widget.order.itemList
                  .map((f) => Container(
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9.3),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0.4, 3.2),
                                  blurRadius: 3.4)
                            ]),
                        child: InkWell(
                          child: Row(
                            children: <Widget>[
                              FadeInImage(
                                height: 90,
                                width: 90,
                                image: CachedNetworkImageProvider(f.itemImg),
                                fit: BoxFit.cover,
                                placeholder: defLoader,
                              ),
                              Expanded(
                                  child: Container(
                                height: 90,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                        child: Text(
                                      "${f.itemTitle}",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Color(0xffffe707),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Text(
                                            '\$${f.itemPrice}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(child: SizedBox.shrink()),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            GestureDetector(
                                              child: new Icon(
                                                  Icons.remove_circle_outline),
                                              onTap: () => setState(() {}),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: Text(
                                                '${f.itemNum}',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            GestureDetector(
                                              child: new Icon(
                                                  Icons.add_circle_outline),
                                              onTap: () {
                                                setState(() {});
                                              },
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            )
          ],
        ),
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
