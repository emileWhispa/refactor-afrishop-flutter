import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Json/User.dart';
import 'Json/info.dart';
import 'SuperBase.dart';

class ContactUs extends StatefulWidget {
  final User user;

  const ContactUs({Key key, @required this.user}) : super(key: key);

  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> with SuperBase {
  List<Info> _list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this.load());
  }

  Future<void> load() {
    return this.ajax(
        url: "contact?pageNum=1&pageSize=300",
        authKey: widget.user.token,
        auth: true,
        onValue: (source, url) {
          Iterable map = json.decode(source)['data'];
          setState(() {
            _list = map.map((json) => Info.fromJson(json)).toList();
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
          "Contact",
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Contact us",
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Text(
                    "Any questions can be directed to",
                    style: TextStyle(color: Colors.grey),
                  ),
                  _list.length > 2
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${_list[1].contactDetail}",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  "Contact number: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    "${_list[0].contactDetail}",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            RichText(
                                text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Contact address: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                TextSpan(
                                  text: "${_list[2].contactDetail}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )),
                          ],
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(height: 40),
                  Container(
                      width: double.infinity,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        color: color,
                        elevation: 0.0,
                        onPressed: () async {
                          if (_list.length > 2) {
                            var phone =
                                _list[0].contactDetail.split(" ").join("");
                            phone = 'tel:$phone';
                            if (await canLaunch(phone)) {
                              launch(phone);
                            }
                          }
                        },
                        child: Text(
                          "Phone",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                            side: BorderSide(color: Colors.grey.shade300)),
                        elevation: 0.0,
                        onPressed: () async {
                          if (_list.length > 2) {
                            var phone =
                                _list[2].contactDetail.split(" ").join("");
                            phone = 'mailto:$phone';
                            if (await canLaunch(phone)) {
                              launch(phone);
                            }
                          }
                        },
                        child: Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                  Spacer()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
