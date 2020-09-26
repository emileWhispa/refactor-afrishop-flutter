import 'package:afri_shop/review_form.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Cart.dart';
import 'Json/User.dart';
import 'Json/order.dart';
import 'SuperBase.dart';
import 'ReviewScreen.dart';

class ReviewList extends StatefulWidget {
  final Order order;
  final User Function() user;
  final void Function(User user) callback;

  const ReviewList(
      {Key key,
      @required this.user,
      @required this.callback,
      @required this.order})
      : super(key: key);

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> with SuperBase {
  List<Cart> get _list =>
      widget.order.itemList.where((element) => !element.commented).toList();

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
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: _list.length,
          itemBuilder: (context, index) {
            var pro = _list[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                onTap: () async {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ReviewScreen(
                                callback: widget.callback,
                                list: [],
                                user: widget.user,
                                product: pro.product,
                                order: widget.order,
                              )));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image(
                        image: CachedNetworkImageProvider(pro.itemImg),
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
                                      "${pro.itemTitle}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text("x${pro.itemNum}")
                                ],
                              ),
                              SizedBox(height: 11),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Text("${pro.itemSku}")),
                              SizedBox(height: 11),
                              Row(
                                children: <Widget>[
                                  Spacer(),
                                  Container(
                                    height: 30,
                                    child: RaisedButton(
                                      onPressed: () async {
                                        var dx = await Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    ReviewForm(
                                                        order: widget.order,
                                                        user: widget.user,
                                                        callback:
                                                            widget.callback,
                                                        cart: pro)));
                                        if (dx != null) {
                                          setState(() {
                                            pro.commented = true;
                                          });
                                        }
                                      },
                                      color: color,
                                      elevation: 0.0,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Review',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
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
            );
          }),
    );
  }
}
