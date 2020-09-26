import 'package:afri_shop/Json/Review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../SuperBase.dart';
import '../Json/User.dart';
import '../Json/Product.dart';
import 'package:afri_shop/old_authorization.dart';

class ReviewItem extends StatefulWidget {
  final Review review;
  final User Function() user;
  final Product product;
  final void Function(User user) callback;

  const ReviewItem({Key key, @required this.review,@required this.user,@required this.product,@required this.callback}) : super(key: key);

  @override
  _ReviewItemState createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> with SuperBase {

  void giveLike(){
    this.ajax(url: "shopify/giveLike/${widget.review.id}/${widget.user()?.id}/${widget.product?.itemId}",server: true,onValue: (s,v){
      print(s);
    },error: (s,v)=>print(s));
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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundImage: CachedNetworkImageProvider(widget.review?.avatar??""),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${widget.review.username}",
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  "${widget.review.time}",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 15),
                Text("${widget.review.itemReview}"),
                SizedBox(height: 15),
                Row(
                  children: List.generate(
                      8,
                      (index) => index == 5
                          ? Spacer()
                          : index == 6
                              ? InkWell(
                        onTap: ()async{
                          await waitUserCheck();
                          if (widget.user() == null) return;
                          widget.review.liked = !widget.review.liked;
                          if( widget.review.liked ){
                            setState(() {
                              ++widget.review.likeNum;
                            });
                            platform.invokeMethod("toast","Comment liked");
                          }else{

                            setState(() {
                              --widget.review.likeNum;
                            });
                            platform.invokeMethod("toast","Comment disliked");
                          }
                          giveLike();
                        },
                                child: Icon(
                                    widget.review.liked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 18,
                                    color:
                                        widget.review.liked ? color : Colors.grey,
                                  ),
                              )
                              : index == 7
                                  ? Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text("${widget.review.likeNum}",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.grey)),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(right: 7),
                                      child: Image.asset(
                                        'assets/${(index + 1) <= widget.review.average ? 'star' : 'star_border'}.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                    )).toList(),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
