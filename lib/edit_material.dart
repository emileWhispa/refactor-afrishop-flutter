import 'dart:convert';

import 'package:afri_shop/SuperBase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';

class EditMaterial extends StatefulWidget {
  final User Function() object;
  final void Function(User user) callback;

  const EditMaterial({Key key, @required this.object,@required this.callback}) : super(key: key);

  @override
  _EditMaterialState createState() => _EditMaterialState();
}

class _EditMaterialState extends State<EditMaterial> with SuperBase {
  TextEditingController _controller = new TextEditingController();
  User _user;
  bool _saving = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = widget.object();
    _controller = new TextEditingController(text: _user?.slogan);
  }

  void saveChanges() {
    setState(() {
      _saving = true;
    });
    _user?.slogan = _controller.text;
    var page = _user?.toServerModel();
    print(page);
    this.ajax(
        url: "user/edit/slogan",
        authKey: widget.object()?.token,
        server: true,
        data: FormData.fromMap(page),
        method: "POST",
        error: (s,v)=>print(s),
        onValue: (source, url) {
          this.auth(jwt, jsonEncode(_user), _user.id);
          widget.callback(_user);
          Navigator.pop(context,source);
        },onEnd: (){
          setState(() {
            _saving = false;
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () async {
                Navigator.maybePop(context);

            })
            : null,title: Text("Edit Materials"), centerTitle: true,actions: <Widget>[
        _saving ? IconButton(icon: CupertinoActivityIndicator(), onPressed: null) :FlatButton(onPressed: saveChanges, child: Text("Save"))
      ],),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Text("Edit caption", style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: new BorderSide(color: Colors.grey.shade300))),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 250.0, minHeight: 70),
                child: new Scrollbar(
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: TextFormField(
                        validator: (s) =>
                            s.trim().isEmpty ? "Field is required !!!" : null,
                        enabled: true,
                        maxLines: null,
                        textAlign: TextAlign.left,
                        onChanged: (s) {
                          setState(() {});
                        },
                        controller: _controller,
                        decoration: InputDecoration.collapsed(
                            hintText: "Add description")),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
