import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'Json/evaluation.dart';
import 'SuperBase.dart';

class FeedbackList extends StatefulWidget {
  final User user;

  const FeedbackList({Key key, @required this.user}) : super(key: key);

  @override
  _FeedbackListState createState() => _FeedbackListState();
}

class _FeedbackListState extends State<FeedbackList> with SuperBase {
  List<Evaluation> _list = [];
  var _refreshKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this.loadEvaluation());
  }

  Future<void> loadEvaluation() {
    _refreshKey.currentState?.show(atTop: true);
    return this.ajax(
        url: "feedback?list",
        auth: true,
        authKey: widget.user?.token,
        onValue: (source, url) {
          print(source);
          Iterable map = json.decode(source)['data'];
          setState(() {
            _list = map.map((json) => Evaluation.fromJson(json)).toList();
          });
        },error: (s,v)=>print(s));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text("Feedback list"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: loadEvaluation,
        child: Scrollbar(
            child: ListView.builder(
                itemCount: _list.length, itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("${_list[index].question}"),
                    subtitle: Text("${_list[index].createTime}"),
                  );
            })),
      ),
    );
  }
}
