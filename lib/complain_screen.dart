import 'package:afri_shop/Json/Post.dart';
import 'package:afri_shop/Json/User.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComplainScreen extends StatefulWidget {
  final User Function() object;
  final Post post;

  const ComplainScreen({Key key, @required this.object, @required this.post})
      : super(key: key);

  @override
  _ComplainScreenState createState() => _ComplainScreenState();
}

class _ComplainScreenState extends State<ComplainScreen> with SuperBase {
  bool _saving = false;
  List<String> _list = [
    "Obscene news",
    "Content plagiarism",
    "Personal attacks",
    "Harmful information",
  ];
  String _selected;
  TextEditingController _controller = new TextEditingController();

  void saveChanges() {

    if( _selected == null ) {
      platform.invokeMethod("toast","Choose complain type");
      return;
    }

    if( _controller.text.trim().isEmpty ) {
      platform.invokeMethod("toast","Descriptions are required");
      return;
    }

    setState(() {
      _saving = true;
    });
    this.ajax(
        url: "saveComplain",
        authKey: widget.object()?.token,
        server: true,
        data: FormData.fromMap({
          "description": _controller.text,
          "type": _selected,
          "post": widget.post?.id,
          "userInfo": widget.object()?.id,
        }),
        method: "POST",
        error: (s, v) => print(s),
        onValue: (source, url) {
          platform.invokeMethod("toast", "Complain message successfully sent");
          Navigator.pop(context, source);
        },
        onEnd: () {
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
                    onPressed: () {
                      Navigator.maybePop(context);
                    })
                : null,
            title: Text("Complain"),
            centerTitle: true),
        body: Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 12),
          child: ListView(
            padding: EdgeInsets.all(15),
            children: <Widget>[
              Text("Types of Complains",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 5.5,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 10,
                      crossAxisCount: 2),
                  children: _list
                      .map((f) => InkWell(
                    onTap: (){
                      setState(() {
                        _selected = f;
                      });
                    },
                        child: Container(
                    decoration: BoxDecoration(
                        color: _selected == f ? color : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3)
                    ),
                              child: Center(child: Text("$f")),
                            ),
                      ))
                      .toList(),
                ),
              ),
              Text("Remarks", style: TextStyle(fontWeight: FontWeight.bold)),
              _area,
              Align(
                alignment: Alignment.centerRight,
                child: Text("${_controller.text.length}/50000",
                    style: TextStyle(color: Colors.grey, fontSize: 12.1)),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                  width: double.infinity,
                  child: _saving ? CupertinoActivityIndicator() : RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    color: color,
                    elevation: 0.0,
                    onPressed: saveChanges,
                    child: Text(
                      "Submit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
            ],
          ),
        ));
  }


  Widget get _area => Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
          border: Border(bottom: new BorderSide(color: Colors.grey.shade300))),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 250.0, minHeight: 170),
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
                decoration:
                InputDecoration.collapsed(hintText: "Add description")),
          ),
        ),
      ));
}
