import 'dart:convert';

import 'package:afri_shop/Partial/list_item.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/comment_section.dart';
import 'package:afri_shop/complain_screen.dart';
import 'package:afri_shop/description.dart';
import 'package:afri_shop/view_tag_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Post.dart';
import 'Json/User.dart';
import 'Json/comment.dart';
import 'Json/hashtag.dart';
import 'Partial/comment_item.dart';
import 'Partial/follow_button.dart';
import 'cart_page.dart';
import 'discover_profile.dart';

class DiscoverDescription extends StatefulWidget {
  final ImageProvider url;
  final Post post;
  final User Function() user;
  final void Function(User user) callback;
  final void Function(Post post) likePost;
  final GlobalKey<CartScreenState> cartState;
  final void Function() delete;
  final bool fromLink;
  final bool partial;


  const DiscoverDescription(
      {Key key,
      this.url,
      @required this.post,
      @required this.user,
      @required this.callback,
      this.fromLink: false,@required this.delete,@required this.likePost,@required this.cartState,this.partial:false})
      : super(key: key);

  @override
  _DiscoverDescriptionState createState() => _DiscoverDescriptionState();
}

class _DiscoverDescriptionState extends State<DiscoverDescription>
    with SuperBase {
  double get _appBarHeight => 406.0;
  ScrollController _controller = new ScrollController();

  List<Comment> _list = [];


  List<Post> _favorites = [];


  bool get hasFavorite => _favorites.any((f) => f.id == widget.post.id);


  void likePost() {
    if (widget.user == null) {
      platform.invokeMethod("toast", "Sign in first");
      return;
    }
    setState(() {
      widget.post.liked = !widget.post.liked;
      platform.invokeMethod("toast",widget.post.liked ? "Post added to favorites":"Post removed from favorites");
      widget.post.likes += widget.post.liked ? 1 : -1;
      widget.likePost(widget.post);
    });
    this.ajax(
        url: "discover/like/saveLike/${widget.post.liked}",
        authKey: widget.user()?.token,
        method: "POST",
        server: true,
        data: FormData.fromMap(
            {"post": widget.post?.id, "userInfo": widget.user()?.id}),
        onValue: (s, v) {},
        error: (s, v) {});
  }

  Future<void> loadComments() {
    return this.ajax(
        url: "discover/comment/commentsByPostId/${widget.post?.id}?pageNo=0&pageSize=100",
        authKey: widget.user()?.token,
        onValue: (source, url) {
          Iterable map = jsonDecode(source);
          setState(() {
            _list = map.map((f) => Comment.fromJson(f)).toList();
          });
        },
        error: (s, v) => print(s));
  }

  Widget _convert(String string,{TextStyle style}){
    return convertHashtag(string, onTap: (s) {
      var ls = widget.post.hashtags.where((f) => f.name == s);
      var hash = ls.isEmpty ? Hashtag(s) : ls.first;
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => ViewTagScreen(
            hashtag: hash,
            callback: widget.callback,
            delete: widget.delete,
            cartState: widget.cartState,
            likePost: widget.likePost,
            user: widget.user,
          )));
    },style: style);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{ this.loadComments();

    //if (!widget.fromLink) {
    this.ajax(url: "community/${widget.post?.id}",onValue: (source,url){
      if(canDecode(source)) {
        var j = jsonDecode(source);
        setState(() {
          _post = Post.fromJson(j);
        });
      }
    });
    //}
    var list = await getPostsFav();
    setState(() {
      this._favorites = list;
    });
    });

    _controller.addListener(() {
      if(_controller.position.pixels >=70 && fit != BoxFit.cover ){
        setState(() {
          fit = BoxFit.cover;
        });
      }else if(_controller.position.pixels < 70 && fit != BoxFit.fitHeight ){
        setState(() {
          fit = BoxFit.fitHeight;
        });
      }
    });
  }


  BoxFit fit = BoxFit.fitHeight;

  Post _post;
  Post get post => _post ?? widget.post;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      body: NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon:
                          Image.asset("assets/back.png", height: 29, width: 29),
                      onPressed: () {
                        Navigator.maybePop(context);
                      })
                  : null,
              iconTheme: IconThemeData(color: Colors.white),
              expandedHeight: _appBarHeight - 30,
              floating: false,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              title: innerBoxIsScrolled
                  ? Text(post?.username ?? " -- username --")
                  : null,
              flexibleSpace: PictureItem(
                post: post,
                cartState: widget.cartState,
                callback: widget.callback,
                user: widget.user,
                fit: fit,
              ),
              actions: <Widget>[
                PopupMenuButton(
                    itemBuilder: (context) {
                      return ["Share", "Complain"]
                          .map((f) => PopupMenuItem<String>(
                                child: Text("$f"),
                                value: f,
                              ))
                          .toList();
                    },
                    child: IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      ),
                      onPressed: null,
                      color: Colors.white,
                    ),
                    onSelected: (string) async {
                      switch (string) {
                        case "Share":
                          {
                            sharePost(post, user: widget.user());
                            break;
                          }
                        case "Complain":
                          {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ComplainScreen(
                                        object: widget.user,
                                        post: post)));
                          }
                      }
                    })
              ],
            ),
          ];
        },
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          if (post != null &&
                              post.user != null &&
                              widget.user() != null)
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => DiscoverProfile(
                                          user: () => post?.user,
                                          object: widget.user,
                                          callback: widget.callback,
                                        )));
                        },
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              post?.avatar ?? ""),
                        ),
                        title: Text("${post?.username}"),
                        subtitle: Text("Personal signature"),
                        trailing: FollowButton(
                            followed: post.user,
                            object: widget.user,
                            follower: widget.user()),
                      ),
                      Container(
                        height: 100,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: post.products.length,
                            itemBuilder: (context, index) {
                              var tag = post.products[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => Description(
                                                product: tag.product,
                                                post: widget.post,
                                                callback: widget.callback,
                                                user: widget.user)));
                                  },
                                  child: Container(
                                    width: 250,
                                    child: Row(
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.5),
                                              bottomLeft: Radius.circular(4.5)),
                                          child: FadeInImage(
                                            placeholder: defLoader,
                                            image: CachedNetworkImageProvider(
                                                tag.product.url),
                                            height: 92,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "${tag.product.title}",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: color,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  padding: EdgeInsets.all(4),
                                                  child: Text(
                                                    "\$${tag.product.price}",
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: _convert(post.title,style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: _convert(post.description,style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                            text: TextSpan(
                                children: post.hashtags
                                    .map((f) => WidgetSpan(
                                            child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        ViewTagScreen(
                                                            hashtag: f,
                                                            user: widget.user,
                                                            likePost: (p) {},
                                                            cartState: widget.cartState,
                                                            callback:
                                                                widget.callback,
                                                            delete: () {})));
                                          },
                                          child: Container(
                                            constraints:
                                                BoxConstraints(maxWidth: 100),
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                border: Border.all(color: Colors.grey.shade400),
                                                borderRadius:
                                                    BorderRadius.circular(2.5)),
                                            padding: EdgeInsets.all(5),
                                            margin: EdgeInsets.all(3),
                                            child: Text(
                                              "${f.name}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )))
                                    .toList())),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Reviews(${_list.length})",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _list.length,
                          itemBuilder: (context, index)=>CommentItem(
                              post: post,
                              user: widget.user,
                              callback: widget.callback,
                              comment: _list[index]))
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: RaisedButton(
                    elevation: 0.0,
                    child: Text(
                      "Comment",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: () async {
                          if(widget.user()!=null){
                         await Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CommentSection(
                                callback: widget.callback,
                                  post: post, user: widget.user)));
                          loadComments();
                      }
                      else{
                    platform.invokeListMethod('toast','You must login first');}


                    },
                    color: Color(0xffffe707),
                    padding: EdgeInsets.all(5),
                  )),
                  Container(width: 5),
                  Expanded(
                      child: RaisedButton(
                    elevation: 0.0,
                    child: Text(
                      widget.post.liked ? "Dislike" : "Like",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed:()=> {
                    widget.user()!=null?likePost():platform.invokeListMethod('toast','You must login first')


                      
                      },
                    color: Color(0xffffe707),
                    padding: EdgeInsets.all(5),
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
