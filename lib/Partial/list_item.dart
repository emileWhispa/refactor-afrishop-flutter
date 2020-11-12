import 'dart:ui';

import 'package:afri_shop/Json/Post.dart';
import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/Json/hashtag.dart';
import 'package:afri_shop/Partial/NowBuilder.dart';
import 'package:afri_shop/Partial/video_app.dart';
import 'package:afri_shop/complain_screen.dart';
import 'package:afri_shop/discover_profile.dart';
import 'package:afri_shop/tag_preview.dart';
import 'package:afri_shop/view_tag_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../SuperBase.dart';
import '../cart_page.dart';
import '../comment_section.dart';
import '../discover_description.dart';

class ListItem extends StatefulWidget {
  final Post post;
  final User Function() user;
  final void Function(Post post) likePost;
  final void Function(User user) callback;
  final void Function() delete;
  final GlobalKey<CartScreenState> cartState;

  const ListItem(
      {Key key,
      @required this.post,
      @required this.user,
      @required this.likePost,
      @required this.delete,
      @required this.callback,
      @required this.cartState})
      : super(key: key);

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> with SuperBase {
  Post get pst => widget.post;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      var liked = (await prefs).containsKey(_likeUrl);
      setState(() {
       // widget.post.liked = liked;
      });
    });
  }


  String get _likeUrl => "post-like-${widget.post?.id}";

  void likePost() {
    if (widget.user == null) {
      platform.invokeMethod("toast", "Sign in first");
      return;
    }
    setState(() {
      widget.post.liked = !widget.post.liked;
      widget.post.likes += widget.post.liked ? 1 : (widget.post.likes > 0 ? -1 : 0);
      widget.likePost(widget.post);
    });
    this.ajax(
        url: "discover/like/saveLike/${widget.post.liked}",
        authKey: widget.user()?.token,
        method: "POST",
        server: true,
        data: FormData.fromMap(
            {"post": widget.post?.id, "userInfo": widget.user()?.id}),
        onValue: (s, v) async {

          if (widget.post.liked)
            saveVal(_likeUrl, "liked");
          else
            (await prefs).remove(_likeUrl);
        },
        error: (s, v) {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () async {
        if (widget.user == null) {
          platform.invokeMethod("toast", "Not signed in");
          return;
        }
        await Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => DiscoverDescription(
                  post: widget.post,
                  user: widget.user,
                  callback: widget.callback,
                  likePost: widget.likePost,
                  delete: widget.delete,
                  cartState: widget.cartState,
                  url: CachedNetworkImageProvider(widget.post.bigImage),
                )));
        widget.cartState?.currentState?.refresh();
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8)),
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.all(5),
              leading: InkWell(
                onTap: () async {
                  var user = pst.user;

                  if (user == null && pst.hasUserId) {
                    user = pst.getDynamicUser;
                  }

                  if (widget.user() != null && user != null)
                    await Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => DiscoverProfile(
                                user: () => user,
                                object: widget.user,
                                callback: widget.callback)));
                  widget.cartState?.currentState?.refresh();
                },
                child: CircleAvatar(
                  backgroundImage: pst?.hasAvatar == false
                      ? defLoader
                      : CachedNetworkImageProvider(pst.avatar),
                ),
              ),
              title: Text(
                "${pst.username}",
                style: TextStyle(fontFamily: 'Futura'),
              ),
              subtitle: NowBuilder(
                  date: pst.dateTime,
                  style: TextStyle(
                      color: Colors.grey, fontSize: 12, fontFamily: 'Futura')),
              trailing: IconButton(
                  icon: Image(
                    image: AssetImage("assets/btnicon_more.png"),
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return _Repost(
                              post: widget.post,
                              user: widget.user,
                              delete: widget.delete);
                        });
                  }),
            ),
            Container(
              height: 350,
              child: PictureItem(
                post: pst,
                user: widget.user,
                callback: widget.callback,
                cartState: widget.cartState,
                clickable: false,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CommentSection(
                                  post: widget.post,
                                  user: widget.user,
                                  callback: widget.callback,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 3.0),
                    child: Image(
                      image: AssetImage("assets/comments.png"),
                      width: 21,
                      height: 21,
                    ),
                  ),
                ),
                Text(
                  "${pst.comments}",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontFamily: 'DIN Alternate'),
                ),
                InkWell(
                  onTap: likePost,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 3.0),
                    child: Icon(
                      widget.post.liked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Color(0xffffe707),
                    ),
                  ),
                ),
                Text(
                  "${pst.likes}",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontFamily: 'DIN Alternate'),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    sharePost(widget.post, user: widget.user());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                    child: Image(
                      image: AssetImage("assets/forwarding.png"),
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: convertHashtag(pst.title, onTap: (s) async {
                var ls = widget.post.hashtags.where((f) => f.name == s);
                var hash = ls.isEmpty ? Hashtag(s) : ls.first;
                await Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => ViewTagScreen(
                          hashtag: hash,
                          callback: widget.callback,
                          delete: widget.delete,
                          cartState: widget.cartState,
                          likePost: widget.likePost,
                          user: widget.user,
                        )));
                widget.cartState?.currentState?.refresh();
              }),
            )
          ],
        ),
      ),
    );
  }
}

