import 'package:afri_shop/description.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Product.dart';
import 'Json/User.dart';
import 'SuperBase.dart';

class Favorite extends StatefulWidget{
  final User Function() user;
  final void Function(User user) callback;

  const Favorite({Key key,@required this.user,@required this.callback}) : super(key: key);
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> with SuperBase {
  List<Product> _list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)=>this._loadItems());
  }

  var _refreshKey = new GlobalKey<RefreshIndicatorState>();

  bool _select = false;
  bool get _selectAll => _list.every((element) => element.selected);


  Future<void> _loadItems()async{
    _refreshKey.currentState?.show(atTop: true);
    var list = await getProductsFav();
    setState(() {
      _list = list;
    });
    return Future.value();
  }

  bool _deleting = false;

  void _delete()async{
    showCupertinoModalPopup(context: context, builder: (context)=>new CupertinoAlertDialog(
      title: new Text("Confirm To Delete"),
      content: new Text("Delete This Favorite ?"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text("Cancel"),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: (){
            Navigator.pop(context);
            setState(() {
              _select = false;
            });
            _list.removeWhere((p)=>p.selected);
            saveFavoriteList(_list);
          },
          child: Text("Confirm"),
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
          leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
            Navigator.maybePop(context);
          }) : null,
        title: Text("Favorites",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(onPressed: (){
            setState(() {
              _select = !_select;
            });
          }, child: Text(_select ? "Complete" :"Management"))
        ],
      ),
      body: RefreshIndicator(key: _refreshKey,child:_list.isNotEmpty ? ListView.builder(padding: EdgeInsets.symmetric(vertical: 15),itemCount: _list.length,itemBuilder: (context,index){
        var pro = _list[index];
        var inkWell = InkWell(
          onTap: ()async {
            await Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => Description(
                        user: widget.user, product: pro,callback: widget.callback,)));
            _loadItems();
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                color: Colors.white,borderRadius: BorderRadius.circular(4)),
            margin: EdgeInsets.all(15).copyWith(top: 0),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                FadeInImage(
                  height: 80,
                  width: 80,
                  image: CachedNetworkImageProvider('${pro.url}'),
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
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom:30.0),
                            child: Text(
                              '${pro.title}',
                              style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: <Widget>[

                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color:
                                    Color(0xffffe707),
                                    borderRadius:
                                    BorderRadius
                                        .circular(5)),
                                child: Text(
                                  '\$${pro.price}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              Image.asset("assets/cart_.png",height: 24,width: 24,)
                            ],
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        );

        return _select ? Row(
          children: <Widget>[
            IconButton(icon: Container(
              margin: EdgeInsets.only(
                  left: 10),
              decoration: BoxDecoration(
                  border: pro.selected
                      ? null
                      : Border.all(
                      color:
                      Colors.grey),
                  shape: BoxShape.circle,
                  color: pro.selected
                      ? color
                      : Colors.white),
              child: Padding(
                padding: EdgeInsets.all(
                    pro.selected
                        ? 2.0
                        : 11),
                child: pro.selected
                    ? Icon(
                  Icons.check,
                  size: 20.0,
                  color: Colors.black,
                )
                    : SizedBox.shrink(),
              ),
            ),color: Colors.red, onPressed: (){
              setState(() {
                pro.selected = !pro.selected;
               // _list.removeAt(index);
               // saveFavoriteList(_list);
              });
        }),
            Expanded(child: inkWell)
          ],
        ) : inkWell;
      }) : ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 70,right: 10,top: 70),
                  child: Image(image: AssetImage("assets/empty.png"),height: 130,),
                ),
                SizedBox(height: 20),
                Text("No Saved Items",style: TextStyle(color: Colors.grey),textAlign: TextAlign.center,),
              ],
            ),
          ),
        ],
      ),
        onRefresh: _loadItems,
    ),bottomNavigationBar: !_select ? null : Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                bool _selectAll = !this._selectAll;
                _list.forEach((f)=>f.selected = _selectAll);
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
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
          Text("Select all"),
          Spacer(),
          Container(
            height: 30,
            child: RaisedButton(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero),
              onPressed: _deleting ? null : _delete,
              child: _deleting
                  ? loadBox()
                  : Text("Delete"),
              color: color,
            ),
          )
        ],
      ),
    ),);
  }
}