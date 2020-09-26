import 'dart:io';

import 'package:afri_shop/product_tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Json/User.dart';
import 'Json/choice.dart';
import 'discover_pic_preview.dart';

class RecentScreen extends StatefulWidget{
  final List<Choice> images;
  final User Function() user;
  final void Function(User user) callback;

  const RecentScreen({Key key, this.images,@required this.user,@required this.callback}) : super(key: key);
  @override
  _RecentScreenState createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<Choice> _list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _list = widget.images ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(
            icon: Icon(Icons.arrow_back_ios), onPressed: () {
          Navigator.maybePop(context);
        }) : null,
        title: Text("Recents",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(onPressed: (){
            Navigator.pop(context,_list);
          }, child: Text("Next"))
        ],
      ),
      body: GridView.builder(padding:EdgeInsets.all(5),itemCount: _list.length+1,gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,mainAxisSpacing: 3,crossAxisSpacing: 3), itemBuilder: (context,index){
        index = index - 1;

        if( index < 0 ){
          return InkWell(onTap: ()async{
            },child: Image(image: AssetImage(
              "assets/take_a_photo.png"),fit: BoxFit.cover,));
        }

        return InkWell(onTap: ()async{
          var c = await Navigator.push(context, CupertinoPageRoute<Choice>(builder: (context)=>ProductTag(choice: _list[index],list:[],user: widget.user,callback: widget.callback,)));
          if( c != null ){
            _list..removeAt(index)..add(c);
          }
        },child: Image(image: FileImage(_list[index].file),fit: BoxFit.cover,));
      }),
    );
  }
}