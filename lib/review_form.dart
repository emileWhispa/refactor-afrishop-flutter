import 'package:afri_shop/ContactUs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'Json/Cart.dart';
import 'Json/User.dart';
import 'Json/order.dart';
import 'SuperBase.dart';

class ReviewForm extends StatefulWidget {
  final Order order;
  final User Function() user;
  final void Function(User user) callback;
  final Cart cart;

  const ReviewForm(
      {Key key,
      @required this.order,
      @required this.user,
      @required this.callback,
      @required this.cart})
      : super(key: key);

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> with SuperBase {
  TextEditingController _controller = new TextEditingController();

  int _logistic;
  int _goods;
  int _price;
  int _service ;

  var _formKey = new GlobalKey<FormState>();

  bool _pop = false;

  void canPop() {
    if (_pop) {
      Navigator.pop(context);
      _pop = false;
    }
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


  void saveComments() {

    if( !(_formKey.currentState?.validate() ?? false) ) return;

    if( _logistic == null || _price == null || _goods == null || _service == null ){
      platform.invokeMethod("toast","Evaluate information missing");
      return;
    }

    reqFocus(context);

    var itemId = "${widget.cart?.product?.itemId}";
    print(itemId);
    var map = {
      "userId": widget.user()?.id,
      "orderId": widget.order?.orderId,
      "orderNo": widget.order?.orderNo,
      "itemId": itemId,
      "urls": itemId,
      "itemScore": _goods,
      "serviceScore": _service,
      "logisticsScore": _logistic,
      "priceScore": _price,
      "itemReview": _controller.text
    };

    print(jsonEncode(map));
    print(widget.user()?.token);

    showMd();

    this.ajax(
        url: "order/add/comment",
        method: "POST",
        map: map,
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          var dx = json.decode(source);
          canPop();
          if( dx['code'] == 1) {
            Navigator.pop(context,"data");
          }else{

          }
          platform.invokeMethod("toast", dx['message'] ?? "");
        },
        error: (s, v) {
          print(v);
          platform.invokeMethod("toast", s);
          canPop();
        },
        onEnd: () {

        });
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
                  Navigator.maybePop(context);
                })
            : null,
        centerTitle: true,
        title: Text("Review"),
      ),
      backgroundColor: Colors.grey.shade200,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 20),
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image(
                      image:
                          CachedNetworkImageProvider(widget.cart?.itemImg ?? ""),
                      height: 100,
                      width: 100,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${widget.cart?.itemTitle}",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text("x${widget.cart?.itemNum}")
                              ],
                            ),
                            SizedBox(height: 5),
                            Align(
                                alignment: Alignment.centerRight,
                                child: Text("${widget.cart?.itemSku}")),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 20),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 250.0, minHeight: 120),
                child: new Scrollbar(
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: TextFormField(
                        validator: (s) =>
                            s.trim().isEmpty ? "Field is required !!!" : null,
                        enabled: true,
                        maxLines: null,
                        textAlign: TextAlign.left,
                        controller: _controller,
                        decoration: InputDecoration.collapsed(
                            hintText: "Print your evaluate...",
                            hintStyle: TextStyle(color: Color(0xffCCCCCC)))),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 20),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Evaluate",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 20),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: List.generate(
                              6,
                              (index) => index == 0
                                  ? Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          "Logistics",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          _logistic = index;
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/${index <= (_logistic??0) ? 'star' : 'star_border'}.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                    )),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: List.generate(
                              6,
                              (index) => index == 0
                                  ? Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          "Goods",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          _goods = index;
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/${index <= (_goods??0) ? 'star' : 'star_border'}.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                    )),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: List.generate(
                              6,
                              (index) => index == 0
                                  ? Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          "Price",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          _price = index;
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/${index <= (_price??0) ? 'star' : 'star_border'}.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                    )),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: List.generate(
                              6,
                              (index) => index == 0
                                  ? Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          "Service",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          _service = index;
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/${index <= (_service??0) ? 'star' : 'star_border'}.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                    )),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 20),
              color: Colors.white,
              child: RaisedButton(
                onPressed: saveComments,
                color: color,
                elevation: 0.0,
                padding: EdgeInsets.all(10),
                child: Text(
                  "Submit",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 23),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
