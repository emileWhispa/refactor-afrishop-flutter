import 'dart:convert';

import 'package:afri_shop/Json/problem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class FrequentQuestion extends StatefulWidget {
  final User user;

  const FrequentQuestion({Key key, @required this.user}) : super(key: key);

  @override
  _FrequentQuestionState createState() => _FrequentQuestionState();
}

class _FrequentQuestionState extends State<FrequentQuestion> with SuperBase {
  List<Problem> _list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this.load());
  }

  Future<void> load() {
    return this.ajax(
        url: "problem?pageNum=0&pageSize=100",
        authKey: widget.user.token,
        auth: true,
        onValue: (source, url) {
            print(source);
          Iterable map = json.decode(source)['data']['content'];
          setState(() {
            _list = map.map((json) => Problem.fromJson(json)).toList();
          });
        },
        error: (source, url) {
          print(source);
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
        title: Text(
          "FAQ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: 100,
            color: color,
          ),
          Card(
            margin: EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              child: RefreshIndicator(
                onRefresh: load,
                child: ListView.builder(
                  itemCount: _list.length + 1,
                  itemBuilder: (context, index) {
                    index = index - 1;
                    if (index < 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Frequently Asked Questions",
                          style: Theme.of(context).textTheme.title,
                        ),
                      );
                    }
                    var item = _list[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Text("${item.question}"),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${item.answer}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
