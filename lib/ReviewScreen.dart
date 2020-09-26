import 'dart:convert';

import 'package:afri_shop/Partial/ReviewItem.dart';
import 'package:flutter/material.dart';

import 'Json/Product.dart';
import 'Json/Review.dart';
import 'Json/User.dart';
import 'Json/order.dart';
import 'SuperBase.dart';

class ReviewScreen extends StatefulWidget {
  final List<Review> list;
  final Product product;
  final User Function() user;
  final Order order;
  final void Function(User user) callback;

  const ReviewScreen({Key key, @required this.list,@required this.product,@required this.user, this.order,@required this.callback}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with SuperBase {

  List<Review> _list = [];


  var _refreshKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _refreshKey.currentState?.show(atTop: true);
    });
  }

  Future<void> loadComments(){
    return this.ajax(url: "shopify/querycomments?itemId=${widget.product?.itemId}&pageNum=0&pageSize=10${widget.user() != null ? "&userId=${widget.user()?.id}":""}",
    auth: true,
    authKey: widget.user()?.token,
    error: (s,v)=>print(s),
    onValue: (source,url){
      print(source);
      var map = json.decode(source);
      Iterable iterable = map['data']['content'];
      print(iterable);
      setState(() {
        _list = iterable.map((json)=>Review.fromJson(json)).toList();
      });
    });
  }


  int _index = 0;
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
        title: Text("Reviews"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: (){
                    setState(() {
                      _index = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _index == 0 ? color : Colors.transparent,
                            width: 2.5
                        )
                      )
                    ),
                    child: Text("All",style: TextStyle(fontWeight: _index == 0 ? FontWeight.bold : null),),
                  ),
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      _index = 1;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _index == 1 ? color : Colors.transparent,
                          width: 2.5
                        )
                      )
                    ),
                    child: Text("Latest",style: TextStyle(fontWeight: _index == 1 ? FontWeight.bold : null),),
                  ),
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      _index = 2;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _index == 2 ? color : Colors.transparent,
                          width: 2.5
                        )
                      )
                    ),
                    child: Text("With Content(0)",style: TextStyle(fontWeight: _index == 2 ? FontWeight.bold : null),),
                  ),
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      _index = 3;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _index == 3 ? color : Colors.transparent,
                          width: 2.5
                        )
                      )
                    ),
                    child: Text("With Photos(0)",style: TextStyle(fontWeight: _index == 3 ? FontWeight.bold : null),),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshKey,
              onRefresh: loadComments,
              child: Scrollbar(
                  child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        return ReviewItem(review: _list[index],user: widget.user,product: widget.product,callback: widget.callback,);
                      })),
            ),
          ),
        ],
      ),
    );
  }
}
