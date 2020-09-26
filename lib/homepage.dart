import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:afri_shop/Json/SubCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Brand.dart';
import 'Json/Product.dart';
import 'Partial/TouchableOpacity.dart';
import 'SuperBase.dart';
import 'detail_screen.dart';
import 'item.dart';

class Homepage extends StatefulWidget {
  final void Function(Item item) callback;

  const Homepage({Key key, this.callback}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with AutomaticKeepAliveClientMixin, SuperBase {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      this._loadBrands();
      this._loadProducts();
    });
  }

  void _loadBrands() {
    this.ajax(
        url: "brands/list",
        onValue: (source, url) {
          Iterable _map = json.decode(source);
          setState(() {
            _brands = _map.map((f) => Brand.fromJson(f)).toList();
          });
        },
        error: (s, v) {
          print(s);
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: CustomScrollView(
        slivers: _list,
      ),
    );
  }

  final double _appBarHeight = 256.0;

  Widget get appBar {
    return SliverAppBar(
      expandedHeight: _appBarHeight,
      pinned: true,
      elevation: 1.0,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Edit',
          onPressed: _loadBrands,
        ),
        PopupMenuButton<Item>(
          onSelected: (Item value) {},
          itemBuilder: (BuildContext context) => <PopupMenuItem<Item>>[],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text("Afrishop"),
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              fit: BoxFit.cover,
              height: _appBarHeight,
              imageUrl:
                  "https://s7d1.scene7.com/is/image/BHLDN/50827450_065_a?\$pdpmain\$",
              placeholder: (BuildContext context, String s) =>
                  CupertinoActivityIndicator(),
            ),
            // This gradient ensures that the toolbar icons are distinct
            // against the background image.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, -1.0),
                  end: Alignment(0.0, -0.4),
                  colors: <Color>[Color(0x60000000), Color(0x00000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _list {
    List<Widget> list = <Widget>[
      appBar,
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.phone_android,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Phones",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.amber,
                    radius: 35,
                    child: Icon(
                      Icons.headset,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Headsets",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )),
              Expanded(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.purple,
                      child: Icon(
                        Icons.watch,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Watches",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.computer,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Computers",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.deepOrange,
                      child: Icon(
                        Icons.beach_access,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Umbrellas",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.motorcycle,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Bikes",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.pink,
                      child: Icon(
                        Icons.directions_car,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Cars",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.teal,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Clothers",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "#",
                  style: TextStyle(color: Color(0xffffe707), fontSize: 21),
                ),
                Text(
                  "BRANDS",
                  style: TextStyle(fontSize: 22),
                ),
                Text(
                  "#",
                  style: TextStyle(color: Color(0xffffe707), fontSize: 21),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xffffe707),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: GridView.builder(
                itemCount: _brands.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.4 / 4,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0),
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(minHeight: 150),
                          decoration: BoxDecoration(color: Colors.white),
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                          child: CachedNetworkImage(
                            imageUrl: _brands[index].itemImg1,
                            fit: BoxFit.cover,
                            placeholder: (context, str) => Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          )),
                      SizedBox(height: 5),
                      Expanded(
                          child: Text(
                        _brands[index].storeName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.title,
                      )),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
      SliverToBoxAdapter(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 3.0 / 4,
            ),
            itemCount: _list1.length > 6 ? 6 : _list1.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var item = _list1[index];
              return TouchableOpacity(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => DetailScreen(
                            key: UniqueKey(),
                            category: SubCategory("1",item.title,item.url),
                          )));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Container(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      child: Image(
                        image: CachedNetworkImageProvider(item.url),
                        fit: BoxFit.cover,
                        loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null ?
                              loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ),
                    )),
                    Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          item.title,
                          style: TextStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                    Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          '\$${item.price}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))
                  ],
                ),
              );
            }),
      )
    ];
    return list;
  }

  List<Brand> _brands = [];

  List<Product>  _list1 = [];

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


  Future<void> _loadProducts(){
    return this.ajax(url: "products/list",onValue: (source,url){
      Iterable _map = json.decode(source);
      setState(() {
        _list1 = _map.map((f)=>Product.fromJson(f)).toList();
      });
    });
  }
}
