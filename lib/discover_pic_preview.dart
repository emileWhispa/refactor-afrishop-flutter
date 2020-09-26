import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/Json/choice.dart';
import 'package:afri_shop/select_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';

class DiscoverPicPreview extends StatefulWidget {
  final Choice choice;
  final List<Product> list;

  const DiscoverPicPreview({Key key, @required this.choice,@required this.list}) : super(key: key);

  @override
  _DiscoverPicPreviewState createState() => _DiscoverPicPreviewState();
}

class _DiscoverPicPreviewState extends State<DiscoverPicPreview>
    with SuperBase {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        actions: <Widget>[
          FlatButton(
              child: Row(
                children: <Widget>[
                  Text("Select"),
                  Icon(Icons.check_circle),
                ],
              ),
              onPressed: null)
        ],
      ),
      body: GridTile(
        child: Image(
          image: FileImage(widget.choice?.file),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        footer: Container(
          color: Colors.black26,
          padding: EdgeInsets.all(15),
          child: Column(
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
                      onTap: () async {
                        var list = await Navigator.push(
                            context,
                            CupertinoPageRoute<List<Product>>(
                                builder: (context) => SelectProduct()));
                        if( list != null ){
                          //widget.choice?.list = list.toList();
                        }
                      },
                      child: Text(
                        "Find products from order",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      )),
                ],
              ),
              Container(
                height: 45,
                margin: EdgeInsets.symmetric(vertical: 30),
                child: TextFormField(
                  onChanged: (string) {
                    widget.choice?.tag = string;
                  },
                  initialValue: widget.choice?.tag,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      hintText: "Trumpet sleeveless Top",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
              widget.choice?.list?.isNotEmpty ?? false
                  ? Text(
                      "${widget.choice.list.map((f) => '#${f.x}').join(", ")}",
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FlatButton(
                        onPressed: () {},
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
                        Navigator.pop(context, widget.choice);
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
      ),
    );
  }
}
