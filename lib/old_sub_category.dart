import 'dart:convert';

import 'package:afri_shop/Json/SubCategory.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/inside_category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/SubSubCategory.dart';
import 'Json/User.dart';

class OldSubCategory extends StatefulWidget {
  final List<SubCategory> list;
  final User Function() user;
  final String title;
  final void Function(User user) callback;

  const OldSubCategory(
      {Key key,
        @required this.list,
        @required this.user,
        this.title,
        @required this.callback})
      : super(key: key);

  @override
  _OldSubCategoryState createState() => _OldSubCategoryState();
}

class _OldSubCategoryState extends State<OldSubCategory> with SuperBase {

  var _key = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _key.currentState?.show(atTop: true);
    });
  }

  List<SubSubCategory> _list = [];

  Future<void> loadData(){
    if( widget.list.isEmpty ) return Future.value();
    return this.ajax(url: "itemStation/queryDescriptionByCTwoId/${widget.list.first?.id}",onValue: (source,v){
      Iterable map = json.decode(source)['data']['descriptionList'];
      setState(() {
        _list = map.map((f)=>SubSubCategory.fromJson(f)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text((widget.title ?? "Afrihome").toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        key: _key,
        onRefresh: loadData,
        child: ListView.builder(
            itemCount: _list.length+1,
            itemBuilder: (context, index) {

              index = index - 1;
              if( index < 0 ){
                if( widget.list.isNotEmpty ) {
                  var cat = widget.list.first;
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:Border.all(color: Colors.grey.shade300)),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: InkWell(
                      onTap: () {

                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => InsideCategory(
                                    category: SubSubCategory(
                                        cat.id, cat.name, cat.url),
                                    user: widget.user,
                                    callback: widget.callback)));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text(
                                  "${cat.name}".toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.w800,fontFamily: 'DIN Alternate',color: Color(0xff4D4D4D)),
                                )),
                            Container(
                                height: 100,
                                width: 100,
                                child: Stack(
                                  children: <Widget>[
                                    cat.url == null
                                        ? Image(
                                      image: defLoader,
                                      height: 100,
                                      width: 1000,
                                    )
                                        : FadeInImage(
                                      image: CachedNetworkImageProvider(cat.url),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      placeholder: defLoader,
                                    ),
                                    Positioned(
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white60,
                                                  Colors.white12,
                                                  Colors.transparent
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              )),
                                        ))
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                  );
                }else return Container();
              }

              var cat = _list[index];
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6)),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => InsideCategory(
                          category: cat,
                          user: widget.user,
                          prefix: "itemStation/queryItemsByTypeThree?typeThreeId",
                          callback: widget.callback,
                        )));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                              "${cat.name}".toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.w800,fontFamily: 'DIN Alternate',color: Color(0xff4D4D4D)),
                            )),
                        Container(
                            height: 100,
                            width: 100,
                            child: Stack(
                              children: <Widget>[
                                cat.image == null
                                    ? Image(
                                  image: defLoader,
                                  height: 100,
                                  width: 1000,
                                )
                                    : FadeInImage(
                                  image: CachedNetworkImageProvider(cat.image),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  placeholder: defLoader,
                                ),
                                Positioned(
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white60,
                                              Colors.white12,
                                              Colors.transparent
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          )),
                                    ))
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
              );
            }),
    ));
  }
}
