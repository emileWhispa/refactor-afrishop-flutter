import 'dart:io';

import 'package:afri_shop/Partial/image_map.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/Product.dart';
import 'Json/User.dart';
import 'Json/choice.dart';
import 'Json/position.dart';

class ProductTag extends StatefulWidget {
  final Choice choice;
  final List<Product> list;
  final User Function() user;
  final void Function(User user) callback;

  const ProductTag(
      {Key key,
      @required this.choice,
      @required this.list,
      @required this.user,
      @required this.callback})
      : super(key: key);

  @override
  _ProductTagState createState() => _ProductTagState();
}

class _ProductTagState extends State<ProductTag> with SuperBase {
  Position _selected;

  var key = new GlobalKey<ImageMapState>();

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
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.maybePop(context, widget.choice);
                },
                child: Text("Next"))
          ],
        ),
        body: GridTile(
          child: ImageMap(
            key: key,
            provider: FileImage(widget.choice.file),
            choice: widget.choice,
            positions: widget.choice.list,
            user: widget.user,
            callback: widget.callback,
            firstTaped: (p){
              setState(() {
                _selected = p;
              });
            },
          ),
          footer: Container(
            color: Colors.black26,
            padding: EdgeInsets.all(25),
            child: _selected == null
                ? Column(
                    children: <Widget>[
                      Image.asset("assets/hand.png", height: 25, width: 25),
                      SizedBox(height: 7),
                      Text(
                        "Click the picture to add product information",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        "Have the chance to show your experience to many people",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      )
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.cached,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          Text(
                            "Add products description",
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          Spacer(),
                          InkWell(
                              onTap: () async {},
                              child: Text(
                                "Find products from order",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              )),
                        ],
                      ),
                      Container(
                        height: 45,
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: TextFormField(
                          onChanged: (string) {
                            _selected.tagName = string;
                            key.currentState?.populate(_selected);
                          },
                          onFieldSubmitted: (string) {
                            _selected.tagName = string;
                            key.currentState?.populate(_selected);
                          },
                          initialValue: _selected.tagName,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white70,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              hintText: "Trumpet sleeveless Top",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                                borderSide: BorderSide.none,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    _selected = null;
                                  });
                                  },
                                child: Text("CANCEL"),
                                textColor: color,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: color),
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            )),
                            Expanded(
                                child: RaisedButton(
                              onPressed: () {
                                key.currentState?.populate(_selected);
                                setState(() {
                                  _selected = null;
                                });
                              },
                              child: Text("SUBMIT"),
                              color: color,
                            )),
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        ));
  }
}