class PictureItem extends StatefulWidget {
  final Post post;
  final User Function() user;
  final void Function(User user) callback;
  final bool clickable;
  final GlobalKey<CartScreenState> cartState;
  final BoxFit fit;

  const PictureItem(
      {Key key,
      @required this.post,
      @required this.user,
      @required this.callback,
      this.clickable: true,
      @required this.cartState, this.fit})
      : super(key: key);

  @override
  _PictureItemState createState() => _PictureItemState();
}

class _PictureItemState extends State<PictureItem> with SuperBase {
  Post get pst => widget.post;
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        PageView.builder(
            itemCount: pst.pictures.length,
            onPageChanged: (index) {
              setState(() {
                _index = index;
              });
            },
            itemBuilder: (context, index) {
              var pic = pst.pictures[index];
              return GestureDetector(
                onTap: widget.clickable
                    ? () async {
                        await Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => TagPreview(
                                  post: pst,
                                  user: widget.user,
                                  initialPage: index,
                                  callback: widget.callback,
                                ),
                            fullscreenDialog: true));
                        widget.cartState?.currentState?.refresh();
                      }
                    : null,
                child: Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: CachedNetworkImageProvider(pic.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: pic.isImage
                        ? FadeInImage(
                            height: 350,
                            image: CachedNetworkImageProvider(pic.image),
                            fit: widget.fit ?? BoxFit.cover,
                            placeholder: defLoader,
                            width: double.infinity,
                          )
                        : VideoApp(
                            url: pic.image,
                            thumb: pic.thumb,
                          ),
                  ),
                ),
              );
            }),
        Positioned(
            bottom: 15,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pst.pictures
                  .asMap()
                  .map((v, f) => MapEntry(
                      v,
                      Container(
                        height: 10,
                        width: 10,
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            color: v == _index ? color : Colors.black38,
                            shape: BoxShape.circle),
                      )))
                  .values
                  .toList(),
            ))
      ],
    );
  }
}

class _Repost extends StatefulWidget {
  final Post post;
  final User Function() user;
  final void Function() delete;

  const _Repost(
      {Key key,
      @required this.post,
      @required this.user,
      @required this.delete})
      : super(key: key);

  @override
  __RepostState createState() => __RepostState();
}

class __RepostState extends State<_Repost> with SuperBase {
  bool _sending = false;

  void rePost() {
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "discover/post/repost/${widget.user()?.id}/${widget.post?.id}",
        method: "POST",
        authKey: widget.user()?.token,
        server: true,
        onValue: (source, url) {
          platform.invokeMethod("toast", "reposted successfully");
          Navigator.pop(context);
        },
        error: (s, v) => print(s),
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      contentPadding: EdgeInsets.all(6),
      content: _sending
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: CupertinoActivityIndicator(),
                ))
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.user()?.id == widget.post.userId
                    ? FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.delete();
                        },
                        child: Text(
                          "DELETE POST",
                          textAlign: TextAlign.left,
                        ))
                    : SizedBox.shrink(),
                widget.user()?.id == widget.post.userId
                    ? SizedBox.shrink()
                    : FlatButton(onPressed: rePost, child: Text("RESHARE POST")),
                widget.user()?.id == widget.post.userId
                    ? SizedBox.shrink()
                    : FlatButton(onPressed: (){
                      Navigator.push(context, CupertinoPageRoute(builder: (context)=>ComplainScreen(object: widget.user, post: widget.post)));
                }, child: Text("REPORT POST")),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("CANCEL")),
              ],
            ),
    );
  }
}
